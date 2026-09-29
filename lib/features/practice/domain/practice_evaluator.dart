import 'package:equatable/equatable.dart';

import '../../sign_translation/domain/sign_prediction.dart';

class PracticeResult extends Equatable {
  const PracticeResult({required this.recognized, required this.confidence, required this.correct, required this.noHand});

  /// Most convincing label observed (null if no hand/predictions).
  final String? recognized;

  /// Mean confidence of [recognized] over the capture window (0..1).
  final double confidence;
  final bool correct;
  final bool noHand;

  @override
  List<Object?> get props => [recognized, confidence, correct, noHand];
}

/// Decides whether a practice attempt matches the requested sign.
///
/// Uses all predictions from the capture window: each label's evidence is its
/// summed confidence; the winner's *mean* confidence is reported. Correct only
/// if the winner is the target and meets [threshold].
class PracticeEvaluator {
  const PracticeEvaluator({this.threshold = 0.7, this.minPredictions = 2});
  final double threshold;
  final int minPredictions;

  PracticeResult evaluate(List<SignPrediction> predictions, {required String target}) {
    if (predictions.length < minPredictions) {
      return const PracticeResult(recognized: null, confidence: 0, correct: false, noHand: true);
    }
    final sum = <String, double>{};
    final count = <String, int>{};
    for (final p in predictions) {
      sum[p.label] = (sum[p.label] ?? 0) + p.confidence;
      count[p.label] = (count[p.label] ?? 0) + 1;
    }
    final winner = sum.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final mean = sum[winner]! / count[winner]!;
    final correct = winner.toLowerCase() == target.toLowerCase() && mean >= threshold;
    return PracticeResult(recognized: winner, confidence: mean, correct: correct, noHand: false);
  }
}
