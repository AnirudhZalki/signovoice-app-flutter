import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/services/permission_service.dart';
import 'package:signovoice/core/services/storage.dart';
import 'package:signovoice/shared/camera/camera_session.dart';

class _Mem implements KeyValueStore {
  final m = <String, Object>{};
  @override
  int? getInt(String key) => m[key] as int?;
  @override
  Future<void> setInt(String key, int value) async => m[key] = value;
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _NoPerm implements PermissionService {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

void main() {
  test('direction fix cycles through 4 states, flips the overlay and is remembered', () async {
    final store = _Mem();
    final s = CameraSession(permissions: _NoPerm(), onImage: (a, b) {}, store: store);
    expect(s.directionFix, 0);
    expect(s.overlayMirror, isTrue); // the front camera preview is mirrored by default
    await s.cycleDirectionFix();
    expect(s.directionFix, 1);
    expect(s.overlayMirror, isTrue);
    await s.cycleDirectionFix();
    expect(s.directionFix, 2);
    expect(s.overlayMirror, isFalse);
    await s.cycleDirectionFix();
    await s.cycleDirectionFix();
    expect(s.directionFix, 0);
    expect(store.getInt('camera_direction_fix_front'), 0);
    await s.disposeSession();
  });
}
