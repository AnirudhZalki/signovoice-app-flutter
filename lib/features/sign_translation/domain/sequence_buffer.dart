import 'dart:collection';

import 'hand_frame.dart';

/// Fixed-length sliding window of [HandFrame]s (30 frames for the shipped model).
class LandmarkSequenceBuffer {
  LandmarkSequenceBuffer({this.length = 30});

  final int length;
  final Queue<HandFrame> _frames = Queue();

  void add(HandFrame f) {
    _frames.addLast(f);
    while (_frames.length > length) {
      _frames.removeFirst();
    }
  }

  bool get isFull => _frames.length == length;
  int get size => _frames.length;

  /// Fraction of frames in the window that contain a hand (0..1).
  double get handPresence =>
      _frames.isEmpty ? 0 : _frames.where((f) => f.hasHand).length / _frames.length;

  /// Number of most recent consecutive frames without a hand.
  int get trailingEmpty {
    var n = 0;
    for (final f in _frames.toList().reversed) {
      if (f.hasHand) break;
      n++;
    }
    return n;
  }

  /// Window as `length × featureCount` rows, oldest first.
  List<List<double>> toWindow() => [for (final f in _frames) f.features];

  void clear() => _frames.clear();
}
