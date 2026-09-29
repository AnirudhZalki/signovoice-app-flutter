import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/routing/session.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/brand.dart';
import '../domain/trial_policy.dart';
import 'purchase_flow_controller.dart';
import 'subscription_labels.dart';
import 'subscription_providers.dart';
import 'terms_block.dart';
import 'widgets/purchase_status_banner.dart';

/// Shown once after sign-up. Clear terms first; nothing is charged without the
/// store's own confirmation sheet.
class TrialOfferScreen extends ConsumerStatefulWidget {
  const TrialOfferScreen({super.key});

  @override
  ConsumerState<TrialOfferScreen> createState() => _TrialOfferScreenState();
}

class _TrialOfferScreenState extends ConsumerState<TrialOfferScreen> {
  @override
  void initState() {
    super.initState();
    Future(() => ref.read(purchaseFlowProvider.notifier).loadProducts());
  }

  Future<void> _continue() => ref.read(trialOfferSeenProvider.notifier).markSeen();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final flow = ref.watch(purchaseFlowProvider);
    final ctrl = ref.read(purchaseFlowProvider.notifier);
    final ent = ref.watch(entitlementProvider);
    final text = Theme.of(context).textTheme;

    // Already premium (e.g. signed in on a new device): nothing to offer.
    ref.listen(entitlementProvider.select((e) => e.isPremium), (_, premium) {
      if (premium) _continue();
    });

    final product = flow.selected;
    final eligible = TrialPolicy.isTrialEligible(ent.subscription);
    final loaded = flow.stage != PurchaseStage.loadingProducts && flow.stage != PurchaseStage.idle;
    final trialAvailable = eligible && (product?.hasFreeTrial ?? false);
    final unavailable = loaded && !trialAvailable;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Center(child: BrandMark(size: 72)),
            const SizedBox(height: 20),
            Semantics(header: true, child: Text(l.trialOfferTitle, style: text.headlineMedium, textAlign: TextAlign.center)),
            const SizedBox(height: 8),
            Text(l.trialOfferBody, style: text.bodyLarge, textAlign: TextAlign.center),
            if (trialAvailable) ...[
              const SizedBox(height: 8),
              Text(
                l.trialOfferPrice(product!.recurring.formattedPrice, periodWord(l, product.recurring.billingPeriod)),
                style: text.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            if (unavailable && flow.stage == PurchaseStage.ready) Text(l.trialNotAvailable, textAlign: TextAlign.center),
            if (!unavailable || flow.stage != PurchaseStage.ready) TermsBlock(product: trialAvailable ? product : null),
            PurchaseStatusBanner(state: flow, onRetryVerification: ctrl.retryVerification, onRetryLoad: ctrl.loadProducts),
            const SizedBox(height: 12),
            if (flow.stage == PurchaseStage.success)
              PrimaryButton(label: l.continueLabel, onPressed: _continue)
            else ...[
              if (trialAvailable || !loaded)
                PrimaryButton(label: l.startFreeTrial, icon: Icons.workspace_premium_rounded, loading: flow.busy || !loaded, onPressed: trialAvailable ? ctrl.startPurchase : null),
              const SizedBox(height: 8),
              SecondaryButton(label: unavailable ? l.continueLabel : l.notNow, onPressed: flow.stage == PurchaseStage.verifying ? null : _continue),
              TextButton(onPressed: () => context.push(Routes.premiumBenefits), child: Text(l.seeAllBenefits)),
            ],
          ]),
        ),
      ),
    );
  }
}
