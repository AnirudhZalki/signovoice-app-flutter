import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../../../core/errors/failure.dart';

/// One classifier output: the most likely sign and how sure the model is.
class SignPrediction extends Equatable {
  const SignPrediction({
    required this.label,
    required this.confidence,
    this.probabilities = const {},
    this.timestamp,
  });

  final String label;

  /// 0..1 probability of [label].
  final double confidence;
  final Map<String, double> probabilities;
  final DateTime? timestamp;

  /// Gap between the best and second-best probability (1.0 when only one class is known).
  double get margin {
    if (probabilities.length < 2) return 1.0;
    final v = probabilities.values.toList()..sort((a, b) => b.compareTo(a));
    return v[0] - v[1];
  }

  /// Top-[n] alternatives, most likely first.
  List<MapEntry<String, double>> topK(int n) {
    final e = probabilities.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return e.take(n).toList();
  }

  @override
  List<Object?> get props => [label, confidence, probabilities, timestamp];
}

/// Converts raw model output into a [SignPrediction].
///
/// The shipped model ends in softmax, but this also accepts logits: values
/// that are not a valid probability distribution are soft-maxed. A length
/// mismatch with [labels] means the model and labels file are out of sync and
/// is reported as `modelUnavailable` rather than guessed at.
SignPrediction parseModelOutput(List<num> raw, List<String> labels, {DateTime? timestamp}) {
  if (raw.length != labels.length || raw.isEmpty) {
    throw Failure(FailureType.modelUnavailable,
        debugDetail: 'output length ${raw.length} != labels ${labels.length}');
  }
  var probs = [for (final v in raw) v.toDouble()];
  if (probs.any((p) => p.isNaN || p.isInfinite)) {
    throw const Failure(FailureType.modelUnavailable, debugDetail: 'non-finite output');
  }
  final sum = probs.fold<double>(0, (a, b) => a + b);
  final valid = probs.every((p) => p >= 0 && p <= 1.0000001) && (sum - 1).abs() < 1e-3;
  if (!valid) {
    final m = probs.reduce(math.max);
    final exps = [for (final p in probs) math.exp(p - m)];
    final s = exps.fold<double>(0, (a, b) => a + b);
    probs = [for (final e in exps) e / s];
  }
  var best = 0;
  for (var i = 1; i < probs.length; i++) {
    if (probs[i] > probs[best]) best = i;
  }
  return SignPrediction(
    label: labels[best],
    confidence: probs[best],
    probabilities: {for (var i = 0; i < labels.length; i++) labels[i]: probs[i]},
    timestamp: timestamp,
  );
}
