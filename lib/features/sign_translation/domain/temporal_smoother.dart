import 'sign_prediction.dart';

/// Turns a noisy stream of per-window predictions into stable, de-duplicated
/// sign events.
///
/// * A sign is accepted when [minVotes] of the last [windowSize] predictions
///   agree and each vote met the confidence threshold.
/// * The same sign is not accepted twice in a row until the hand has left the
///   frame for [repeatGap] (duplicate suppression).
class TemporalSmoother {
  TemporalSmoother({this.windowSize = 3, this.minVotes = 2, this.repeatGap = const Duration(milliseconds: 700)})
      : assert(minVotes <= windowSize);

  final int windowSize;
  final int minVotes;
  final Duration repeatGap;

  final List<String?> _recent = [];
  String? _lastAccepted;
  DateTime? _noHandSince;

  String? get lastAccepted => _lastAccepted;

  /// Call on ticks where no hand is visible.
  void noteNoHand(DateTime now) {
    _noHandSince ??= now;
    if (now.difference(_noHandSince!) >= repeatGap) {
      _lastAccepted = null;
      _recent.clear();
    }
  }

  /// Returns the newly accepted label, or null.
  String? add(SignPrediction? p, {required double threshold, required DateTime now}) {
    if (p == null) {
      noteNoHand(now);
      return null;
    }
    _noHandSince = null;
    _recent.add(p.confidence >= threshold ? p.label : null);
    if (_recent.length > windowSize) _recent.removeAt(0);

    final counts = <String, int>{};
    for (final l in _recent) {
      if (l != null) counts[l] = (counts[l] ?? 0) + 1;
    }
    for (final e in counts.entries) {
      if (e.value >= minVotes) {
        if (e.key == _lastAccepted) return null; // duplicate suppression
        _lastAccepted = e.key;
        _recent.clear();
        return e.key;
      }
    }
    return null;
  }

  void reset() {
    _recent.clear();
    _lastAccepted = null;
    _noHandSince = null;
  }
}
