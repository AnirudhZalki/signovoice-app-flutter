import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class TtsVoice {
  const TtsVoice({required this.name, required this.locale});
  final String name;
  final String locale;
}

enum TtsState { idle, speaking, error }

abstract class TtsService {
  Stream<TtsState> get stateStream;
  Future<void> speak(String text, {String? language, double? rate, TtsVoice? voice});
  Future<void> stop();
  Future<List<TtsVoice>> voices();
  Future<bool> isLanguageAvailable(String language);
  Future<void> dispose();
}

/// Android's TTS engine has no true pause, so "pause" = stop and "play"
/// replays from the start (the UI exposes Play / Pause / Replay accordingly).
class FlutterTtsService implements TtsService {
  FlutterTtsService() {
    _tts.setStartHandler(() => _c.add(TtsState.speaking));
    _tts.setCompletionHandler(() => _c.add(TtsState.idle));
    _tts.setCancelHandler(() => _c.add(TtsState.idle));
    _tts.setErrorHandler((_) => _c.add(TtsState.error));
  }

  final FlutterTts _tts = FlutterTts();
  final StreamController<TtsState> _c = StreamController<TtsState>.broadcast();

  @override
  Stream<TtsState> get stateStream => _c.stream;

  @override
  Future<void> speak(String text, {String? language, double? rate, TtsVoice? voice}) async {
    if (text.trim().isEmpty) return;
    try {
      if (language != null) await _tts.setLanguage(language);
      if (voice != null) {
        await _tts.setVoice({'name': voice.name, 'locale': voice.locale});
      }
      await _tts.setSpeechRate((rate ?? 0.5).clamp(0.1, 1.0));
      await _tts.speak(text);
    } catch (_) {
      _c.add(TtsState.error);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  @override
  Future<List<TtsVoice>> voices() async {
    try {
      final raw = await _tts.getVoices as List<dynamic>?;
      return [
        for (final v in raw ?? const [])
          if (v is Map && v['name'] != null && v['locale'] != null)
            TtsVoice(name: '${v['name']}', locale: '${v['locale']}'),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<bool> isLanguageAvailable(String language) async {
    try {
      return (await _tts.isLanguageAvailable(language)) == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _c.close();
  }
}
