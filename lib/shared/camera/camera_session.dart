import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/permission_service.dart';

enum CameraStatus { checkingPermission, needsPermission, permanentlyDenied, initializing, ready, error }

/// Owns a [CameraController]: permission flow, init, image stream, flip, flash
/// and app-lifecycle release. Always call [disposeSession].
class CameraSession extends ChangeNotifier {
  CameraSession({
    required this.permissions,
    required this.onImage,
    this.initialDirection = CameraLensDirection.front,
  }) : direction = initialDirection;

  final PermissionService permissions;
  final void Function(CameraImage image, int sensorOrientation) onImage;
  final CameraLensDirection initialDirection;

  CameraController? controller;
  CameraStatus status = CameraStatus.checkingPermission;
  CameraLensDirection direction;
  bool flashOn = false;
  bool _disposed = false;
  bool _busy = false;

  bool get isFront => direction == CameraLensDirection.front;
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
      final c = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await c.initialize();
      if (_disposed) {
        await c.dispose();
        return;
      }
      await c.startImageStream((image) => onImage(image, cam.sensorOrientation));
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
    super.dispose();
  }
}
