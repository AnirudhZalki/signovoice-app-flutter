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
  /// One entry per detected hand (21 points each).
  List<List<({double x, double y})>> hands = const [];
  final StreamController<void> _c = StreamController<void>.broadcast();
  Stream<void> get changes => _c.stream;
  void set(List<List<({double x, double y})>> p) {
    hands = p;
    if (!_c.isClosed) _c.add(null);
  }

  void close() => _c.close();
}

/// MediaPipe Hand Landmarker (Android, on-device, background thread).
class MediaPipeHandLandmarkSource implements HandLandmarkSource {
  MediaPipeHandLandmarkSource({required this.spec}) {
    if (!isSupported) {
      throw const Failure(FailureType.modelUnavailable, debugDetail: 'hand landmarks unsupported on platform');
    }
    _plugin = HandLandmarkerPlugin.create(
      numHands: spec.hands,
      minHandDetectionConfidence: 0.7,
      delegate: HandLandmarkerDelegate.gpu,
    );
    _sub = _plugin.landmarkStream.listen(_onHands, onError: (Object _) {
      _controller.add(HandFrame.emptyFor(spec.featureCount));
    });
  }

  final HandFeatureSpec spec;
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
    final valid = [
      for (final h in hands)
        if (h.landmarks.length == 21) h.landmarks,
    ];
    if (valid.isEmpty) {
      _overlay.set(const []);
      _controller.add(HandFrame.emptyFor(spec.featureCount));
      return;
    }
    _overlay.set([
      for (final h in valid) [for (final l in h) (x: l.x, y: l.y)],
    ]);
    _controller.add(HandFrame.fromHands([
      for (final h in valid) [for (final l in h) (x: l.x, y: l.y, z: l.z)],
    ], spec));
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
