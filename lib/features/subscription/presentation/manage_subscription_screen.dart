import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/failure_message.dart';
import 'purchase_flow_controller.dart';
import 'subscription_labels.dart';
import 'subscription_providers.dart';
import 'widgets/purchase_status_banner.dart';
import 'widgets/trial_status_card.dart';

class ManageSubscriptionScreen extends ConsumerStatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  ConsumerState<ManageSubscriptionScreen> createState() => _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends ConsumerState<ManageSubscriptionScreen> {
  bool _refreshing = false;
  String? _message;

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _message = null;
    });
    try {
      await ref.read(subscriptionProvider.notifier).refresh();
      if (mounted) setState(() => _message = context.l10n.statusRefreshed);
    } catch (e) {
      if (mounted) setState(() => _message = failureMessage(context.l10n, toFailure(e)));
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _openStore(String? productId) async {
    final uri = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.https('play.google.com', '/store/account/subscriptions', {'package': kApplicationId, 'sku': ?productId});
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ent = ref.watch(entitlementProvider);
    final flow = ref.watch(purchaseFlowProvider);
    final ctrl = ref.read(purchaseFlowProvider.notifier);
    final sub = ent.subscription;

    return Scaffold(
      appBar: AppBar(title: Text(l.manageSubscription)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TrialStatusCard(entitlement: ent),
        const SizedBox(height: 12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (sub.productId != null) Text(l.planName(planTitle(l, sub.productId!)), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              sub.verifiedAt == null ? l.notVerifiedYet : l.lastVerified(formatDate(context, sub.verifiedAt!)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ]),
        ),
        if (_message != null) Padding(padding: const EdgeInsets.only(top: 8), child: Semantics(liveRegion: true, child: Text(_message!))),
        PurchaseStatusBanner(state: flow),
        const SizedBox(height: 12),
        PrimaryButton(label: l.manageInStore, icon: Icons.open_in_new_rounded, onPressed: () => _openStore(sub.productId)),
        const SizedBox(height: 10),
        SecondaryButton(label: l.refreshStatus, icon: Icons.refresh_rounded, onPressed: _refreshing ? null : _refresh),
        const SizedBox(height: 10),
        SecondaryButton(label: l.restorePurchases, icon: Icons.restore_rounded, onPressed: flow.busy ? null : ctrl.restore),
        const SizedBox(height: 16),
        Text(l.cancelAnytime, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}
