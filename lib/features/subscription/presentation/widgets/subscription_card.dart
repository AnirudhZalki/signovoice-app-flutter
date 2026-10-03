import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/status_widgets.dart';
import '../../domain/billing_service.dart';
import '../subscription_labels.dart';

/// A selectable plan (monthly / yearly) showing the *store's* price.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key, required this.product, required this.selected, required this.onTap});
  final StoreProduct product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final price = product.recurring.formattedPrice;
    final period = periodLabel(l, product.recurring.billingPeriod);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: '${planTitle(l, product.id)}. ${l.planPerPeriod(price, period)}${product.hasFreeTrial ? '. ${l.planFirstFree}' : ''}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? scheme.primary : scheme.outline, width: selected ? 2.5 : 1),
          ),
          child: Row(children: [
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: selected ? scheme.primary : scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(planTitle(l, product.id), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(l.planPerPeriod(price, period), style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            if (product.hasFreeTrial) Flexible(child: StatusBadge(label: l.planFirstFree, tone: StatusTone.success, icon: Icons.card_giftcard_rounded)),
          ]),
        ),
      ),
    );
  }
}
