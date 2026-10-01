import 'dart:math' as math;

import 'package:equatable/equatable.dart';

typedef LandmarkPoint = ({double x, double y, double z});

/// How raw landmark coordinates are turned into model features.
enum FeaturePreprocess {
  /// Normalised image coordinates exactly as the detector reports them.
  raw,

  /// Each hand minus its own wrist (landmark 0): position independent.
  wristRelative,

  /// Wrist-relative, then divided by the hand's largest extent: position and size independent.
  normalized,
}

/// Which feature slot a detected hand goes into when the model expects two hands.
enum HandOrder {
  /// Smaller wrist x first (after mirroring). In a mirrored selfie view that is the person's left hand.
  imageXAscending,
  imageXDescending,

  /// Detector order.
  detected,
}

/// Everything that defines the model's input layout. Comes from the model manifest, so a new model
/// with a different layout needs a JSON change, not a code change.
class HandFeatureSpec extends Equatable {
  const HandFeatureSpec({
    this.hands = 1,
    this.preprocess = FeaturePreprocess.raw,
    this.order = HandOrder.imageXAscending,
    this.mirrorX = true,
    this.lockMirror = false,
  });

  final int hands;
  final FeaturePreprocess preprocess;
  final HandOrder order;

  /// Flip x (1 - x) — the original model was trained on a mirrored webcam feed.
  final bool mirrorX;

  /// The model was trained with a fixed mirroring, so the user setting must not override it.
  final bool lockMirror;

  int get featureCount => hands * HandFrame.perHand;

  HandFeatureSpec copyWith({bool? mirrorX}) => HandFeatureSpec(
      hands: hands,
      preprocess: preprocess,
      order: order,
      mirrorX: lockMirror ? this.mirrorX : (mirrorX ?? this.mirrorX),
      lockMirror: lockMirror);

  @override
  List<Object?> get props => [hands, preprocess, order, mirrorX, lockMirror];
}

/// Landmarks for one video frame: `hands × 21 × (x, y, z)` floats, zeros for missing hands.
class HandFrame extends Equatable {
  const HandFrame(this.features, {required this.hasHand});

  static const int perHand = 63;
  static const int featureCount = perHand;

  /// One-hand empty frame (legacy model).
  static final HandFrame empty = HandFrame(List<double>.filled(featureCount, 0), hasHand: false);

  /// Empty frame for any feature count.
  factory HandFrame.emptyFor(int features) =>
      features == perHand ? empty : HandFrame(List<double>.filled(features, 0), hasHand: false);

  final List<double> features;
  final bool hasHand;

  /// Single-hand frame (legacy API): mirrors x when [mirrorX].
  factory HandFrame.fromLandmarks(List<LandmarkPoint> landmarks, {bool mirrorX = true}) =>
      HandFrame.fromHands([landmarks], const HandFeatureSpec(), mirrorXOverride: mirrorX);

  /// Builds a frame from every detected hand according to [spec].
  factory HandFrame.fromHands(List<List<LandmarkPoint>> detected, HandFeatureSpec spec, {bool? mirrorXOverride}) {
    final mirror = mirrorXOverride ?? spec.mirrorX;
    final valid = [
      for (final h in detected)
        if (h.length == 21) [for (final p in h) (x: mirror ? 1 - p.x : p.x, y: p.y, z: p.z)],
    ];
    if (valid.isEmpty) return HandFrame.emptyFor(spec.featureCount);

    var hands = valid.take(spec.hands).toList();
    switch (spec.order) {
      case HandOrder.imageXAscending:
        hands.sort((a, b) => a[0].x.compareTo(b[0].x));
      case HandOrder.imageXDescending:
        hands.sort((a, b) => b[0].x.compareTo(a[0].x));
      case HandOrder.detected:
        break;
    }

    final f = List<double>.filled(spec.featureCount, 0);
    // Two-hand model, one visible hand: put it on the side of the image it appears on.
    var start = 0;
    if (spec.hands == 2 && hands.length == 1 && spec.order != HandOrder.detected) {
      final leftSide = hands.first[0].x < 0.5;
      final firstSlot = spec.order == HandOrder.imageXAscending ? leftSide : !leftSide;
      start = firstSlot ? 0 : 1;
    }
    for (var h = 0; h < hands.length; h++) {
      final slot = (start + h) * perHand;
      final pts = _preprocess(hands[h], spec.preprocess);
      for (var i = 0; i < 21; i++) {
        f[slot + i * 3] = pts[i].x;
        f[slot + i * 3 + 1] = pts[i].y;
        f[slot + i * 3 + 2] = pts[i].z;
      }
    }
    return HandFrame(f, hasHand: true);
  }

  static List<LandmarkPoint> _preprocess(List<LandmarkPoint> p, FeaturePreprocess mode) {
    if (mode == FeaturePreprocess.raw) return p;
    final w = p[0];
    final rel = [for (final q in p) (x: q.x - w.x, y: q.y - w.y, z: q.z - w.z)];
    if (mode == FeaturePreprocess.wristRelative) return rel;
    var m = 0.0;
    for (final q in rel) {
      m = math.max(m, math.max(q.x.abs(), math.max(q.y.abs(), q.z.abs())));
    }
    if (m < 1e-6) return rel;
    return [for (final q in rel) (x: q.x / m, y: q.y / m, z: q.z / m)];
  }

  @override
  List<Object?> get props => [features, hasHand];
}
