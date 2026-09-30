import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/in_app_billing_service.dart';
import '../data/razorpay_billing_service.dart';
import '../domain/payment_method.dart';
import '../domain/billing_service.dart';
import '../domain/trial_policy.dart';
import 'subscription_providers.dart';

/// The person's chosen payment method. Razorpay is offered only when [AppConfig.enableRazorpay].
class PaymentMethodController extends Notifier<PaymentMethod> {
  @override
  PaymentMethod build() =>
      AppConfig.enableRazorpay && AppConfig.defaultPaymentMethod == 'razorpay' ? PaymentMethod.razorpay : PaymentMethod.googlePlay;

  void select(PaymentMethod m) {
    if (m == PaymentMethod.razorpay && !AppConfig.enableRazorpay) return;
    state = m;
  }
}

final paymentMethodProvider = NotifierProvider<PaymentMethodController, PaymentMethod>(PaymentMethodController.new);

final billingServiceProvider = Provider<BillingService>((ref) {
  final BillingService s = ref.watch(paymentMethodProvider) == PaymentMethod.razorpay
      ? RazorpayBillingService(api: ref.watch(apiClientProvider))
      : InAppBillingService();
  ref.onDispose(s.dispose);
  return s;
});

enum PurchaseStage {
  idle,
  loadingProducts,
  ready,
  billingUnavailable,
  productsUnavailable,
  purchasing,
  pending,
  verifying,
  success,
  cancelled,
  failed,
  restoring,
  restoreNothing,
}

class PurchaseFlowState {
  const PurchaseFlowState({
    this.stage = PurchaseStage.idle,
    this.products = const {},
    this.selectedId,
    this.failure,
    this.needsVerification = false,
  });

  final PurchaseStage stage;

  /// Best offer per product id, straight from the store (real prices).
  final Map<String, StoreProduct> products;
  final String? selectedId;
  final Failure? failure;

  /// A purchase went through in the store but the backend hasn't verified it yet.
  final bool needsVerification;

  StoreProduct? get selected => selectedId == null ? null : products[selectedId];
  bool get busy =>
      stage == PurchaseStage.loadingProducts ||
      stage == PurchaseStage.purchasing ||
      stage == PurchaseStage.verifying ||
      stage == PurchaseStage.restoring;

  PurchaseFlowState copyWith({
    PurchaseStage? stage,
    Map<String, StoreProduct>? products,
    String? selectedId,
    Failure? failure,
    bool clearFailure = false,
    bool? needsVerification,
  }) =>
      PurchaseFlowState(
        stage: stage ?? this.stage,
        products: products ?? this.products,
        selectedId: selectedId ?? this.selectedId,
        failure: clearFailure ? null : (failure ?? this.failure),
        needsVerification: needsVerification ?? this.needsVerification,
      );
}

/// Purchase → store transaction → **backend verification** → entitlement.
/// Premium is never granted from a store event alone.
class PurchaseFlowController extends Notifier<PurchaseFlowState> {
  StreamSubscription<StorePurchase>? _sub;
  StorePurchase? _unverified;
  final Set<String> _verifying = {};

  BillingService get _billing => ref.read(billingServiceProvider);
  BillingService? _watched;

  @override
  PurchaseFlowState build() {
    // Re-subscribes when the payment method changes.
    _watched = ref.watch(billingServiceProvider);
    _sub = _watched!.purchases.listen(_onPurchase);
    ref.onDispose(() => _sub?.cancel());
    return const PurchaseFlowState();
  }

  Future<void> loadProducts() async {
    if (state.busy) return;
    state = state.copyWith(stage: PurchaseStage.loadingProducts, clearFailure: true);
    try {
      if (!await _billing.isAvailable()) {
        state = state.copyWith(stage: PurchaseStage.billingUnavailable);
        return;
      }
      final all = await _billing.loadProducts(AppConfig.subscriptionProductIds);
      final byId = <String, List<StoreProduct>>{};
      for (final p in all) {
        (byId[p.id] ??= []).add(p);
      }
      final best = <String, StoreProduct>{
        for (final e in byId.entries) e.key: pickBestOffer(e.value)!,
      };
      if (best.isEmpty) {
        state = state.copyWith(stage: PurchaseStage.productsUnavailable, products: const {});
        return;
      }
      final selected = best.containsKey(state.selectedId)
          ? state.selectedId
          : (best.containsKey(AppConfig.monthlyProductId) ? AppConfig.monthlyProductId : best.keys.first);
      state = state.copyWith(stage: PurchaseStage.ready, products: best, selectedId: selected);
    } catch (e) {
      state = state.copyWith(stage: PurchaseStage.failed, failure: toFailure(e));
    }
  }

  void select(String id) {
    if (state.products.containsKey(id)) state = state.copyWith(selectedId: id);
  }

