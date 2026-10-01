import 'package:equatable/equatable.dart';

import '../../../core/errors/failure.dart';
import 'hand_frame.dart';

enum ModelEngineKind { onnx, tflite }

/// Describes a bundled model (`assets/models/*.json`). Labels and tensor layout live in data, not
/// code, so a new model is a file swap: input shape, hands, preprocessing and label order.
class ModelManifest extends Equatable {
  const ModelManifest({
    this.id = 'model',
    required this.version,
    required this.modelFile,
    required this.inputName,
    required this.sequenceLength,
    required this.featureCount,
    required this.labels,
    this.engine = ModelEngineKind.onnx,
    this.hands = 1,
    this.preprocess = FeaturePreprocess.raw,
    this.handOrder = HandOrder.imageXAscending,
    this.mirrorX,
  });

  final String id;
  final int version;
  final String modelFile;
  final String inputName;
  final int sequenceLength;
  final int featureCount;
  final List<String> labels;
  final ModelEngineKind engine;
  final int hands;
  final FeaturePreprocess preprocess;
  final HandOrder handOrder;

  /// When set, the model needs exactly this x-mirroring (the user's mirror setting is ignored).
  final bool? mirrorX;

  String get assetPath => 'assets/models/$modelFile';

  HandFeatureSpec get spec => mirrorX == null
      ? HandFeatureSpec(hands: hands, preprocess: preprocess, order: handOrder)
      : HandFeatureSpec(hands: hands, preprocess: preprocess, order: handOrder, mirrorX: mirrorX!, lockMirror: true);

  /// [labels] may be supplied separately (a `labelsFile`), otherwise they come from the JSON.
  factory ModelManifest.fromJson(Map<String, dynamic> j, {List<String>? labels}) {
    final l = labels ?? (j['labels'] as List<dynamic>?)?.cast<String>() ?? const [];
    if (l.isEmpty || j['model'] == null) {
      throw const Failure(FailureType.modelUnavailable, debugDetail: 'invalid manifest');
    }
    T e<T extends Enum>(List<T> v, Object? n, T d) => v.firstWhere((x) => x.name == n, orElse: () => d);
    final hands = j['hands'] as int? ?? 1;
    return ModelManifest(
      id: j['id'] as String? ?? 'model',
      version: j['version'] as int? ?? 1,
      modelFile: j['model'] as String,
      inputName: j['inputName'] as String? ?? 'input',
      sequenceLength: j['sequenceLength'] as int? ?? 30,
      featureCount: j['featureCount'] as int? ?? hands * HandFrame.perHand,
      labels: l,
      engine: e(ModelEngineKind.values, j['engine'], ModelEngineKind.onnx),
      hands: hands,
      preprocess: e(FeaturePreprocess.values, j['preprocess'], FeaturePreprocess.raw),
      handOrder: e(HandOrder.values, j['handOrder'], HandOrder.imageXAscending),
      mirrorX: j['mirrorX'] as bool?,
    );
  }

  @override
  List<Object?> get props =>
      [id, version, modelFile, inputName, sequenceLength, featureCount, labels, engine, hands, preprocess, handOrder, mirrorX];
}
