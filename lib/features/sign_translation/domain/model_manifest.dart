import 'package:equatable/equatable.dart';

import '../../../core/errors/failure.dart';

/// Describes the bundled model (assets/models/labels.json). Keeping labels and
/// tensor shape in data, not code, lets the model be replaced without
/// touching the pipeline.
class ModelManifest extends Equatable {
  const ModelManifest({
    required this.version,
    required this.modelFile,
    required this.inputName,
    required this.sequenceLength,
    required this.featureCount,
    required this.labels,
  });

  final int version;
  final String modelFile;
  final String inputName;
  final int sequenceLength;
  final int featureCount;
  final List<String> labels;

  String get assetPath => 'assets/models/$modelFile';

  factory ModelManifest.fromJson(Map<String, dynamic> j) {
    final labels = (j['labels'] as List<dynamic>?)?.cast<String>() ?? const [];
    if (labels.isEmpty || j['model'] == null) {
      throw const Failure(FailureType.modelUnavailable, debugDetail: 'invalid manifest');
    }
    return ModelManifest(
      version: j['version'] as int? ?? 1,
      modelFile: j['model'] as String,
      inputName: j['inputName'] as String? ?? 'input',
      sequenceLength: j['sequenceLength'] as int? ?? 30,
      featureCount: j['featureCount'] as int? ?? 63,
      labels: labels,
    );
  }

  @override
  List<Object?> get props => [version, modelFile, inputName, sequenceLength, featureCount, labels];
}
