import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/services/tts_service.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../history/domain/history_entry.dart';
import '../../history/presentation/history_controller.dart';
import '../../profile/domain/user_preferences.dart';
import '../../profile/presentation/preferences_controller.dart';
import '../../subscription/presentation/subscription_providers.dart';
import '../data/hand_landmark_source.dart';
import '../data/model_repository.dart';
import '../data/remote_translation_engine.dart';
import '../domain/gloss_processor.dart';
import '../domain/hand_frame.dart';
import '../domain/recognition_engine.dart';
import '../domain/recognition_session.dart';
import '../domain/sign_prediction.dart';
import '../domain/translation_engine.dart';

enum SignMode { signToText, signToVoice }

/// BCP-47 locale for text-to-speech for an output language code.
String ttsLocaleFor(String code) => switch (code) {
      'hi' => 'hi-IN',
      'kn' => 'kn-IN',
      _ => 'en-IN',
    };

final modelRepositoryProvider =
    Provider<ModelRepository>((ref) => ModelRepository(tokenProvider: ref.watch(authTokenProvider)));

/// Factory so tests (and future platforms) can supply a different landmark source.
final landmarkSourceFactoryProvider = Provider<HandLandmarkSource Function({required HandFeatureSpec spec})>(
  (ref) => ({required HandFeatureSpec spec}) => MediaPipeHandLandmarkSource(spec: spec),
);

final translationEngineProvider = Provider<TranslationEngine>((ref) {
  final api = ref.watch(apiClientProvider);
  return FallbackTranslationEngine(
    primary: RemoteTranslationEngine(api),
    fallback: const RuleBasedTranslationEngine(),
    usePrimary: () =>
        api.isConfigured &&
        ref.read(isPremiumProvider) &&
        (ref.read(isOnlineProvider).value ?? false) &&
        ref.read(authControllerStateIsSignedIn),
  );
});

class SignTranslationState {
  const SignTranslationState({
    this.engineStatus = EngineStatus.uninitialized,
    this.engineName = '',
    this.requiresInternet = false,
    this.failure,
    this.paused = false,
    this.handVisible = false,
    this.limitReached = false,
    this.speaking = false,
    this.current,
    this.glosses = const [],
    this.sentence = '',
    this.languageCode = 'en',
    this.signsRemaining = -1,
    this.saved = false,
  });

  final EngineStatus engineStatus;
  final String engineName;
  final bool requiresInternet;
  final Failure? failure;
  final bool paused;
  final bool handVisible;
  final bool limitReached;
  final bool speaking;
  final SignPrediction? current;
  final List<String> glosses;
  final String sentence;
  final String languageCode;

  /// Recognised signs left on the free plan today; -1 = unlimited.
  final int signsRemaining;
  final bool saved;

  bool get ready => engineStatus == EngineStatus.ready && failure == null;

  SignTranslationState copyWith({
    EngineStatus? engineStatus,
    String? engineName,
    bool? requiresInternet,
    Failure? failure,
    bool clearFailure = false,
    bool? paused,
    bool? handVisible,
    bool? limitReached,
    bool? speaking,
    SignPrediction? current,
    bool clearCurrent = false,
    List<String>? glosses,
    String? sentence,
    String? languageCode,
    int? signsRemaining,
    bool? saved,
  }) =>
      SignTranslationState(
        engineStatus: engineStatus ?? this.engineStatus,
        engineName: engineName ?? this.engineName,
        requiresInternet: requiresInternet ?? this.requiresInternet,
        failure: clearFailure ? null : (failure ?? this.failure),
        paused: paused ?? this.paused,
        handVisible: handVisible ?? this.handVisible,
        limitReached: limitReached ?? this.limitReached,
        speaking: speaking ?? this.speaking,
        current: clearCurrent ? null : (current ?? this.current),
        glosses: glosses ?? this.glosses,
        sentence: sentence ?? this.sentence,
        languageCode: languageCode ?? this.languageCode,
        signsRemaining: signsRemaining ?? this.signsRemaining,
        saved: saved ?? this.saved,
      );
}

/// Orchestrates camera frames → landmarks → engine → smoothing → gloss →
/// sentence → speech/history. Widgets only render its state.
class SignTranslationController extends Notifier<SignTranslationState> {
  SignRecognitionEngine? _engine;
  RecognitionSession? _session;
  HandLandmarkSource? _source;
  StreamSubscription<HandFrame>? _frameSub;
  StreamSubscription<TtsState>? _ttsSub;
  Timer? _frameTimer;
  Timer? _inferTimer;
  HandFrame _emptyFrame = HandFrame.empty;
  HandFrame _latest = HandFrame.empty;
  DateTime _latestAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCameraFeed = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? _startedAt;
  SignMode _mode = SignMode.signToText;
  int _translateSeq = 0;
  bool _started = false;
  bool _disposed = false;
  bool _saved = false;
  static const _processor = GlossProcessor();

