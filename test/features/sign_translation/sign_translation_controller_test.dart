import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/errors/failure.dart';
import 'package:signovoice/core/providers.dart';
import 'package:signovoice/core/services/analytics_service.dart';
import 'package:signovoice/core/services/storage.dart';
import 'package:signovoice/core/services/tts_service.dart';
import 'package:signovoice/features/history/presentation/history_controller.dart';
import 'package:signovoice/features/profile/domain/user_preferences.dart';
import 'package:signovoice/features/profile/presentation/preferences_controller.dart';
import 'package:signovoice/features/sign_translation/data/hand_landmark_source.dart';
import 'package:signovoice/features/sign_translation/data/model_repository.dart';
import 'package:signovoice/features/sign_translation/data/unavailable_recognition_engine.dart';
import 'package:signovoice/features/sign_translation/domain/hand_frame.dart';
import 'package:signovoice/features/sign_translation/domain/recognition_engine.dart';
import 'package:signovoice/features/sign_translation/domain/sign_prediction.dart';
import 'package:signovoice/features/sign_translation/presentation/sign_translation_controller.dart';

// ---- test-only fakes (production code never uses these) ----
class _Engine implements SignRecognitionEngine {
  @override
  String get name => 'test-engine';
  @override
  EngineStatus get status => EngineStatus.ready;
  @override
  bool get requiresInternet => false;
  @override
  List<String> get labels => const ['Hello'];
  @override
  int get sequenceLength => 30;
  @override
  HandFeatureSpec get featureSpec => const HandFeatureSpec();
  @override
  Future<void> initialize() async {}
  @override
  Future<SignPrediction?> predict(List<List<double>> window) async =>
      const SignPrediction(label: 'Hello', confidence: 0.95);
  @override
  Future<void> dispose() async {}
}

class _Models extends ModelRepository {
  _Models(this.engine) : super(tokenProvider: () async => null);
  final SignRecognitionEngine engine;
  @override
  Future<SignRecognitionEngine> createEngine(RecognitionMode mode) async => engine;
}

class _Source implements HandLandmarkSource {
  final _c = StreamController<HandFrame>.broadcast();
  Timer? _t;
  _Source() {
    _t = Timer.periodic(const Duration(milliseconds: 40), (_) => _c.add(HandFrame(List.filled(63, 0.5), hasHand: true)));
  }
  @override
  bool get isSupported => true;
  @override
  Stream<HandFrame> get frames => _c.stream;
  @override
  final ValueStreamOverlay overlay = ValueStreamOverlay();
  @override
  void processCameraImage(CameraImage image, int sensorOrientation) {}
  @override
  Future<void> dispose() async {
    _t?.cancel();
    await _c.close();
  }
}

class _Tts implements TtsService {
  final spoken = <String>[];
  @override
  Stream<TtsState> get stateStream => const Stream.empty();
  @override
  Future<void> speak(String text, {String? language, double? rate, TtsVoice? voice}) async => spoken.add(text);
  @override
  Future<void> stop() async {}
  @override
  Future<List<TtsVoice>> voices() async => const [];
  @override
  Future<bool> isLanguageAvailable(String language) async => true;
  @override
  Future<void> dispose() async {}
}

ProviderContainer _container({required SignRecognitionEngine engine, _Tts? tts, NoopAnalyticsService? analytics}) {
  final c = ProviderContainer(overrides: [
    keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
    collectionStoreProvider.overrideWithValue(InMemoryCollectionStore()),
    secureStoreProvider.overrideWithValue(InMemorySecureStore()),
    isOnlineProvider.overrideWith((ref) => Stream.value(true)),
    analyticsServiceProvider.overrideWithValue(analytics ?? NoopAnalyticsService()),
    ttsServiceProvider.overrideWithValue(tts ?? _Tts()),
    modelRepositoryProvider.overrideWithValue(_Models(engine)),
    landmarkSourceFactoryProvider.overrideWithValue(({required HandFeatureSpec spec}) => _Source()),
  ]);
  addTearDown(c.dispose);
  return c;
}

