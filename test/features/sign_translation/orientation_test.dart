import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/features/sign_translation/domain/hand_frame.dart';
import 'package:signovoice/shared/camera/camera_session.dart';

void main() {
  group('camera rotation follows the phone orientation', () {
    int r(int sensor, bool front, DeviceOrientation d) => cameraRotationDegrees(sensorOrientation: sensor, front: front, device: d);
    test('portrait uses the sensor orientation (unchanged behaviour)', () {
      expect(r(270, true, DeviceOrientation.portraitUp), 270);
      expect(r(90, false, DeviceOrientation.portraitUp), 90);
    });
    test('landscape: raw frames are already upright for the front camera, and for the back camera', () {
      expect(r(270, true, DeviceOrientation.landscapeLeft), 0);
      expect(r(270, true, DeviceOrientation.landscapeRight), 180);
      expect(r(90, false, DeviceOrientation.landscapeLeft), 0);
      expect(r(90, false, DeviceOrientation.landscapeRight), 180);
    });
  });

  group('landscape canvas (training-data geometry)', () {
    LandmarkPoint pt(double x, double y) => (x: x, y: y, z: 0.0);

    test('landscape frames are untouched', () {
      final out = toLandscapeCanvas([pt(0.3, 0.7)], frameWidth: 640, frameHeight: 480);
      expect((out[0].x, out[0].y), (0.3, 0.7));
    });

    test('portrait: centre stays the centre, shapes keep real proportions', () {
      final c = toLandscapeCanvas([pt(0.5, 0.5)], frameWidth: 480, frameHeight: 640).single;
      expect(c.x, closeTo(0.5, 1e-9));
      expect(c.y, closeTo(0.5, 1e-9));
      // Two points 100 px apart horizontally and 100 px apart vertically stay equally far apart (isotropic).
      final a = toLandscapeCanvas([pt(0.5, 0.5), pt(0.5 + 100 / 480, 0.5), pt(0.5, 0.5 + 100 / 640)], frameWidth: 480, frameHeight: 640);
      final dx = (a[1].x - a[0].x) * 640; // canvas is 640 wide, 480 tall
      final dy = (a[2].y - a[0].y) * 480;
      expect(dx, closeTo(100, 1e-6));
      expect(dy, closeTo(100, 1e-6));
    });

    test('a vertical downward motion stays vertical and downward', () {
      final a = toLandscapeCanvas([pt(0.5, 0.3), pt(0.5, 0.7)], frameWidth: 480, frameHeight: 640);
      expect(a[0].x, closeTo(a[1].x, 1e-9));
      expect(a[1].y, greaterThan(a[0].y));
    });
  });
}