  /// Overlay data for the camera preview (null until started).
  HandLandmarkSource? get source => _source;

  @override
  SignTranslationState build() {
    ref.onDispose(() {
      _disposed = true;
      _teardown();
    });
    final prefs = ref.read(preferencesProvider);
    final lang = prefs.localeCode ?? 'en';
    return SignTranslationState(languageCode: const {'en', 'hi', 'kn'}.contains(lang) ? lang : 'en');
  }

  Future<void> start(SignMode mode) async {
    if (_started) return;
    _started = true;
    _mode = mode;
    final prefs = ref.read(preferencesProvider);
    final ent = ref.read(entitlementProvider);
    final usage = ref.read(usageServiceProvider);
    state = state.copyWith(
      engineStatus: EngineStatus.initializing,
      clearFailure: true,
      paused: false,
      limitReached: usage.isLimitReached(ent.dailySignLimit),
      signsRemaining: usage.remaining(ent.dailySignLimit),
    );

    try {
      if (prefs.recognitionMode == RecognitionMode.remote && !(ref.read(isOnlineProvider).value ?? true)) {
        throw const Failure(FailureType.offline);
      }
      final engine = await ref.read(modelRepositoryProvider).createEngine(prefs.recognitionMode);
      if (_disposed) {
        await engine.dispose();
        return;
      }
      if (engine.status != EngineStatus.ready) {
        await engine.initialize(); // throws the stored failure
      }
      _engine = engine;
      _emptyFrame = HandFrame.emptyFor(engine.featureSpec.featureCount);
      _latest = _emptyFrame;
      _source = ref.read(landmarkSourceFactoryProvider)(spec: engine.featureSpec.copyWith(mirrorX: prefs.mirrorCamera));
      _session = RecognitionSession(engine: engine, threshold: prefs.confidenceThreshold);
      _frameSub = _source!.frames.listen((f) {
        _latest = f;
        _latestAt = DateTime.now();
      });
      _ttsSub = ref.read(ttsServiceProvider).stateStream.listen((s) {
        if (!_disposed) state = state.copyWith(speaking: s == TtsState.speaking);
      });
      _startTimers();
      _startedAt = DateTime.now();
      state = state.copyWith(
        engineStatus: EngineStatus.ready,
        engineName: engine.name,
        requiresInternet: engine.requiresInternet,
      );
      ref.read(analyticsServiceProvider).log(AnalyticsEvents.signTranslationStarted, {'mode': _mode.name});
    } catch (e) {
      _started = false;
      _teardown();
      if (!_disposed) {
        state = state.copyWith(engineStatus: EngineStatus.unavailable, failure: toFailure(e));
      }
    }
  }