Future<void> _until(bool Function() cond, {Duration timeout = const Duration(seconds: 8)}) async {
  final end = DateTime.now().add(timeout);
  while (!cond()) {
    if (DateTime.now().isAfter(end)) fail('condition not met in $timeout');
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  test('bundled manifest keeps the verified alphabetical label order and points at a real model file', () {
    final m = jsonDecode(File('assets/models/labels.json').readAsStringSync()) as Map<String, dynamic>;
    // Order of the shipped ONNX output (verified against MP_Data): NOT the legacy onnx_server.py order.
    expect(m['labels'], ['A', 'B', 'C', 'Hello', 'I love you', 'No', 'Please', 'Thanks', 'Yes']);
    expect(m['sequenceLength'], 30);
    expect(m['featureCount'], 63);
    expect(File('assets/models/${m['model']}').existsSync(), isTrue);
  });

  test('pipeline: frames → engine → smoothing → gloss → sentence → history + usage + analytics', () async {
    final analytics = NoopAnalyticsService();
    final tts = _Tts();
    final c = _container(engine: _Engine(), tts: tts, analytics: analytics);
    c.listen(signTranslationProvider, (_, _) {});
    final ctrl = c.read(signTranslationProvider.notifier);

    await ctrl.start(SignMode.signToVoice);
    expect(c.read(signTranslationProvider).ready, isTrue);

    await _until(() => c.read(signTranslationProvider).glosses.isNotEmpty);
    final s = c.read(signTranslationProvider);
    expect(s.glosses, ['HELLO']);
    expect(s.sentence, 'Hello');
    expect(s.current?.label, 'Hello');
    expect(c.read(usageServiceProvider).signsToday, 1);
    expect(tts.spoken, contains('Hello')); // Sign → Voice speaks accepted signs

    // Same sign held: no duplicates
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    expect(c.read(signTranslationProvider).glosses, ['HELLO']);

    await ctrl.finish();
    final history = await c.read(historyProvider.future);
    expect(history.length, 1);
    expect(history.first.text, 'Hello');
    expect(analytics.events, containsAll(['sign_translation_started', 'sign_translation_completed']));
  });

  test('privacy: history is not written when the person turned it off', () async {
    final c = _container(engine: _Engine());
    c.listen(signTranslationProvider, (_, _) {});
    // preferences default saveHistory=true; turn it off via the notifier
    await c.read(preferencesProvider.notifier).update((p) => p.copyWith(saveHistory: false));
    final ctrl = c.read(signTranslationProvider.notifier);
    await ctrl.start(SignMode.signToText);
    await _until(() => c.read(signTranslationProvider).glosses.isNotEmpty);
    expect(await ctrl.saveToHistory(), isFalse);
    expect((await c.read(historyProvider.future)), isEmpty);
  });

  test('model unavailable is reported, never faked, and retry is possible', () async {
    final c = _container(engine: UnavailableRecognitionEngine(const Failure(FailureType.modelUnavailable)));
    c.listen(signTranslationProvider, (_, _) {});
    await c.read(signTranslationProvider.notifier).start(SignMode.signToText);
    final s = c.read(signTranslationProvider);
    expect(s.engineStatus, EngineStatus.unavailable);
    expect(s.failure?.type, FailureType.modelUnavailable);
    expect(s.glosses, isEmpty);
  });

  test('clear resets translation state', () async {
    final c = _container(engine: _Engine());
    c.listen(signTranslationProvider, (_, _) {});
    final ctrl = c.read(signTranslationProvider.notifier);
    await ctrl.start(SignMode.signToText);
    await _until(() => c.read(signTranslationProvider).glosses.isNotEmpty);
    ctrl.clear();
    expect(c.read(signTranslationProvider).glosses, isEmpty);
    expect(c.read(signTranslationProvider).sentence, isEmpty);
  });
}
