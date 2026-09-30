import 'hand_frame.dart';
import 'sign_prediction.dart';

enum EngineStatus { uninitialized, initializing, ready, unavailable }

/// Contract every sign-recognition backend implements. The UI and pipeline
/// depend only on this, so the model can be swapped or upgraded freely
/// (ONNX today; TFLite, MediaPipe Tasks or a server later).
abstract class SignRecognitionEngine {
  /// Stable identifier for diagnostics ("local-onnx", "remote", ...).
  String get name;

  EngineStatus get status;

  /// True when inference needs a network connection.
  bool get requiresInternet;

  /// Frames per classification window.
  int get sequenceLength;

  /// Input layout (hands, preprocessing, ordering) the landmark source must produce.
  HandFeatureSpec get featureSpec;

  /// Sign labels in model-output order.
  List<String> get labels;

  /// Loads the model. Throws `Failure(modelUnavailable)` on problems.
  Future<void> initialize();

  /// Classifies a `sequenceLength × featureCount` window. Returns null when the engine
  /// cannot produce a result for this window.
  Future<SignPrediction?> predict(List<List<double>> window);

  Future<void> dispose();
}
