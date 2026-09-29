import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../domain/learning_progress.dart';
import '../badge_labels.dart';

/// Earned badges are filled with a check; unearned are outlined and say so in
/// text — state never depends on colour alone.
class BadgeWrap extends StatelessWidget {
  const BadgeWrap({super.key, required this.earned});
  final Set<LearningBadge> earned;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Wrap(spacing: 10, runSpacing: 10, children: [
      for (final b in LearningBadge.values)
        Semantics(
          label: '${badgeName(l, b)}. ${earned.contains(b) ? '' : l.badgeLocked}',
          child: ExcludeSemantics(
            child: Container(
              width: 104,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: earned.contains(b) ? scheme.secondaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: earned.contains(b) ? scheme.secondary : scheme.outline, width: earned.contains(b) ? 2 : 1),
              ),
              child: Column(children: [
                Icon(earned.contains(b) ? badgeIcon(b) : Icons.lock_outline_rounded,
                    color: earned.contains(b) ? scheme.onSecondaryContainer : scheme.onSurfaceVariant),
                const SizedBox(height: 6),
                Text(badgeName(l, b), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
              ]),
            ),
          ),
        ),
    ]);
  }
}
