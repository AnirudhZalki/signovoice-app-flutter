import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;

import '../../core/services/permission_service.dart';
import '../../core/services/storage.dart';

/// Clockwise degrees to rotate a raw camera frame so it is upright for the current phone orientation
/// (same rule as CameraX / Android docs): front = sensor + device, back = sensor - device.
/// Passing only the sensor orientation is right in portrait but wrong in landscape.
int cameraRotationDegrees({required int sensorOrientation, required bool front, required DeviceOrientation device}) {
  final dev = switch (device) {
    DeviceOrientation.portraitUp => 0,
    DeviceOrientation.landscapeLeft => 90,
    DeviceOrientation.portraitDown => 180,
    DeviceOrientation.landscapeRight => 270,
  };
  return front ? (sensorOrientation + dev) % 360 : (sensorOrientation - dev + 360) % 360;
}

enum CameraStatus { checkingPermission, needsPermission, permanentlyDenied, initializing, ready, error }

/// Owns a [CameraController]: permission flow, init, image stream, flip, flash
/// and app-lifecycle release. Always call [disposeSession].
class CameraSession extends ChangeNotifier {
  CameraSession({
    required this.permissions,
    required this.onImage,
    this.initialDirection = CameraLensDirection.front,
    this.store,
  }) : direction = initialDirection;

  /// Remembers the skeleton-direction fix per camera (see [cycleDirectionFix]).
  final KeyValueStore? store;

  final PermissionService permissions;
  /// Called for every frame with the clockwise rotation (degrees) that makes it upright.
  final void Function(CameraImage image, int rotationDegrees) onImage;
  final CameraLensDirection initialDirection;

  CameraController? controller;
  CameraStatus status = CameraStatus.checkingPermission;
  CameraLensDirection direction;
  bool flashOn = false;
  bool _disposed = false;
  bool _busy = false;

  bool get isFront => direction == CameraLensDirection.front;

  /// Manual correction for devices whose hand skeleton comes out upside down or mirrored:
  /// bit 0 = rotate the frames sent to the detector by 180°, bit 1 = mirror the drawn skeleton.
  int directionFix = 0;

  bool get overlayMirror => isFront != ((directionFix & 2) != 0);

  String get _fixKey => 'camera_direction_fix_${direction.name}';

  void _loadFix() => directionFix = (store?.getInt(_fixKey) ?? 0) & 3;

  /// Steps through the four fixes (normal, upside down, mirrored, both) and remembers the choice.
  Future<void> cycleDirectionFix() async {
    directionFix = (directionFix + 1) & 3;
    notifyListeners();
    await store?.setInt(_fixKey, directionFix);
  }

  int _rotationFor(CameraDescription cam, DeviceOrientation d) {
    final base = cameraRotationDegrees(sensorOrientation: cam.sensorOrientation, front: cam.lensDirection == CameraLensDirection.front, device: d);
    return (directionFix & 1) != 0 ? (base + 180) % 360 : base;
  }
  bool get canFlash => direction == CameraLensDirection.back && status == CameraStatus.ready;

  void _set(CameraStatus s) {
    status = s;
    if (!_disposed) notifyListeners();
  }

  Future<void> start() async {
    _set(CameraStatus.checkingPermission);
    final st = await permissions.status(AppPermission.camera);
    switch (st) {
      case PermissionState.granted:
        await _init();
      case PermissionState.denied:
        _set(CameraStatus.needsPermission);
      case PermissionState.permanentlyDenied:
        _set(CameraStatus.permanentlyDenied);
    }
  }

  Future<void> requestPermission() async {
    final st = await permissions.request(AppPermission.camera);
    switch (st) {
      case PermissionState.granted:
        await _init();
      case PermissionState.denied:
        _set(CameraStatus.needsPermission);
      case PermissionState.permanentlyDenied:
        _set(CameraStatus.permanentlyDenied);
    }
  }

  Future<void> openSettings() => permissions.openSettings();

  Future<void> _init() async {
    if (_busy || _disposed) return;
    _busy = true;
    _set(CameraStatus.initializing);
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw CameraException('noCamera', 'No camera available');
      final cam = cams.firstWhere((c) => c.lensDirection == direction, orElse: () => cams.first);
      direction = cam.lensDirection;
      _loadFix();
      final c = CameraController(
        cam,
        ResolutionPreset.high, // 720p: finger detail matters for landmark accuracy
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await c.initialize();
      // The screen and the preview stay portrait while the camera is open; the frames sent to the hand detector are
      // rotated for that same portrait view. Following the physical phone angle instead made the detected skeleton
      // point a different way from the hand shown on screen.
      try {
        await SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
        await c.lockCaptureOrientation(DeviceOrientation.portraitUp);
      } catch (_) {/* not supported on this device: rotation below still uses portrait */}
      if (_disposed) {
        await c.dispose();
        return;
      }
      await c.startImageStream((image) => onImage(image, _rotationFor(cam, DeviceOrientation.portraitUp)));
      controller = c;
      flashOn = false;
      _set(CameraStatus.ready);
    } on CameraException catch (e) {
      final denied = e.code == 'CameraAccessDenied' || e.code == 'CameraAccessDeniedWithoutPrompt';
      _set(denied ? CameraStatus.needsPermission : CameraStatus.error);
    } catch (_) {
      _set(CameraStatus.error);
    } finally {
      _busy = false;
    }
  }

  Future<void> _release() async {
    final c = controller;
    controller = null;
    if (c == null) return;
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
    } catch (_) {}
    try {
      await c.dispose();
    } catch (_) {}
  }

  Future<void> flip() async {
    direction = isFront ? CameraLensDirection.back : CameraLensDirection.front;
    _set(CameraStatus.initializing);
    await _release();
    await _init();
  }

  Future<void> toggleFlash() async {
    final c = controller;
    if (c == null || !canFlash) return;
    try {
      await c.setFlashMode(flashOn ? FlashMode.off : FlashMode.torch);
      flashOn = !flashOn;
      notifyListeners();
    } catch (_) {/* flash unsupported: ignore */}
  }

  /// App went to background: release the camera hardware.
  Future<void> pause() async {
    if (status == CameraStatus.ready) {
      await _release();
      _set(CameraStatus.initializing);
    }
  }

  Future<void> resume() async {
    if (controller == null && !_disposed && status == CameraStatus.initializing) await _init();
  }

  Future<void> disposeSession() async {
    _disposed = true;
    await _release();
    try {
      await SystemChrome.setPreferredOrientations(const []);
    } catch (_) {}
    super.dispose();
  }
}
