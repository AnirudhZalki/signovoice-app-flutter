import '../../../core/constants/app_constants.dart';
import 'gloss_processor.dart';
import 'hand_frame.dart';
import 'recognition_engine.dart';
import 'sequence_buffer.dart';
import 'sign_prediction.dart';
import 'temporal_smoother.dart';

/// Result of one inference tick.
class RecognitionUpdate {
  const RecognitionUpdate({required this.handVisible, this.raw, this.accepted});

  final bool handVisible;

  /// Latest raw model output (may be below the confidence threshold).
  final SignPrediction? raw;

  /// A new sign accepted this tick (after smoothing + duplicate suppression).
  final String? accepted;
}

/// Pure (UI-free) recognition logic: buffers frames, runs the engine and
/// applies confidence filtering + smoothing. Timers and cameras live outside
/// so this is deterministic and unit-testable.
class RecognitionSession {
  RecognitionSession({
    required this.engine,
    LandmarkSequenceBuffer? buffer,
    TemporalSmoother? smoother,
    this.glossProcessor = const GlossProcessor(),
    this.threshold = AppConstants.defaultConfidenceThreshold,
    this.minHandPresence = AppConstants.minHandPresence,
    DateTime Function()? clock,
  })  : buffer = buffer ?? LandmarkSequenceBuffer(length: AppConstants.sequenceLength),
        smoother = smoother ?? TemporalSmoother(),
        _clock = clock ?? DateTime.now;

  final SignRecognitionEngine engine;
  final LandmarkSequenceBuffer buffer;
  final TemporalSmoother smoother;
  final GlossProcessor glossProcessor;
  final DateTime Function() _clock;

  double threshold;
  final double minHandPresence;

  bool _inFlight = false;

  void pushFrame(HandFrame f) => buffer.add(f);

  /// Runs one inference. Returns null when skipped (window not full yet, or a
  /// previous inference is still running — this is what throttles the model).
  Future<RecognitionUpdate?> infer() async {
    if (_inFlight || !buffer.isFull) return null;
    final now = _clock();

    if (buffer.handPresence < minHandPresence) {
      smoother.noteNoHand(now);
      return const RecognitionUpdate(handVisible: false);
    }

    _inFlight = true;
    try {
      final prediction = await engine.predict(buffer.toWindow());
      final accepted = smoother.add(prediction, threshold: threshold, now: now);
      return RecognitionUpdate(
        handVisible: true,
        raw: prediction,
        accepted: accepted == null ? null : glossProcessor.normalize(accepted),
      );
    } finally {
      _inFlight = false;
    }
  }

  void reset() {
    buffer.clear();
    smoother.reset();
  }
}
