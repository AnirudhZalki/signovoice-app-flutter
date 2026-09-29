import 'package:equatable/equatable.dart';

/// Landmarks for one video frame in the layout the model was trained on:
/// 21 hand landmarks × (x, y, z) = 63 floats, all zeros when no hand.
class HandFrame extends Equatable {
  const HandFrame(this.features, {required this.hasHand});

  static const int featureCount = 63;

  static final HandFrame empty = HandFrame(List<double>.filled(featureCount, 0), hasHand: false);

  final List<double> features;
  final bool hasHand;

  /// Builds a frame from landmark triples. [mirrorX] flips x (1 - x) because
  /// training data was captured from a horizontally mirrored webcam feed.
  factory HandFrame.fromLandmarks(List<({double x, double y, double z})> landmarks, {bool mirrorX = true}) {
    if (landmarks.length != 21) return empty;
    final f = List<double>.filled(featureCount, 0);
    for (var i = 0; i < 21; i++) {
      final l = landmarks[i];
      f[i * 3] = mirrorX ? 1 - l.x : l.x;
      f[i * 3 + 1] = l.y;
      f[i * 3 + 2] = l.z;
    }
    return HandFrame(f, hasHand: true);
  }

  @override
  List<Object?> get props => [features, hasHand];
}
