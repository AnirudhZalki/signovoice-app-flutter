import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/haptics_service.dart';
import '../../learning/domain/learning_progress.dart';
import '../../learning/presentation/learning_controller.dart';
import '../../profile/presentation/preferences_controller.dart';
import '../../sign_translation/data/hand_landmark_source.dart';
import '../../sign_translation/domain/hand_frame.dart';
import '../../sign_translation/domain/recognition_engine.dart';
import '../../sign_translation/domain/sequence_buffer.dart';
import '../../sign_translation/domain/sign_prediction.dart';
import '../../sign_translation/presentation/sign_translation_controller.dart';
import '../domain/practice_evaluator.dart';

enum PracticePhase { loading, idle, countdown, capturing, result, error }

class PracticeState {
  const PracticeState({
    this.phase = PracticePhase.loading,
    this.failure,
    this.countdown = 0,
    this.result,
    this.xpEarned = 0,
    this.handVisible = false,
    this.captureProgress = 0,
  });

  final PracticePhase phase;
  final Failure? failure;
  final int countdown;
  final PracticeResult? result;
  final int xpEarned;
  final bool handVisible;

  /// 0..1 while capturing.
  final double captureProgress;

  PracticeState copyWith({
    PracticePhase? phase,
    Failure? failure,
    bool clearFailure = false,
    int? countdown,
    PracticeResult? result,
    bool clearResult = false,
    int? xpEarned,
    bool? handVisible,
    double? captureProgress,
  }) =>
      PracticeState(
        phase: phase ?? this.phase,
        failure: clearFailure ? null : (failure ?? this.failure),
        countdown: countdown ?? this.countdown,
        result: clearResult ? null : (result ?? this.result),
        xpEarned: xpEarned ?? this.xpEarned,
        handVisible: handVisible ?? this.handVisible,
        captureProgress: captureProgress ?? this.captureProgress,
      );
}

/// One practice attempt at a time: countdown (buffer fills) → 3 s capture →
/// evaluate against the requested sign using the same on-device model.
class PracticeController extends Notifier<PracticeState> {
  static const captureDuration = Duration(seconds: 3);
  static const countdownSeconds = 3;

  SignRecognitionEngine? _engine;
  HandLandmarkSource? _source;
  StreamSubscription<HandFrame>? _sub;
  Timer? _frameTimer;
  Timer? _tickTimer;
  HandFrame _emptyFrame = HandFrame.empty;
  HandFrame _latest = HandFrame.empty;
  DateTime _latestAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastFeed = DateTime.fromMillisecondsSinceEpoch(0);
  LandmarkSequenceBuffer _buffer = LandmarkSequenceBuffer(length: AppConstants.sequenceLength);
  final List<SignPrediction> _predictions = [];
  bool _inFlight = false;
  bool _disposed = false;
  bool _started = false;
  String _signId = '';
  String _label = '';

  HandLandmarkSource? get source => _source;

  @override
  PracticeState build() {
    ref.onDispose(() {
      _disposed = true;
      _teardown();
    });
    return const PracticeState();
  }

  Future<void> start({required String signId, required String label}) async {
    if (_started) return;
    _started = true;
    _signId = signId;
    _label = label;
    state = const PracticeState(phase: PracticePhase.loading);
    final prefs = ref.read(preferencesProvider);
    try {
      final engine = await ref.read(modelRepositoryProvider).createEngine(prefs.recognitionMode);
      if (_disposed) {
        await engine.dispose();
        return;
      }
      if (engine.status != EngineStatus.ready) await engine.initialize();
      _engine = engine;
      _emptyFrame = HandFrame.emptyFor(engine.featureSpec.featureCount);
      _latest = _emptyFrame;
      _buffer = LandmarkSequenceBuffer(length: engine.sequenceLength);
      _source = ref.read(landmarkSourceFactoryProvider)(spec: engine.featureSpec.copyWith(mirrorX: prefs.mirrorCamera));
      _sub = _source!.frames.listen((f) {
        _latest = f;
        _latestAt = DateTime.now();
      });
      _frameTimer = Timer.periodic(AppConstants.frameInterval, (_) {
        final fresh = DateTime.now().difference(_latestAt) < const Duration(milliseconds: 250);
        final f = fresh ? _latest : _emptyFrame;
        _buffer.add(f);
        if (!_disposed && state.handVisible != f.hasHand && state.phase != PracticePhase.result) {
          state = state.copyWith(handVisible: f.hasHand);
        }
      });
      state = state.copyWith(phase: PracticePhase.idle);
    } catch (e) {
      _started = false;
      _teardown();
      if (!_disposed) state = PracticeState(phase: PracticePhase.error, failure: toFailure(e));
    }
  }

