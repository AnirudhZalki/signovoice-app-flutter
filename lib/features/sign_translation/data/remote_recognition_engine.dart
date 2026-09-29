import 'package:dio/dio.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/services/api_client.dart';
import '../domain/model_manifest.dart';
import '../domain/recognition_engine.dart';
import '../domain/sign_prediction.dart';

/// Server-side inference. Sends only landmark coordinates (30×63 numbers),
/// never camera images. Contract: docs/BACKEND_CONTRACT.md → POST /recognize.
class RemoteRecognitionEngine implements SignRecognitionEngine {
  RemoteRecognitionEngine({
    required this.manifest,
    required this.endpoint,
    required this.tokenProvider,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final ModelManifest manifest;
  final String endpoint;
  final TokenProvider tokenProvider;
  final Dio _dio;
  EngineStatus _status = EngineStatus.uninitialized;

  @override
  String get name => 'remote';
  @override
  EngineStatus get status => _status;
  @override
  bool get requiresInternet => true;
  @override
  List<String> get labels => manifest.labels;

  @override
  Future<void> initialize() async {
    if (!endpoint.startsWith('https://')) {
      _status = EngineStatus.unavailable;
      throw const Failure(FailureType.notConfigured, debugDetail: 'REMOTE_RECOGNITION_URL');
    }
    _status = EngineStatus.ready;
  }

  @override
  Future<SignPrediction?> predict(List<List<double>> window) async {
    if (_status != EngineStatus.ready) throw const Failure(FailureType.modelUnavailable);
    try {
      final token = await tokenProvider();
      final res = await _dio.post<dynamic>(
        endpoint,
        data: {'landmarks': window, 'modelVersion': manifest.version},
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final data = res.data as Map<String, dynamic>;
      final probs = (data['probabilities'] as List<dynamic>?)?.cast<num>();
      if (probs != null) return parseModelOutput(probs, manifest.labels, timestamp: DateTime.now());
      final label = data['label'] as String?;
      final conf = (data['confidence'] as num?)?.toDouble();
      if (label == null || conf == null) {
        throw const Failure(FailureType.modelUnavailable, debugDetail: 'malformed response');
      }
      return SignPrediction(label: label, confidence: conf.clamp(0, 1).toDouble(), timestamp: DateTime.now());
    } on Failure {
      rethrow;
    } catch (e) {
      throw toFailure(e);
    }
  }

  @override
  Future<void> dispose() async {
    _dio.close();
    _status = EngineStatus.uninitialized;
  }
}
