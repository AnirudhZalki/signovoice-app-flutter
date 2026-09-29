import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/cards.dart';

/// Gentle, non-aggressive upgrade prompt.
class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key, required this.title, required this.body, this.compact = false});
  final String title;
  final String body;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      color: scheme.primaryContainer,
      borderColor: scheme.primary.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.workspace_premium_rounded, color: scheme.onPrimaryContainer),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer))),
          ]),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer)),
          const SizedBox(height: 12),
          SecondaryButton(label: context.l10n.seePremium, expanded: !compact, onPressed: () => context.push(Routes.premium)),
        ],
      ),
    );
  }
}
