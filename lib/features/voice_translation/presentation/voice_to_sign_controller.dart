import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/providers.dart';
import '../../dictionary/domain/text_to_sign.dart';
import '../../dictionary/presentation/dictionary_providers.dart';
import '../../history/domain/history_entry.dart';
import '../../history/presentation/history_controller.dart';
import '../../profile/presentation/preferences_controller.dart';
import '../data/speech_to_text_service.dart';
import '../domain/speech_service.dart';

final speechServiceProvider = Provider<SpeechService>((ref) {
  final s = SpeechToTextService();
  ref.onDispose(s.dispose);
  return s;
});

String speechLocaleFor(String code) => switch (code) {
      'hi' => 'hi_IN',
      'kn' => 'kn_IN',
      _ => 'en_IN',
    };

class VoiceToSignState {
  const VoiceToSignState({
    this.listening = false,
    this.transcript = '',
    this.tokens = const [],
    this.failure,
    this.languageCode = 'en',
    this.saved = false,
    this.heardNothing = false,
  });

  final bool listening;
  final String transcript;
  final List<SignToken> tokens;
  final Failure? failure;
  final String languageCode;
  final bool saved;
  final bool heardNothing;

  int get missing => tokens.where((t) => !t.hasSign).length;

  VoiceToSignState copyWith({
    bool? listening,
    String? transcript,
    List<SignToken>? tokens,
    Failure? failure,
    bool clearFailure = false,
    String? languageCode,
    bool? saved,
    bool? heardNothing,
  }) =>
      VoiceToSignState(
        listening: listening ?? this.listening,
        transcript: transcript ?? this.transcript,
        tokens: tokens ?? this.tokens,
        failure: clearFailure ? null : (failure ?? this.failure),
        languageCode: languageCode ?? this.languageCode,
        saved: saved ?? this.saved,
        heardNothing: heardNothing ?? this.heardNothing,
      );
}

class VoiceToSignController extends Notifier<VoiceToSignState> {
  DateTime? _startedAt;
  bool _disposed = false;

  @override
  VoiceToSignState build() {
    ref.onDispose(() => _disposed = true);
    final code = ref.read(preferencesProvider).localeCode ?? 'en';
    return VoiceToSignState(languageCode: const {'en', 'hi', 'kn'}.contains(code) ? code : 'en');
  }

  Future<void> toggleListening() async {
    final speech = ref.read(speechServiceProvider);
    if (state.listening) {
      await speech.stop();
      state = state.copyWith(listening: false);
      return;
    }
    state = state.copyWith(listening: true, clearFailure: true, heardNothing: false, saved: false);
    _startedAt = DateTime.now();
    ref.read(analyticsServiceProvider).log(AnalyticsEvents.voiceTranslationStarted);
    try {
      await speech.listen(
        localeId: speechLocaleFor(state.languageCode),
        onResult: (text, isFinal) => _apply(text),
        onError: (f) {
          if (!_disposed) state = state.copyWith(listening: false, failure: f);
        },
        onDone: () {
          if (_disposed) return;
          state = state.copyWith(listening: false, heardNothing: state.transcript.trim().isEmpty);
        },
      );
    } catch (e) {
      if (!_disposed) state = state.copyWith(listening: false, failure: toFailure(e));
    }
  }

  void _apply(String text) {
    if (_disposed) return;
    state = state.copyWith(transcript: text);
    _convert(text);
  }

  /// Typed/edited text path (also used after speech).
  void setText(String text) {
    state = state.copyWith(transcript: text, saved: false, heardNothing: false, clearFailure: true);
    _convert(text);
  }

  Future<void> _convert(String text) async {
    try {
      final dict = await ref.read(dictionaryProvider.future);
      if (_disposed || state.transcript != text) return;
      state = state.copyWith(tokens: TextToSignConverter(dict).convert(text));
    } catch (e) {
      if (!_disposed) state = state.copyWith(failure: toFailure(e));
    }
  }

  void setLanguage(String code) => state = state.copyWith(languageCode: code);

  Future<void> clear() async {
    await ref.read(speechServiceProvider).stop();
    state = VoiceToSignState(languageCode: state.languageCode);
  }

  Future<bool> saveToHistory() async {
    if (state.transcript.trim().isEmpty || state.saved) return false;
    final ok = await ref.read(historyProvider.notifier).record(HistoryEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          inputType: HistoryInputType.voiceToSign,
          glosses: [for (final t in state.tokens) (t.entry?.word ?? t.surface).toUpperCase()],
          text: state.transcript.trim(),
          timestamp: DateTime.now(),
          languageCode: state.languageCode,
          durationMs: _startedAt == null ? 0 : DateTime.now().difference(_startedAt!).inMilliseconds,
        ));
    if (ok) state = state.copyWith(saved: true);
    return ok;
  }
}

final voiceToSignProvider = NotifierProvider.autoDispose<VoiceToSignController, VoiceToSignState>(VoiceToSignController.new);
