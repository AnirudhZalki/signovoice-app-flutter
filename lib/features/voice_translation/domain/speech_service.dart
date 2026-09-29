import '../../../core/errors/failure.dart';

/// Speech-to-text contract. The default implementation uses the device's
/// speech recogniser (may use the network depending on device/language).
abstract class SpeechService {
  bool get isListening;

  /// Starts listening. [onResult] gets partial and final text; [onDone] fires
  /// when listening ends (silence, stop or error).
  Future<void> listen({
    required String localeId,
    required void Function(String text, bool isFinal) onResult,
    required void Function(Failure failure) onError,
    required void Function() onDone,
  });

  Future<void> stop();
  Future<void> dispose();
}

/// Failure code used when the recogniser isn't available on the device.
const speechUnavailableCode = 'speech-unavailable';
