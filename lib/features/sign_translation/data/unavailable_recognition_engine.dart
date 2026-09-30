import '../../../core/errors/failure.dart';
import '../domain/hand_frame.dart';
import '../domain/recognition_engine.dart';
import '../domain/sign_prediction.dart';

/// Returned when no real engine can be created. It never fabricates output;
/// the UI shows the failure with a retry.
class UnavailableRecognitionEngine implements SignRecognitionEngine {
  UnavailableRecognitionEngine(this.failure);
  final Failure failure;

  @override
  String get name => 'unavailable';
  @override
  EngineStatus get status => EngineStatus.unavailable;
  @override
  bool get requiresInternet => false;
  @override
  List<String> get labels => const [];
  @override
  int get sequenceLength => 30;
  @override
  HandFeatureSpec get featureSpec => const HandFeatureSpec();
  @override
  Future<void> initialize() async => throw failure;
  @override
  Future<SignPrediction?> predict(List<List<double>> window) async => throw failure;
  @override
  Future<void> dispose() async {}
}
