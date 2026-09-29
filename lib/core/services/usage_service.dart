import '../constants/app_constants.dart';
import '../utils/date_utils.dart';
import 'storage.dart';

/// Per-day counter of recognised signs, used for the free plan's daily limit.
/// Stored locally; the limit is a product nudge, not a security boundary.
class UsageService {
  UsageService(this._kv, this._clock);
  final KeyValueStore _kv;
  final DateTime Function() _clock;

  String get _key => '${PrefKeys.usagePrefix}signs_${dayKey(_clock())}';

  int get signsToday => _kv.getInt(_key) ?? 0;

  Future<int> recordSigns([int n = 1]) async {
    final v = signsToday + n;
    await _kv.setInt(_key, v);
    return v;
  }

  /// [limit] < 0 = unlimited.
  bool isLimitReached(int limit) => limit >= 0 && signsToday >= limit;
  int remaining(int limit) => limit < 0 ? -1 : (limit - signsToday).clamp(0, limit);
}
