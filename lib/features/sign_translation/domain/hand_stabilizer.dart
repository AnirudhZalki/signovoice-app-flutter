import 'dart:math' as math;

import 'hand_frame.dart';

/// True when 21 landmarks form a physically plausible hand. The detector sometimes returns a collapsed,
/// stretched or non-finite skeleton (hand at an awkward angle, motion blur); feeding that to the sign model is what
/// produces wrong words, so such frames are dropped instead of classified.
bool isPlausibleHand(List<LandmarkPoint> p) {
  if (p.length != 21) return false;
  for (final q in p) {
    if (!q.x.isFinite || !q.y.isFinite || !q.z.isFinite) return false;
  }
  double d(int a, int b) => math.sqrt(math.pow(p[a].x - p[b].x, 2) + math.pow(p[a].y - p[b].y, 2));
  final palm = d(0, 9); // wrist -> middle-finger knuckle
  if (palm < 1e-4) return false;
  const bones = <(int, int)>[
    (0, 1), (1, 2), (2, 3), (3, 4),
    (0, 5), (5, 6), (6, 7), (7, 8),
    (9, 10), (10, 11), (11, 12),
    (13, 14), (14, 15), (15, 16),
    (17, 18), (18, 19), (19, 20),
  ];
  for (final (a, b) in bones) {
    final r = d(a, b) / palm;
    if (r > 1.9) return false; // a finger segment far longer than the palm: skeleton is stretched
  }
  // Knuckles (5, 9, 13, 17) must be spread: a collapsed hand puts them on one spot.
  if (d(5, 17) / palm < 0.25) return false;
  // Whole hand must not collapse into a point either.
  if (d(0, 12) / palm < 0.35) return false;
  return true;
}

/// One-Euro filter per coordinate: removes finger jitter when the hand is still, but follows quickly when it moves,
/// so signs are not delayed. State is tracked per hand slot and reset when the hand disappears.
class HandStabilizer {
  HandStabilizer({this.minCutoff = 1.6, this.beta = 18.0, this.dCutoff = 1.0});

  final double minCutoff;
  final double beta;
  final double dCutoff;

  final Map<int, List<_Axis>> _slots = {};
  final Map<int, List<LandmarkPoint>> _lastWrists = {};

  void reset() {
    _slots.clear();
    _lastWrists.clear();
  }

  /// Smooths every hand in [hands] (index order may change between frames, so hands are matched to the
  /// nearest previous wrist). [dtSeconds] is the time since the previous frame.
  List<List<LandmarkPoint>> smooth(List<List<LandmarkPoint>> hands, double dtSeconds) {
    if (hands.isEmpty) {
      reset();
      return hands;
    }
    final dt = dtSeconds.clamp(0.005, 0.5);
    final used = <int>{};
    final out = <List<LandmarkPoint>>[];
    final newWrists = <int, List<LandmarkPoint>>{};
    for (final h in hands) {
      var slot = -1;
      var best = double.infinity;
      for (final e in _lastWrists.entries) {
        if (used.contains(e.key)) continue;
        final w = e.value.first;
        final dist = math.sqrt(math.pow(w.x - h[0].x, 2) + math.pow(w.y - h[0].y, 2));
        if (dist < best && dist < 0.35) {
          best = dist;
          slot = e.key;
        }
      }
      if (slot == -1) {
        slot = 0;
        while (used.contains(slot) || (_lastWrists.containsKey(slot) && !_slots.containsKey(slot))) {
          slot++;
        }
        _slots.remove(slot);
      }
      used.add(slot);
      final axes = _slots.putIfAbsent(slot, () => List.generate(63, (_) => _Axis()));
      final sm = <LandmarkPoint>[];
      for (var i = 0; i < 21; i++) {
        sm.add((
          x: axes[i * 3].filter(h[i].x, dt, this),
          y: axes[i * 3 + 1].filter(h[i].y, dt, this),
          z: axes[i * 3 + 2].filter(h[i].z, dt, this),
        ));
      }
      out.add(sm);
      newWrists[slot] = sm;
    }
    _slots.removeWhere((k, _) => !used.contains(k));
    _lastWrists
      ..clear()
      ..addAll(newWrists);
    return out;
  }
}

class _Axis {
  double? _x;
  double _dx = 0;

  static double _alpha(double cutoff, double dt) {
    final tau = 1 / (2 * math.pi * cutoff);
    return 1 / (1 + tau / dt);
  }

  double filter(double v, double dt, HandStabilizer c) {
    final prev = _x;
    if (prev == null) {
      _x = v;
      return v;
    }
    final rawD = (v - prev) / dt;
    _dx += _alpha(c.dCutoff, dt) * (rawD - _dx);
    final cutoff = c.minCutoff + c.beta * _dx.abs();
    final a = _alpha(cutoff, dt);
    _x = prev + a * (v - prev);
    return _x!;
  }
}