  void onCameraImage(CameraImage image, int rotationDegrees) {
    if (_source == null) return;
    final now = DateTime.now();
    if (now.difference(_lastFeed) < const Duration(milliseconds: 60)) return;
    _lastFeed = now;
    _source!.processCameraImage(image, rotationDegrees);
  }

  /// Starts countdown then capture. Safe to call again for "Try again".
  Future<void> begin() async {
    if (state.phase != PracticePhase.idle && state.phase != PracticePhase.result) return;
    _predictions.clear();
    ref.read(analyticsServiceProvider).log(AnalyticsEvents.practiceStarted);
    state = state.copyWith(phase: PracticePhase.countdown, countdown: countdownSeconds, clearResult: true, xpEarned: 0, captureProgress: 0);
    for (var n = countdownSeconds; n >= 1; n--) {
      state = state.copyWith(countdown: n);
      ref.read(hapticsServiceProvider).trigger(HapticKind.selection);
      await Future<void>.delayed(const Duration(seconds: 1));
      if (_disposed) return;
    }
    state = state.copyWith(phase: PracticePhase.capturing, captureProgress: 0);
    ref.read(hapticsServiceProvider).trigger(HapticKind.light);
    final started = DateTime.now();
    _tickTimer = Timer.periodic(AppConstants.inferenceInterval, (_) => _captureTick(started));
  }

  Future<void> _captureTick(DateTime started) async {
    if (_disposed) return;
    final elapsed = DateTime.now().difference(started);
    if (elapsed >= captureDuration) {
      _tickTimer?.cancel();
      await _finish();
      return;
    }
    state = state.copyWith(captureProgress: elapsed.inMilliseconds / captureDuration.inMilliseconds);
    if (_inFlight || !_buffer.isFull || _buffer.handPresence < AppConstants.minHandPresence) return;
    _inFlight = true;
    try {
      final p = await _engine?.predict(_buffer.toWindow());
      if (p != null) _predictions.add(p);
    } catch (e) {
      _tickTimer?.cancel();
      if (!_disposed) state = PracticeState(phase: PracticePhase.error, failure: toFailure(e));
    } finally {
      _inFlight = false;
    }
  }

  Future<void> _finish() async {
    if (_disposed || state.phase == PracticePhase.error) return;
    final prefs = ref.read(preferencesProvider);
    final result = PracticeEvaluator(threshold: prefs.confidenceThreshold).evaluate(List.of(_predictions), target: _label);
    final xp = ProgressRules.xpPerAttempt + (result.correct ? ProgressRules.xpPerCorrectPractice : 0);
    state = state.copyWith(phase: PracticePhase.result, result: result, xpEarned: xp, captureProgress: 1);
    ref.read(hapticsServiceProvider).trigger(result.correct ? HapticKind.success : HapticKind.warning);
    await ref.read(learningProvider.notifier).recordPractice(PracticeSession(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          signId: _signId,
          recognized: result.recognized,
          confidence: result.confidence,
          correct: result.correct,
          timestamp: DateTime.now(),
        ));
    ref.read(analyticsServiceProvider).log(AnalyticsEvents.practiceCompleted, {'correct': result.correct ? 1 : 0});
  }

  Future<void> retryEngine() async {
    _teardown();
    _started = false;
    await start(signId: _signId, label: _label);
  }

  void _teardown() {
    _frameTimer?.cancel();
    _tickTimer?.cancel();
    _sub?.cancel();
    _frameTimer = _tickTimer = null;
    _sub = null;
    final e = _engine;
    final s = _source;
    _engine = null;
    _source = null;
    e?.dispose();
    s?.dispose();
  }
}

final practiceProvider = NotifierProvider.autoDispose<PracticeController, PracticeState>(PracticeController.new);
