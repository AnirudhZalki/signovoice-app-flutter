import 'dart:convert';

import '../../../core/errors/failure.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage.dart';
import '../domain/subscription.dart';
import '../domain/subscription_repository.dart';

/// Talks to the SignoVoice backend (`/v1/subscription*`, see
/// docs/BACKEND_CONTRACT.md). The backend verifies purchases with the Google
/// Play Developer API / App Store Server API and owns the entitlement record.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({required this.api, required this.secure});

  final ApiClient api;
  final SecureStore secure;

  String _key(String uid) => 'entitlement_$uid';

  @override
  Future<Subscription> cached(String uid) async {
    final raw = await secure.read(_key(uid));
    if (raw == null) return Subscription.free;
    try {
      return Subscription.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return Subscription.free;
    }
  }

  @override
  Future<void> writeCache(String uid, Subscription s) => secure.write(_key(uid), jsonEncode(s.toJson()));

  @override
  Future<void> clearCache(String uid) => secure.delete(_key(uid));

  Subscription _parse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const Failure(FailureType.serviceUnavailable, debugDetail: 'malformed entitlement');
    }
    return Subscription.fromJson(data);
  }

  @override
  Future<Subscription> fetch(String uid) async => _parse(await api.get('/v1/subscription'));

  @override
  Future<Subscription> verifyPurchase({
    required String productId,
    required String purchaseToken,
    required StorePlatform platform,
    String? orderId,
  }) async =>
      _parse(await api.post('/v1/subscriptions/verify', body: {
        'productId': productId,
        'purchaseToken': purchaseToken,
        'platform': platform.name,
        'orderId': ?orderId,
      }));

  @override
  Future<Subscription> cancelAutoRenew() async => _parse(await api.post('/v1/razorpay/cancel'));

  @override
  Future<Subscription> restore({required StorePlatform platform}) async =>
      _parse(await api.post('/v1/subscriptions/restore', body: {'platform': platform.name}));
}
