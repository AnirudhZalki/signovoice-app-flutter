import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/features/sign_translation/domain/hand_frame.dart';
import 'package:signovoice/features/sign_translation/domain/hand_stabilizer.dart';

List<LandmarkPoint> _openHand({double dx = 0, double dy = 0}) {
  // wrist at bottom, fingers up, thumb to the side.
  final pts = <LandmarkPoint>[(x: 0.5 + dx, y: 0.9 + dy, z: 0)];
  const base = [-0.12, -0.04, 0.04, 0.12]; // knuckle x offsets for index..pinky (5, 9, 13, 17 => idx 1..4)
  pts.addAll([
    (x: 0.42 + dx, y: 0.84 + dy, z: 0), (x: 0.37 + dx, y: 0.78 + dy, z: 0), (x: 0.33 + dx, y: 0.73 + dy, z: 0), (x: 0.30 + dx, y: 0.69 + dy, z: 0),
  ]);
  for (final k in base) {
    for (var j = 0; j < 4; j++) {
      pts.add((x: 0.5 + k + dx, y: 0.7 - j * 0.09 + dy, z: 0));
    }
  }
  return pts;
}

void main() {
  test('a normal hand is plausible', () => expect(isPlausibleHand(_openHand()), isTrue));

  test('collapsed and stretched skeletons are rejected', () {
    final collapsed = [for (var i = 0; i < 21; i++) (x: 0.5, y: 0.5, z: 0.0)];
    expect(isPlausibleHand(collapsed), isFalse);
    final stretched = _openHand();
    stretched[8] = (x: 0.5, y: -3.0, z: 0);
    expect(isPlausibleHand(stretched), isFalse);
    expect(isPlausibleHand(_openHand().sublist(0, 20)), isFalse);
  });

  test('jitter is damped but a real move is followed', () {
    final s = HandStabilizer();
    var out = s.smooth([_openHand()], 0.06);
    final jitter = s.smooth([_openHand(dx: 0.004)], 0.06).first[8].x;
    expect(jitter, lessThan(_openHand(dx: 0.004)[8].x));
    for (var i = 0; i < 6; i++) {
      out = s.smooth([_openHand(dx: 0.2)], 0.06);
    }
    expect(out.first[0].x, closeTo(0.7, 0.03));
  });

  test('losing the hand resets the filter', () {
    final s = HandStabilizer();
    s.smooth([_openHand()], 0.06);
    s.smooth(const [], 0.06);
    expect(s.smooth([_openHand(dx: 0.3)], 0.06).first[0].x, closeTo(0.8, 1e-9));
  });
}
