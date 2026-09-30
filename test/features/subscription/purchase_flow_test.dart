import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/errors/failure.dart';
import 'package:signovoice/core/providers.dart';
import 'package:signovoice/core/services/analytics_service.dart';
import 'package:signovoice/core/services/storage.dart';
import 'package:signovoice/features/auth/domain/app_user.dart';
import 'package:signovoice/features/auth/presentation/auth_controller.dart';
import 'package:signovoice/features/subscription/domain/billing_service.dart';
import 'package:signovoice/features/subscription/domain/subscription.dart';
import 'package:signovoice/features/subscription/domain/subscription_repository.dart';
import 'package:signovoice/features/subscription/presentation/purchase_flow_controller.dart';
import 'package:signovoice/features/subscription/presentation/subscription_providers.dart';

// ---- test-only fakes ----
class _Auth extends AuthController {
  _Auth(this.signedIn);
  final bool signedIn;
  @override
  AuthState build() =>
      signedIn ? const AuthState(AuthStatus.authenticated, AppUser(uid: 'u1')) : const AuthState(AuthStatus.guest, AppUser.guest);
}

class _Billing implements BillingService {
  _Billing({this.available = true, this.products = const []});
  bool available;
  List<StoreProduct> products;
  final stream = StreamController<StorePurchase>.broadcast();
  final completed = <String>[];
  bool buyStarted = true;
  bool restoreCalled = false;
  @override
  StorePlatform get platform => StorePlatform.android;
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<List<StoreProduct>> loadProducts(Set<String> ids) async => products;
  @override
  Future<bool> buy(StoreProduct product, {String? accountId}) async => buyStarted;
  @override
  Future<void> restore({String? accountId}) async => restoreCalled = true;
  @override
  Stream<StorePurchase> get purchases => stream.stream;
  @override
  Future<void> complete(StorePurchase purchase) async => completed.add(purchase.productId);
  @override
  Future<void> dispose() async {}
}

class _Repo implements SubscriptionRepository {
  Subscription? verifyResult;
  Object? verifyError;
  Subscription restoreResult = Subscription.free;
  Object? restoreError;
  int verifyCalls = 0;
  final cache = <String, Subscription>{};
  @override
  Future<Subscription> cached(String uid) async => cache[uid] ?? Subscription.free;
  @override
  Future<void> writeCache(String uid, Subscription s) async => cache[uid] = s;
  @override
  Future<void> clearCache(String uid) async => cache.remove(uid);
  @override
  Future<Subscription> fetch(String uid) async => throw const Failure(FailureType.notConfigured);
  @override
  Future<Subscription> verifyPurchase({required String productId, required String purchaseToken, required StorePlatform platform, String? orderId}) async {
    verifyCalls++;
    if (verifyError != null) throw verifyError!;
    return verifyResult!;
  }

  @override
  Future<Subscription> cancelAutoRenew() async => Subscription.free;
  @override
  Future<Subscription> restore({required StorePlatform platform}) async {
    if (restoreError != null) throw restoreError!;
    return restoreResult;
  }
}

const monthlyTrial = StoreProduct(
  id: 'signovoice_premium_monthly',
  title: 'Premium monthly',
  offerToken: 'tok-trial',
  phases: [
    PricingPhase(billingPeriod: 'P1M', priceMicros: 0, formattedPrice: 'Free'),
    PricingPhase(billingPeriod: 'P1M', priceMicros: 99000000, formattedPrice: '₹99.00'),
  ],
);
const monthlyBase = StoreProduct(
  id: 'signovoice_premium_monthly',
  title: 'Premium monthly',
  offerToken: 'tok-base',
  phases: [PricingPhase(billingPeriod: 'P1M', priceMicros: 99000000, formattedPrice: '₹99.00')],
);
const yearly = StoreProduct(
  id: 'signovoice_premium_yearly',
  title: 'Premium yearly',
  offerToken: 'tok-y',
  phases: [PricingPhase(billingPeriod: 'P1Y', priceMicros: 799000000, formattedPrice: '₹799.00')],
);

const purchase = StorePurchase(
    productId: 'signovoice_premium_monthly', status: PurchaseEventStatus.purchased, purchaseToken: 'secret-token', orderId: 'GPA.1');

ProviderContainer _make({required _Billing billing, required _Repo repo, bool signedIn = true, NoopAnalyticsService? analytics, DateTime? now}) {
  final c = ProviderContainer(overrides: [
    keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
    authControllerProvider.overrideWith(() => _Auth(signedIn)),
    billingServiceProvider.overrideWithValue(billing),
    subscriptionRepositoryProvider.overrideWithValue(repo),
    isOnlineProvider.overrideWith((ref) => Stream.value(true)),
    analyticsServiceProvider.overrideWithValue(analytics ?? NoopAnalyticsService()),
    clockProvider.overrideWithValue(() => now ?? DateTime(2026, 6, 1, 12)),
  ]);
  addTearDown(c.dispose);
  c.listen(purchaseFlowProvider, (_, _) {});
  c.listen(subscriptionProvider, (_, _) {});
  return c;
}

