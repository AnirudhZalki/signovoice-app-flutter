import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

import '../../../core/errors/failure.dart';
import '../domain/model_manifest.dart';
import '../domain/recognition_engine.dart';
import '../domain/sign_prediction.dart';

/// On-device inference of the bundled LSTM (`assets/models/*.onnx`) with ONNX
/// Runtime. Input `[1, 30, 63]` float32; output `[1, N]` probabilities.
///
/// Camera frames never reach this class — only 63 numbers per frame.
class LocalOnnxRecognitionEngine implements SignRecognitionEngine {
  LocalOnnxRecognitionEngine(this.manifest, {OnnxRuntime? runtime}) : _ort = runtime ?? OnnxRuntime();

  final ModelManifest manifest;
  final OnnxRuntime _ort;
  OrtSession? _session;
  EngineStatus _status = EngineStatus.uninitialized;

  @override
  String get name => 'local-onnx';
  @override
  EngineStatus get status => _status;
  @override
  bool get requiresInternet => false;
  @override
  List<String> get labels => manifest.labels;

  @override
  Future<void> initialize() async {
    if (_status == EngineStatus.ready) return;
    _status = EngineStatus.initializing;
    try {
      _session = await _ort.createSessionFromAsset(manifest.assetPath);
      _status = EngineStatus.ready;
    } catch (e) {
      _status = EngineStatus.unavailable;
      throw Failure(FailureType.modelUnavailable, debugDetail: 'onnx init: ${e.runtimeType}');
    }
  }

  @override
  Future<SignPrediction?> predict(List<List<double>> window) async {
    final session = _session;
    if (session == null || _status != EngineStatus.ready) {
      throw const Failure(FailureType.modelUnavailable, debugDetail: 'predict before initialize');
    }
    if (window.length != manifest.sequenceLength || window.any((r) => r.length != manifest.featureCount)) {
      throw Failure(FailureType.modelUnavailable, debugDetail: 'bad window shape');
    }
    final flat = Float32List(manifest.sequenceLength * manifest.featureCount);
    var i = 0;
    for (final row in window) {
      for (final v in row) {
        flat[i++] = v;
      }
    }

    OrtValue? input;
    Map<String, OrtValue>? outputs;
    try {
      input = await OrtValue.fromList(flat, [1, manifest.sequenceLength, manifest.featureCount]);
      outputs = await session.run({manifest.inputName: input});
      final out = outputs.values.first;
      final raw = await out.asFlattenedList();
      return parseModelOutput(raw.cast<num>(), manifest.labels, timestamp: DateTime.now());
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(FailureType.modelUnavailable, debugDetail: 'onnx run: ${e.runtimeType}');
    } finally {
      await input?.dispose();
      if (outputs != null) {
        for (final t in outputs.values) {
          await t.dispose();
        }
      }
    }
  }

  @override
  Future<void> dispose() async {
    final s = _session;
    _session = null;
    _status = EngineStatus.uninitialized;
    await s?.close();
  }
}
