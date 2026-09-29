import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/services/api_client.dart';
import '../../profile/domain/user_preferences.dart';
import '../domain/model_manifest.dart';
import '../domain/recognition_engine.dart';
import 'local_onnx_recognition_engine.dart';
import 'remote_recognition_engine.dart';
import 'unavailable_recognition_engine.dart';

/// Single place that decides which [SignRecognitionEngine] to use. Swapping
/// or upgrading the model = change the manifest/asset or add a new engine here.
class ModelRepository {
  ModelRepository({required this.tokenProvider, AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final TokenProvider tokenProvider;
  final AssetBundle _bundle;
  ModelManifest? _manifest;

  Future<ModelManifest> manifest() async {
    if (_manifest != null) return _manifest!;
    try {
      final raw = await _bundle.loadString('assets/models/labels.json');
      return _manifest = ModelManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      throw e is Failure ? e : const Failure(FailureType.modelUnavailable, debugDetail: 'manifest load');
    }
  }

  /// Creates and initialises an engine. On failure returns
  /// [UnavailableRecognitionEngine] carrying the reason (no fake fallback).
  Future<SignRecognitionEngine> createEngine(RecognitionMode mode) async {
    try {
      final m = await manifest();
      final SignRecognitionEngine engine = switch (mode) {
        RecognitionMode.onDevice => LocalOnnxRecognitionEngine(m),
        RecognitionMode.remote => RemoteRecognitionEngine(
            manifest: m,
            endpoint: AppConfig.remoteRecognitionUrl,
            tokenProvider: tokenProvider,
          ),
      };
      await engine.initialize();
      return engine;
    } catch (e) {
      return UnavailableRecognitionEngine(toFailure(e));
    }
  }
}