  void _startTimers() {
    _frameTimer = Timer.periodic(AppConstants.frameInterval, (_) {
      if (state.paused || _session == null) return;
      final fresh = DateTime.now().difference(_latestAt) < const Duration(milliseconds: 250);
      _session!.pushFrame(fresh ? _latest : _emptyFrame);
    });
    _inferTimer = Timer.periodic(AppConstants.inferenceInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    final session = _session;
    if (session == null || state.paused || state.limitReached || _disposed) return;
    try {
      final u = await session.infer();
      if (u == null || _disposed) return;
      state = u.handVisible
          ? state.copyWith(handVisible: true, current: u.raw)
          : state.copyWith(handVisible: false, clearCurrent: true);
      if (u.accepted != null) await _onSign(u.accepted!);
    } catch (e) {
      // Model/service failure mid-session: stop cleanly and surface a retry.
      _teardown();
      _started = false;
      if (!_disposed) state = state.copyWith(engineStatus: EngineStatus.unavailable, failure: toFailure(e));
    }
  }

  Future<void> _onSign(String gloss) async {
    final ent = ref.read(entitlementProvider);
    final usage = ref.read(usageServiceProvider);
    if (usage.isLimitReached(ent.dailySignLimit)) {
      state = state.copyWith(limitReached: true, paused: true, signsRemaining: 0);
      return;
    }
    await usage.recordSigns();
    final glosses = _processor.append(state.glosses, gloss);
    state = state.copyWith(
      glosses: glosses,
      saved: false,
      signsRemaining: usage.remaining(ent.dailySignLimit),
      limitReached: usage.isLimitReached(ent.dailySignLimit),
    );
    _saved = false;
    ref.read(hapticsServiceProvider).trigger(HapticKind.success);
    await _retranslate();
    if (_mode == SignMode.signToVoice || ref.read(preferencesProvider).autoSpeak) {
      final r = await ref
          .read(translationEngineProvider)
          .translate([gloss.toUpperCase()], languageCode: state.languageCode);
      await _speakText(r.text);
    }
  }

  Future<void> _retranslate() async {
    final seq = ++_translateSeq;
    if (state.glosses.isEmpty) {
      state = state.copyWith(sentence: '');
      return;
    }
    try {
      final r = await ref.read(translationEngineProvider).translate(state.glosses, languageCode: state.languageCode);
      if (seq == _translateSeq && !_disposed) state = state.copyWith(sentence: r.text);
    } catch (_) {
      // Rule-based fallback never throws; keep the previous sentence otherwise.
    }
  }

  void onCameraImage(CameraImage image, int rotationDegrees) {
    if (state.paused || _source == null) return;
    final now = DateTime.now();
    if (now.difference(_lastCameraFeed) < const Duration(milliseconds: 60)) return; // ~16 fps into the detector
    _lastCameraFeed = now;
    _source!.processCameraImage(image, rotationDegrees);
  }

  void togglePause() {
    final paused = !state.paused;
    if (!paused && state.limitReached) return; // cannot resume past the free limit
    state = state.copyWith(paused: paused, handVisible: paused ? false : state.handVisible);
    if (paused) {
      ref.read(ttsServiceProvider).stop();
    } else {
      _session?.reset();
    }
  }

  void clear() {
    _translateSeq++;
    _session?.reset();
    ref.read(ttsServiceProvider).stop();
    _saved = false;
    state = state.copyWith(glosses: const [], sentence: '', clearCurrent: true, saved: false);
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    await _retranslate();
  }

  /// Speak the whole current sentence (manual Speak / Replay).
  Future<void> speak() => _speakText(state.sentence);

  Future<void> stopSpeaking() => ref.read(ttsServiceProvider).stop();

  Future<void> _speakText(String text) {
    final p = ref.read(preferencesProvider);
    final voice = (p.ttsVoiceName != null && p.ttsVoiceLocale != null)
        ? TtsVoice(name: p.ttsVoiceName!, locale: p.ttsVoiceLocale!)
        : null;
    final locale = ttsLocaleFor(state.languageCode);
    return ref.read(ttsServiceProvider).speak(
          text,
          language: locale,
          rate: p.ttsRate,
          // A saved voice only applies when it matches the output language.
          voice: (voice != null && voice.locale.toLowerCase().startsWith(state.languageCode)) ? voice : null,
        );
  }

  /// Saves the current translation to history (respecting the privacy setting).
  Future<bool> saveToHistory() async {
    if (state.glosses.isEmpty || _saved) return false;
    final saved = await ref.read(historyProvider.notifier).record(HistoryEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          inputType: _mode == SignMode.signToVoice ? HistoryInputType.signToVoice : HistoryInputType.signToText,
          glosses: state.glosses,
          text: state.sentence,
          timestamp: DateTime.now(),
          languageCode: state.languageCode,
          durationMs: _startedAt == null ? 0 : DateTime.now().difference(_startedAt!).inMilliseconds,
        ));
    if (saved) {
      _saved = true;
      state = state.copyWith(saved: true);
    }
    return saved;
  }

  /// Called when leaving the screen: persists work and reports completion.
  Future<void> finish() async {
    if (state.glosses.isNotEmpty) {
      await saveToHistory();
      ref.read(analyticsServiceProvider).log(
        AnalyticsEvents.signTranslationCompleted,
        {'signs': state.glosses.length, 'mode': _mode.name},
      );
    }
  }

  Future<void> retry() async {
    _teardown();
    _started = false;
    await start(_mode);
  }

  void _teardown() {
    _frameTimer?.cancel();
    _inferTimer?.cancel();
    _frameSub?.cancel();
    _ttsSub?.cancel();
    _frameTimer = _inferTimer = null;
    _frameSub = _ttsSub = null;
    final e = _engine;
    final s = _source;
    _engine = null;
    _source = null;
    _session = null;
    e?.dispose();
    s?.dispose();
  }
}

final signTranslationProvider =
    NotifierProvider.autoDispose<SignTranslationController, SignTranslationState>(SignTranslationController.new);
