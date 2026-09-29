import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Future<bool> get isOnline;
  Stream<bool> get onlineStream;
}

class PlusConnectivityService implements ConnectivityService {
  PlusConnectivityService([Connectivity? c]) : _c = c ?? Connectivity();
  final Connectivity _c;

  static bool _online(List<ConnectivityResult> r) =>
      r.any((e) => e != ConnectivityResult.none);

  @override
  Future<bool> get isOnline async => _online(await _c.checkConnectivity());

  @override
  Stream<bool> get onlineStream => _c.onConnectivityChanged.map(_online).distinct();
}
