import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/failure_message.dart';
import '../data/razorpay_order_checkout.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/billing_service.dart';
import '../domain/subscription.dart';
import '../domain/trial_policy.dart';
import 'purchase_flow_controller.dart';
import 'subscription_providers.dart';
import 'terms_block.dart';
import 'widgets/payment_method_selector.dart';
import 'widgets/plan_comparison.dart';
import 'widgets/purchase_status_banner.dart';
import 'widgets/subscription_card.dart';
import 'widgets/trial_status_card.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

/// Saving of a multi-month plan versus the monthly plan, from the real store prices (same currency only).
int? _savePercent(Map<String, StoreProduct> all, StoreProduct p) {
  final months = parseBillingPeriod(p.recurring.billingPeriod);
  final monthly = all[AppConfig.monthlyProductId];
  if (monthly == null || p.id == monthly.id || months.unit != BillingUnit.month || months.count < 2) return null;
  final base = monthly.recurring.priceMicros * months.count;
  if (base <= 0 || p.recurring.priceMicros <= 0) return null;
  final pct = ((1 - p.recurring.priceMicros / base) * 100).round();
  return pct >= 5 ? pct : null;
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _testBusy = false;
  String? _testMessage;

  /// Debug-only end-to-end check of Razorpay Standard Checkout (order → checkout → signature verify).
  Future<void> _testPayment() async {
    final checkout = RazorpayOrderCheckout(api: ref.read(apiClientProvider));
    setState(() {
      _testBusy = true;
      _testMessage = null;
    });
    try {
      final r = await checkout.pay(amountPaise: 100, description: 'Test payment');
      if (!mounted) return;
      final l = context.l10n;
      setState(() => _testMessage = switch (r.outcome) {
            OrderPaymentOutcome.success => l.testPaymentOk,
            OrderPaymentOutcome.cancelled => l.testPaymentCancelled,
            OrderPaymentOutcome.failed => l.testPaymentFailed,
          });
    } catch (e) {
      if (mounted) setState(() => _testMessage = failureMessageWithReason(context.l10n, toFailure(e)));
    } finally {
      checkout.dispose();
      if (mounted) setState(() => _testBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(apiClientProvider).warmUp(); // wakes a sleeping free-tier backend before plans are requested
    Future(() => ref.read(purchaseFlowProvider.notifier).loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final flow = ref.watch(purchaseFlowProvider);
    final ctrl = ref.read(purchaseFlowProvider.notifier);
    final ent = ref.watch(entitlementProvider);
    final auth = ref.watch(authControllerProvider);
    final method = ref.watch(paymentMethodProvider);
    final selected = flow.selected;
    final eligible = TrialPolicy.isTrialEligible(ent.subscription);
    final canBuy = !ent.isPremium && flow.stage != PurchaseStage.billingUnavailable && flow.stage != PurchaseStage.productsUnavailable;
    final showTrial = eligible && (selected?.hasFreeTrial ?? true);

    return Scaffold(
      appBar: AppBar(title: Text(l.premiumPlan)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), children: [
        _Hero(title: l.premiumHeroTitle, body: l.premiumHeroBody, header: l.premiumHeader),
        const SizedBox(height: 16),
        if (ent.subscription.status != SubscriptionStatus.free) ...[
          TrialStatusCard(entitlement: ent, onTap: () => context.push(Routes.manageSubscription)),
          const SizedBox(height: 16),
        ],
        const PlanComparison(),
        TextButton(onPressed: () => context.push(Routes.premiumBenefits), child: Text(l.seeAllBenefits)),
        const SizedBox(height: 8),
        if (canBuy && AppConfig.enableRazorpay) ...[
          PaymentMethodSelector(
            selected: method,
            enabled: !flow.busy,
            onChanged: (m) {
              ref.read(paymentMethodProvider.notifier).select(m);
              Future(() => ref.read(purchaseFlowProvider.notifier).loadProducts());
            },
          ),
          const SizedBox(height: 16),
        ],
        if (canBuy) ...[
          if (flow.stage == PurchaseStage.loadingProducts && flow.products.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
          else
            for (final p in flow.products.values) ...[
              SubscriptionCard(product: p, selected: p.id == flow.selectedId, onTap: () => ctrl.select(p.id), savePercent: _savePercent(flow.products, p)),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 4),
          TermsBlock(product: selected, method: method),
        ],
        PurchaseStatusBanner(method: method, state: flow, onRetryVerification: ctrl.retryVerification, onRetryLoad: ctrl.loadProducts),
        if (canBuy) ...[
          const SizedBox(height: 8),
          if (!auth.isSignedIn)
            PrimaryButton(label: l.signInToSubscribe, icon: Icons.login_rounded, onPressed: () => ref.read(authControllerProvider.notifier).leaveGuestMode())
          else
            PrimaryButton(
              label: showTrial ? l.startFreeTrial : l.subscribeNow,
              icon: Icons.workspace_premium_rounded,
              loading: flow.busy,
              onPressed: selected == null ? null : ctrl.startPurchase,
            ),
        ],
        if (kDebugMode && AppConfig.enableRazorpay && auth.isSignedIn) ...[
          const SizedBox(height: 8),
          SecondaryButton(label: l.testPaymentButton, icon: Icons.bolt_rounded, onPressed: _testBusy ? null : _testPayment),
          if (_testMessage != null) Padding(padding: const EdgeInsets.only(top: 8), child: Semantics(liveRegion: true, child: Text(_testMessage!))),
        ],
        const SizedBox(height: 8),
        if (auth.isSignedIn)
          SecondaryButton(label: l.restorePurchases, icon: Icons.restore_rounded, onPressed: flow.busy ? null : ctrl.restore),
      ]),
    );
  }
}

/// Gradient hero with a gently floating crown so the page feels like a reward, not a wall.
class _Hero extends StatefulWidget {
  const _Hero({required this.title, required this.body, required this.header});
  final String title;
  final String body;
  final String header;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      header: true,
      label: '${widget.header}. ${widget.title}. ${widget.body}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.secondary]),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title.toUpperCase(), style: text.labelMedium?.copyWith(color: Colors.white, letterSpacing: 1.2)),
              const SizedBox(height: 4),
              Text(widget.header, style: text.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(widget.body, style: text.bodyMedium?.copyWith(color: Colors.white)),
            ]),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _c,
            builder: (_, child) => Transform.translate(offset: Offset(0, -6 * Curves.easeInOut.transform(_c.value)), child: child),
            child: const Icon(Icons.workspace_premium_rounded, size: 56, color: Colors.white),
          ),
        ]),
      ),
    );
  }
}
