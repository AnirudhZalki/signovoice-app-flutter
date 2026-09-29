import 'package:permission_handler/permission_handler.dart';

enum AppPermission { camera, microphone, notifications }

enum PermissionState { granted, denied, permanentlyDenied }

/// Permissions are requested just-in-time, only from the screen that needs
/// them, after an in-app explanation (see PermissionCard).
abstract class PermissionService {
  Future<PermissionState> status(AppPermission p);
  Future<PermissionState> request(AppPermission p);
  Future<void> openSettings();
}

class PermissionHandlerService implements PermissionService {
  Permission _map(AppPermission p) => switch (p) {
        AppPermission.camera => Permission.camera,
        AppPermission.microphone => Permission.microphone,
        AppPermission.notifications => Permission.notification,
      };

  PermissionState _state(PermissionStatus s) {
    if (s.isGranted || s.isLimited) return PermissionState.granted;
    if (s.isPermanentlyDenied || s.isRestricted) return PermissionState.permanentlyDenied;
    return PermissionState.denied;
  }

  @override
  Future<PermissionState> status(AppPermission p) async => _state(await _map(p).status);

  @override
  Future<PermissionState> request(AppPermission p) async => _state(await _map(p).request());

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
