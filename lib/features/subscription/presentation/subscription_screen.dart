import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/subscription.dart';
import '../domain/trial_policy.dart';
import 'purchase_flow_controller.dart';
import 'subscription_providers.dart';
import 'terms_block.dart';
import 'widgets/plan_comparison.dart';
import 'widgets/purchase_status_banner.dart';
import 'widgets/subscription_card.dart';
import 'widgets/trial_status_card.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    Future(() => ref.read(purchaseFlowProvider.notifier).loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final flow = ref.watch(purchaseFlowProvider);
    final ctrl = ref.read(purchaseFlowProvider.notifier);
    final ent = ref.watch(entitlementProvider);
    final auth = ref.watch(authControllerProvider);
    final text = Theme.of(context).textTheme;
    final selected = flow.selected;
    final eligible = TrialPolicy.isTrialEligible(ent.subscription);
    final canBuy = !ent.isPremium && flow.stage != PurchaseStage.billingUnavailable && flow.stage != PurchaseStage.productsUnavailable;
    final showTrial = eligible && (selected?.hasFreeTrial ?? true);

    return Scaffold(
      appBar: AppBar(title: Text(l.premiumPlan)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), children: [
        Semantics(header: true, child: Text(l.premiumHeader, style: text.headlineMedium)),
        const SizedBox(height: 8),
        Text(l.premiumSubheader, style: text.bodyLarge),
        const SizedBox(height: 16),
        if (ent.subscription.status != SubscriptionStatus.free) ...[
          TrialStatusCard(entitlement: ent, onTap: () => context.push(Routes.manageSubscription)),
          const SizedBox(height: 16),
        ],
        const PlanComparison(),
        TextButton(onPressed: () => context.push(Routes.premiumBenefits), child: Text(l.seeAllBenefits)),
        const SizedBox(height: 8),
        if (canBuy) ...[
          if (flow.stage == PurchaseStage.loadingProducts && flow.products.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
          else
            for (final p in flow.products.values) ...[
              SubscriptionCard(product: p, selected: p.id == flow.selectedId, onTap: () => ctrl.select(p.id)),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 4),
          TermsBlock(product: selected),
        ],
        PurchaseStatusBanner(state: flow, onRetryVerification: ctrl.retryVerification, onRetryLoad: ctrl.loadProducts),
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
        const SizedBox(height: 8),
        if (auth.isSignedIn)
          SecondaryButton(label: l.restorePurchases, icon: Icons.restore_rounded, onPressed: flow.busy ? null : ctrl.restore),
      ]),
    );
  }
}
