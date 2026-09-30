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
import 'local_tflite_recognition_engine.dart';
import 'remote_recognition_engine.dart';
import 'unavailable_recognition_engine.dart';

/// Which model is active and why (shown in Settings › Translation).
class ModelSelection {
  const ModelSelection(this.manifest, {this.note});
  final ModelManifest manifest;

  /// Set when a preferred model could not be used and a fallback is active.
  final String? note;
}

/// Single place that decides which model + [SignRecognitionEngine] to use.
///
/// Order: the newest model (`signovoice_model.json`, TFLite) if its labels file
/// (`signovoice_model_labels.txt`, one label per line in output order) is present and matches the
/// model's class count; otherwise the original ONNX model. A model is never used with the wrong
/// labels — that would show wrong words.
class ModelRepository {
  ModelRepository({required this.tokenProvider, AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final TokenProvider tokenProvider;
  final AssetBundle _bundle;
  ModelSelection? _selection;

  Future<Map<String, dynamic>?> _json(String name) async {
    try {
      return jsonDecode(await _bundle.loadString('assets/models/$name')) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<ModelSelection> select() async {
    if (_selection != null) return _selection!;
    String? note;
    final j = await _json('signovoice_model.json');
    if (j != null) {
      final expected = j['classes'] as int?;
      List<String> labels = const [];
      try {
        labels = LineSplitter.split(await _bundle.loadString('assets/models/${j['labelsFile']}'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } catch (_) {/* missing labels file */}
      if (labels.isNotEmpty && (expected == null || labels.length == expected)) {
        return _selection = ModelSelection(ModelManifest.fromJson(j, labels: labels));
      }
      note = labels.isEmpty
          ? 'labels file "${j['labelsFile']}" is missing'
          : 'labels file has ${labels.length} entries but the model has $expected classes';
    }
    final legacy = await _json('labels.json');
    if (legacy == null) throw const Failure(FailureType.modelUnavailable, debugDetail: 'no model manifest');
    return _selection = ModelSelection(ModelManifest.fromJson(legacy), note: note);
  }

  Future<ModelManifest> manifest() async => (await select()).manifest;

  /// Creates and initialises an engine. On failure returns
  /// [UnavailableRecognitionEngine] carrying the reason (no fake fallback).
  Future<SignRecognitionEngine> createEngine(RecognitionMode mode) async {
    try {
      final m = await manifest();
      final SignRecognitionEngine engine = switch (mode) {
        RecognitionMode.onDevice => m.engine == ModelEngineKind.tflite ? LocalTfliteRecognitionEngine(m) : LocalOnnxRecognitionEngine(m),
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
