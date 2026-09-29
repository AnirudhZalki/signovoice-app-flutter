import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/status_widgets.dart';
import '../../domain/entitlement.dart';
import '../../domain/subscription.dart';
import '../../domain/trial_policy.dart';
import '../subscription_labels.dart';

/// Shows the plan, trial countdown and renewal/end dates. Every state has an
/// icon and text label — colour is only a reinforcement.
class TrialStatusCard extends StatelessWidget {
  const TrialStatusCard({super.key, required this.entitlement, this.onTap});
  final Entitlement entitlement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final sub = entitlement.subscription;
    final status = entitlement.status;
    final now = entitlement.evaluatedAt;
    final end = TrialPolicy.accessEndDate(sub, now);
    final (tone, icon) = statusStyle(status);
    final text = Theme.of(context).textTheme;

    final lines = <String>[
      switch (status) {
        SubscriptionStatus.free => l.freeBody,
        SubscriptionStatus.trial => l.trialDaysLeft('${TrialPolicy.trialDaysLeft(sub, now)}'),
        SubscriptionStatus.expired => l.expiredBody,
        _ => '',
      },
      if (status == SubscriptionStatus.trial && end != null) l.trialEnds(formatDate(context, end)),
      if (status == SubscriptionStatus.premium && end != null) l.renewsOn(formatDate(context, end)),
      if (status == SubscriptionStatus.cancelled && end != null) l.accessEndsOn(formatDate(context, end)),
      if (entitlement.isPremium) (sub.autoRenewing ? l.autoRenewOn : l.autoRenewOff),
    ].where((e) => e.isNotEmpty).toList();

    return AppCard(
      onTap: onTap,
      semanticLabel: '${statusLabel(l, status)}. ${lines.join('. ')}',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Align(alignment: AlignmentDirectional.centerStart, child: StatusBadge(label: statusLabel(l, status), tone: tone, icon: icon))),
          if (onTap != null) const Icon(Icons.chevron_right_rounded),
        ]),
        for (final line in lines) ...[const SizedBox(height: 8), Text(line, style: text.bodyMedium)],
      ]),
    );
  }
}
