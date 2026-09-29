import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/errors/failure.dart';
import '../domain/speech_service.dart';

class SpeechToTextService implements SpeechService {
  SpeechToTextService([SpeechToText? stt]) : _stt = stt ?? SpeechToText();
  final SpeechToText _stt;
  bool _ready = false;
  void Function(Failure)? _onError;
  void Function()? _onDone;

  @override
  bool get isListening => _stt.isListening;

  Failure _map(SpeechRecognitionError e) {
    switch (e.errorMsg) {
      case 'error_permission':
        return const Failure(FailureType.permissionDenied, code: 'mic');
      case 'error_network':
      case 'error_network_timeout':
        return const Failure(FailureType.offline);
      case 'error_language_not_supported':
      case 'error_language_unavailable':
        return const Failure(FailureType.serviceUnavailable, code: speechUnavailableCode);
      default:
        return Failure(FailureType.unknown, debugDetail: e.errorMsg);
    }
  }

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String text, bool isFinal) onResult,
    required void Function(Failure failure) onError,
    required void Function() onDone,
  }) async {
    _onError = onError;
    _onDone = onDone;
    if (!_ready) {
      _ready = await _stt.initialize(
        onError: (e) {
          // "no match"/"speech timeout" simply mean nothing was heard.
          if (e.errorMsg == 'error_no_match' || e.errorMsg == 'error_speech_timeout') {
            _onDone?.call();
          } else {
            _onError?.call(_map(e));
          }
        },
        onStatus: (s) {
          if (s == 'done' || s == 'notListening') _onDone?.call();
        },
      );
    }
    if (!_ready) {
      throw const Failure(FailureType.serviceUnavailable, code: speechUnavailableCode);
    }
    await _stt.listen(
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Future<void> stop() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    try {
      await _stt.cancel();
    } catch (_) {}
  }
}