Future<void> _until(bool Function() cond) async {
  final end = DateTime.now().add(const Duration(seconds: 5));
  while (!cond()) {
    if (DateTime.now().isAfter(end)) fail('timed out');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

final trialSub = Subscription(
  status: SubscriptionStatus.trial,
  trialStartDate: DateTime(2026, 6, 1),
  trialEndDate: DateTime(2026, 7, 1),
  productId: 'signovoice_premium_monthly',
  platform: StorePlatform.android,
  autoRenewing: true,
  verifiedAt: DateTime(2026, 6, 1),
);

void main() {
  group('offer selection', () {
    test('prefers the free-trial offer, else the base plan', () {
      expect(pickBestOffer([monthlyBase, monthlyTrial]), monthlyTrial);
      expect(pickBestOffer([monthlyBase]), monthlyBase);
      expect(pickBestOffer(const []), isNull);
      expect(monthlyTrial.hasFreeTrial, isTrue);
      expect(monthlyTrial.recurring.formattedPrice, '₹99.00');
      expect(monthlyBase.hasFreeTrial, isFalse);
    });
    test('parses ISO billing periods', () {
      expect(parseBillingPeriod('P1M').unit, BillingUnit.month);
      expect(parseBillingPeriod('P1Y').unit, BillingUnit.year);
      expect(parseBillingPeriod('P7D').count, 7);
      expect(parseBillingPeriod('P1W').unit, BillingUnit.week);
      expect(parseBillingPeriod('nonsense').unit, BillingUnit.unknown);
    });
  });

  group('loading products', () {
    test('ready with store prices; trial offer chosen', () async {
      final c = _make(billing: _Billing(products: [monthlyBase, monthlyTrial, yearly]), repo: _Repo());
      await c.read(purchaseFlowProvider.notifier).loadProducts();
      final s = c.read(purchaseFlowProvider);
      expect(s.stage, PurchaseStage.ready);
      expect(s.products.length, 2);
      expect(s.selected!.hasFreeTrial, isTrue);
      expect(s.selectedId, 'signovoice_premium_monthly');
    });
    test('billing unavailable', () async {
      final c = _make(billing: _Billing(available: false), repo: _Repo());
      await c.read(purchaseFlowProvider.notifier).loadProducts();
      expect(c.read(purchaseFlowProvider).stage, PurchaseStage.billingUnavailable);
    });
    test('no products configured in the store', () async {
      final c = _make(billing: _Billing(), repo: _Repo());
      await c.read(purchaseFlowProvider.notifier).loadProducts();
      expect(c.read(purchaseFlowProvider).stage, PurchaseStage.productsUnavailable);
    });
  });

  group('purchasing', () {
    test('guests must sign in first', () async {
      final billing = _Billing(products: [monthlyTrial]);
      final c = _make(billing: billing, repo: _Repo(), signedIn: false);
      final ctrl = c.read(purchaseFlowProvider.notifier);
      await ctrl.loadProducts();
      await ctrl.startPurchase();
      expect(c.read(purchaseFlowProvider).failure?.type, FailureType.unauthorized);
    });

    test('purchase → backend verification → trial unlocked → acknowledged', () async {
      final billing = _Billing(products: [monthlyTrial]);
      final repo = _Repo()..verifyResult = trialSub;
      final analytics = NoopAnalyticsService();
      final c = _make(billing: billing, repo: repo, analytics: analytics);
      final ctrl = c.read(purchaseFlowProvider.notifier);
      await ctrl.loadProducts();
      await ctrl.startPurchase();
      expect(c.read(purchaseFlowProvider).stage, PurchaseStage.purchasing);
      expect(c.read(isPremiumProvider), isFalse, reason: 'a started purchase alone never unlocks premium');

      billing.stream.add(purchase);
      await _until(() => c.read(purchaseFlowProvider).stage == PurchaseStage.success);

      expect(repo.verifyCalls, 1);
      expect(billing.completed, ['signovoice_premium_monthly']);
      expect(c.read(isPremiumProvider), isTrue);
      expect(c.read(entitlementProvider).isTrial, isTrue);
      expect(analytics.events, contains('trial_started'));
    });

    test('verification failure (offline) does NOT unlock premium or acknowledge; retry succeeds', () async {
      final billing = _Billing(products: [monthlyTrial]);
      final repo = _Repo()..verifyError = const Failure(FailureType.offline);
      final c = _make(billing: billing, repo: repo);
      final ctrl = c.read(purchaseFlowProvider.notifier);
      await ctrl.loadProducts();
      billing.stream.add(purchase);
      await _until(() => c.read(purchaseFlowProvider).stage == PurchaseStage.failed);

      expect(c.read(purchaseFlowProvider).failure?.type, FailureType.offline);
      expect(c.read(purchaseFlowProvider).needsVerification, isTrue);
      expect(c.read(isPremiumProvider), isFalse);
      expect(billing.completed, isEmpty);

      repo
        ..verifyError = null
        ..verifyResult = trialSub;
      await ctrl.retryVerification();
      expect(c.read(purchaseFlowProvider).stage, PurchaseStage.success);
      expect(c.read(isPremiumProvider), isTrue);
      expect(billing.completed, isNotEmpty);
    });

    test('backend not configured is reported and nothing is unlocked', () async {
      final billing = _Billing(products: [monthlyTrial]);
      final repo = _Repo()..verifyError = const Failure(FailureType.notConfigured);
      final c = _make(billing: billing, repo: repo);
      await c.read(purchaseFlowProvider.notifier).loadProducts();
      billing.stream.add(purchase);
      await _until(() => c.read(purchaseFlowProvider).stage == PurchaseStage.failed);
      expect(c.read(purchaseFlowProvider).failure?.type, FailureType.notConfigured);
      expect(c.read(isPremiumProvider), isFalse);
    });

    test('pending and cancelled purchases', () async {
      final billing = _Billing(products: [monthlyTrial]);
      final c = _make(billing: billing, repo: _Repo());
      await c.read(purchaseFlowProvider.notifier).loadProducts();
      billing.stream.add(const StorePurchase(productId: 'signovoice_premium_monthly', status: PurchaseEventStatus.pending));
      await _until(() => c.read(purchaseFlowProvider).stage == PurchaseStage.pending);
      expect(c.read(isPremiumProvider), isFalse);
      billing.stream.add(const StorePurchase(productId: 'signovoice_premium_monthly', status: PurchaseEventStatus.cancelled));
      await _until(() => c.read(purchaseFlowProvider).stage == PurchaseStage.cancelled);
    });

    test('store error and failure to start are surfaced', () async {
      final billing = _Billing(products: [monthlyTrial])..buyStarted = false;
      final c = _make(billing: billing, repo: _Repo());
      final ctrl = c.read(purchaseFlowProvider.notifier);
      await ctrl.loadProducts();
      await ctrl.startPurchase();
      expect(c.read(purchaseFlowProvider).failure?.type, FailureType.billingUnavailable);
      billing.stream.add(const StorePurchase(productId: 'signovoice_premium_monthly', status: PurchaseEventStatus.error, errorCode: 'x'));
      await _until(() => c.read(purchaseFlowProvider).failure?.code == 'x');
    });

    test('ignores purchases of unknown products', () async {
      final billing = _Billing(products: [monthlyTrial]);
      final repo = _Repo()..verifyResult = trialSub;
      final c = _make(billing: billing, repo: repo);
      await c.read(purchaseFlowProvider.notifier).loadProducts();
      billing.stream.add(const StorePurchase(productId: 'other', status: PurchaseEventStatus.purchased, purchaseToken: 't'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(repo.verifyCalls, 0);
    });
  });

  group('restore purchases', () {
    test('restores an active subscription via the backend', () async {
      final billing = _Billing(products: [monthlyTrial]);
      final repo = _Repo()..restoreResult = trialSub;
      final c = _make(billing: billing, repo: repo);
      await c.read(purchaseFlowProvider.notifier).restore();
      expect(billing.restoreCalled, isTrue);
      expect(c.read(purchaseFlowProvider).stage, PurchaseStage.success);
      expect(c.read(isPremiumProvider), isTrue);
    });
    test('nothing to restore', () async {
      final c = _make(billing: _Billing(), repo: _Repo());
      await c.read(purchaseFlowProvider.notifier).restore();
      expect(c.read(purchaseFlowProvider).stage, PurchaseStage.restoreNothing);
      expect(c.read(isPremiumProvider), isFalse);
    });
    test('network failure is reported', () async {
      final repo = _Repo()..restoreError = const Failure(FailureType.offline);
      final c = _make(billing: _Billing(), repo: repo);
      await c.read(purchaseFlowProvider.notifier).restore();
      expect(c.read(purchaseFlowProvider).failure?.type, FailureType.offline);
    });
  });

  group('entitlement over time', () {
    test('an expired trial loses premium even if stored status says trial', () async {
      final repo = _Repo()..cache['u1'] = trialSub;
      final c = _make(billing: _Billing(), repo: repo, now: DateTime(2026, 8, 15));
      await c.read(subscriptionProvider.future);
      expect(c.read(entitlementProvider).status, SubscriptionStatus.expired);
      expect(c.read(isPremiumProvider), isFalse);
    });
    test('cancelled subscription keeps access until period end and logs analytics', () async {
      final cancelled = Subscription(status: SubscriptionStatus.cancelled, subscriptionEndDate: DateTime(2026, 6, 20));
      final analytics = NoopAnalyticsService();
      final c = _make(billing: _Billing(), repo: _Repo(), analytics: analytics);
      await c.read(subscriptionProvider.future);
      await c.read(subscriptionProvider.notifier).applyVerified(cancelled);
      expect(c.read(isPremiumProvider), isTrue);
      expect(analytics.events, contains('subscription_cancelled'));
    });
    test('guests are always free', () async {
      final c = _make(billing: _Billing(), repo: _Repo()..cache['guest'] = trialSub, signedIn: false);
      expect(await c.read(subscriptionProvider.future), Subscription.free);
      expect(c.read(isPremiumProvider), isFalse);
    });
  });
}
