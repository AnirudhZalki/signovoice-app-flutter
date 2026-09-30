import 'package:flutter_litert/flutter_litert.dart';

import '../../../core/errors/failure.dart';
import '../domain/hand_frame.dart';
import '../domain/model_manifest.dart';
import '../domain/recognition_engine.dart';
import '../domain/sign_prediction.dart';

/// On-device inference of a bundled `.tflite` model with LiteRT (TensorFlow Lite).
/// Input `[1, sequenceLength, featureCount]` float32, output `[1, classes]`. The shapes are
/// checked against the manifest at load time, so a model/labels mismatch is reported clearly
/// instead of producing wrong words.
class LocalTfliteRecognitionEngine implements SignRecognitionEngine {
  LocalTfliteRecognitionEngine(this.manifest);

  final ModelManifest manifest;
  Interpreter? _interpreter;
  EngineStatus _status = EngineStatus.uninitialized;

  @override
  String get name => 'local-tflite';
  @override
  EngineStatus get status => _status;
  @override
  bool get requiresInternet => false;
  @override
  List<String> get labels => manifest.labels;
  @override
  int get sequenceLength => manifest.sequenceLength;
  @override
  HandFeatureSpec get featureSpec => manifest.spec;

  @override
  Future<void> initialize() async {
    if (_status == EngineStatus.ready) return;
    _status = EngineStatus.initializing;
    try {
      final options = InterpreterOptions()..threads = 2;
      final it = await Interpreter.fromAsset(manifest.assetPath, options: options);
      final inShape = it.getInputTensors().first.shape;
      final outShape = it.getOutputTensors().first.shape;
      final ok = inShape.length == 3 &&
          inShape[1] == manifest.sequenceLength &&
          inShape[2] == manifest.featureCount &&
          outShape.length == 2 &&
          outShape[1] == manifest.labels.length;
      if (!ok) {
        it.close();
        throw Failure(FailureType.modelUnavailable,
            debugDetail: 'shape mismatch in=$inShape out=$outShape labels=${manifest.labels.length}');
      }
      _interpreter = it;
      _status = EngineStatus.ready;
    } catch (e) {
      _status = EngineStatus.unavailable;
      throw e is Failure ? e : Failure(FailureType.modelUnavailable, debugDetail: 'tflite init: ${e.runtimeType}');
    }
  }

  @override
  Future<SignPrediction?> predict(List<List<double>> window) async {
    final it = _interpreter;
    if (it == null || _status != EngineStatus.ready) {
      throw const Failure(FailureType.modelUnavailable, debugDetail: 'predict before initialize');
    }
    if (window.length != manifest.sequenceLength || window.any((r) => r.length != manifest.featureCount)) {
      throw const Failure(FailureType.modelUnavailable, debugDetail: 'bad window shape');
    }
    try {
      final input = [window];
      final output = [List<double>.filled(manifest.labels.length, 0)];
      it.run(input, output);
      return parseModelOutput(output.first, manifest.labels, timestamp: DateTime.now());
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(FailureType.modelUnavailable, debugDetail: 'tflite run: ${e.runtimeType}');
    }
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _status = EngineStatus.uninitialized;
  }
}
