import 'subscription.dart';

/// Source of truth is the *backend-verified* entitlement. The local cache is
/// only for offline display and is always re-evaluated against dates.
abstract class SubscriptionRepository {
  Future<Subscription> cached(String uid);
  Future<void> writeCache(String uid, Subscription s);
  Future<void> clearCache(String uid);

  /// Latest verified entitlement from the backend. Throws [Failure]
  /// (`notConfigured` when there is no backend, `offline` etc.).
  Future<Subscription> fetch(String uid);

  /// Sends a store purchase to the backend for verification and returns the
  /// resulting entitlement. The app never grants premium from a purchase
  /// event alone.
  Future<Subscription> verifyPurchase({
    required String productId,
    required String purchaseToken,
    required StorePlatform platform,
    String? orderId,
  });

  /// Restores entitlement (e.g. after reinstall) by asking the backend to
  /// re-check the store for this account.
  Future<Subscription> restore({required StorePlatform platform});
}
