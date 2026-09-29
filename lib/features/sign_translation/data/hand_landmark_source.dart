import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

import '../../../core/errors/failure.dart';
import '../domain/hand_frame.dart';

/// Produces [HandFrame]s from camera images. Implementations wrap a hand
/// landmark detector so the pipeline is independent of the vendor.
abstract class HandLandmarkSource {
  bool get isSupported;

  /// Emits whenever the detector reports (possibly empty hand list => [HandFrame.empty]).
  Stream<HandFrame> get frames;

  /// Latest raw landmarks (x,y in 0..1 image space) for drawing overlays.
  ValueStreamOverlay get overlay;

  void processCameraImage(CameraImage image, int sensorOrientation);
  Future<void> dispose();
}

/// Latest overlay points, without forcing a rebuild per frame.
class ValueStreamOverlay {
  List<({double x, double y})> points = const [];
  final StreamController<void> _c = StreamController<void>.broadcast();
  Stream<void> get changes => _c.stream;
  void set(List<({double x, double y})> p) {
    points = p;
    if (!_c.isClosed) _c.add(null);
  }

  void close() => _c.close();
}

/// MediaPipe Hand Landmarker (Android, on-device, background thread).
class MediaPipeHandLandmarkSource implements HandLandmarkSource {
  MediaPipeHandLandmarkSource({required this.mirrorX}) {
    if (!isSupported) {
      throw const Failure(FailureType.modelUnavailable, debugDetail: 'hand landmarks unsupported on platform');
    }
    _plugin = HandLandmarkerPlugin.create(
      numHands: 1,
      minHandDetectionConfidence: 0.7,
      delegate: HandLandmarkerDelegate.gpu,
    );
    _sub = _plugin.landmarkStream.listen(_onHands, onError: (Object _) {
      _controller.add(HandFrame.empty);
    });
  }

  final bool mirrorX;
  late final HandLandmarkerPlugin _plugin;
  StreamSubscription<List<Hand>>? _sub;
  final StreamController<HandFrame> _controller = StreamController<HandFrame>.broadcast();
  final ValueStreamOverlay _overlay = ValueStreamOverlay();

  static bool get platformSupported => Platform.isAndroid;

  @override
  bool get isSupported => platformSupported;

  @override
  Stream<HandFrame> get frames => _controller.stream;

  @override
  ValueStreamOverlay get overlay => _overlay;

  void _onHands(List<Hand> hands) {
    if (hands.isEmpty || hands.first.landmarks.length != 21) {
      _overlay.set(const []);
      _controller.add(HandFrame.empty);
      return;
    }
    final lms = hands.first.landmarks;
    _overlay.set([for (final l in lms) (x: l.x, y: l.y)]);
    _controller.add(HandFrame.fromLandmarks([for (final l in lms) (x: l.x, y: l.y, z: l.z)], mirrorX: mirrorX));
  }

  @override
  void processCameraImage(CameraImage image, int sensorOrientation) {
    try {
      _plugin.processFrame(image, sensorOrientation);
    } catch (_) {
      // A dropped frame is harmless; never crash the camera loop.
    }
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    _plugin.dispose();
    await _controller.close();
    _overlay.close();
  }
}