  Future<void> startPurchase() async {
    final product = state.selected;
    if (product == null || state.busy) return;
    final auth = ref.read(authControllerProvider);
    if (!auth.isSignedIn) {
      state = state.copyWith(stage: PurchaseStage.failed, failure: const Failure(FailureType.unauthorized));
      return;
    }
    if (!(ref.read(isOnlineProvider).value ?? true)) {
      state = state.copyWith(stage: PurchaseStage.failed, failure: const Failure(FailureType.offline));
      return;
    }
    state = state.copyWith(stage: PurchaseStage.purchasing, clearFailure: true);
    try {
      final started = await _billing.buy(product, accountId: auth.uid);
      if (!started) {
        state = state.copyWith(stage: PurchaseStage.failed, failure: const Failure(FailureType.billingUnavailable));
      }
      // Otherwise the outcome arrives on the purchase stream.
    } catch (e) {
      state = state.copyWith(stage: PurchaseStage.failed, failure: toFailure(e));
    }
  }

  Future<void> _onPurchase(StorePurchase p) async {
    if (!AppConfig.subscriptionProductIds.contains(p.productId)) return;
    switch (p.status) {
      case PurchaseEventStatus.pending:
        state = state.copyWith(stage: PurchaseStage.pending, clearFailure: true);
      case PurchaseEventStatus.cancelled:
        state = state.copyWith(stage: PurchaseStage.cancelled, clearFailure: true);
      case PurchaseEventStatus.error:
        state = state.copyWith(
          stage: PurchaseStage.failed,
          failure: Failure(FailureType.billingUnavailable, code: p.errorCode),
        );
      case PurchaseEventStatus.purchased:
      case PurchaseEventStatus.restored:
        await _verify(p);
    }
  }

  Future<void> _verify(StorePurchase p) async {
    final token = p.purchaseToken;
    final auth = ref.read(authControllerProvider);
    if (token == null || token.isEmpty) return;
    if (!_verifying.add(token)) return; // already in progress
    _unverified = p;
    state = state.copyWith(stage: PurchaseStage.verifying, clearFailure: true, needsVerification: true);
    try {
      if (!auth.isSignedIn) throw const Failure(FailureType.unauthorized);
      final sub = await ref.read(subscriptionRepositoryProvider).verifyPurchase(
            productId: p.productId,
            purchaseToken: token,
            platform: _billing.platform,
            orderId: p.orderId,
          );
      await ref.read(subscriptionProvider.notifier).applyVerified(sub);
      // Only now is it safe to finish/acknowledge the store transaction.
      await _billing.complete(p);
      _unverified = null;
      final ok = TrialPolicy.hasPremiumAccess(sub, ref.read(clockProvider)());
      state = state.copyWith(
        stage: ok ? PurchaseStage.success : PurchaseStage.failed,
        needsVerification: !ok,
        failure: ok ? null : const Failure(FailureType.serviceUnavailable, debugDetail: 'verified but not active'),
        clearFailure: ok,
      );
    } catch (e) {
      // Keep the store purchase un-acknowledged so the store re-delivers it.
      state = state.copyWith(stage: PurchaseStage.failed, failure: toFailure(e), needsVerification: true);
    } finally {
      _verifying.remove(token);
    }
  }

  /// Retry backend verification of a purchase that was made but not yet verified.
  Future<void> retryVerification() async {
    final p = _unverified;
    if (p != null) await _verify(p);
  }

  Future<void> restore() async {
    if (state.busy) return;
    final auth = ref.read(authControllerProvider);
    if (!auth.isSignedIn) {
      state = state.copyWith(stage: PurchaseStage.failed, failure: const Failure(FailureType.unauthorized));
      return;
    }
    state = state.copyWith(stage: PurchaseStage.restoring, clearFailure: true);
    try {
      if (!await _billing.isAvailable()) {
        state = state.copyWith(stage: PurchaseStage.billingUnavailable);
        return;
      }
      await _billing.restore(accountId: auth.uid);
      // Ask the backend to re-check the store for this account too.
      final sub = await ref.read(subscriptionRepositoryProvider).restore(platform: _billing.platform);
      await ref.read(subscriptionProvider.notifier).applyVerified(sub);
      final ok = TrialPolicy.hasPremiumAccess(sub, ref.read(clockProvider)());
      state = state.copyWith(stage: ok ? PurchaseStage.success : PurchaseStage.restoreNothing);
    } catch (e) {
      final f = toFailure(e);
      // "Nothing to restore" is not an error the person needs to fix.
      state = state.copyWith(stage: PurchaseStage.failed, failure: f);
    }
  }

  void reset() => state = state.copyWith(stage: state.products.isEmpty ? PurchaseStage.idle : PurchaseStage.ready, clearFailure: true);
}

final purchaseFlowProvider = NotifierProvider<PurchaseFlowController, PurchaseFlowState>(PurchaseFlowController.new);

/// Keeps the purchase listener alive for the whole session once signed in, so
/// pending/interrupted purchases are always received and verified.
final purchaseListenerProvider = Provider<void>((ref) {
  if (ref.watch(authControllerProvider.select((a) => a.isSignedIn)) && ref.watch(firebaseAvailableProvider)) {
    ref.watch(purchaseFlowProvider);
  }
});
