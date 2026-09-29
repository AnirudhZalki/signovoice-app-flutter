import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/l10n_ext.dart';

/// FREE vs PREMIUM. Only capabilities that truly exist and are enforced.
class PlanComparison extends StatelessWidget {
  const PlanComparison({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = <(String, String, bool, String, bool)>[
      (l.featRecognition, l.featRecognitionFree('${AppConstants.freeDailyTranslations}'), true, l.featUnlimited, true),
      (l.featHistory, l.featHistoryFree('${AppConstants.freeHistoryEntries}'), true, l.featFullHistory, true),
      (l.featAi, l.featNotIncluded, false, l.featIncludedOnline, true),
      (l.featAnalytics, l.featBasicProgress, true, l.featFullAnalytics, true),
      (l.featCore, l.featIncluded, true, l.featIncluded, true),
    ];
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget cell(String label, bool included) => Expanded(
          flex: 3,
          child: Row(children: [
            Icon(included ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded, size: 20, color: included ? scheme.secondary : scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: text.bodySmall?.copyWith(color: scheme.onSurface))),
          ]),
        );

    return Semantics(
      container: true,
      child: Column(children: [
        Row(children: [
          const Expanded(flex: 3, child: SizedBox()),
          Expanded(flex: 3, child: Text(l.freePlan, style: text.titleSmall)),
          Expanded(flex: 3, child: Text(l.premiumPlan, style: text.titleSmall?.copyWith(color: scheme.primary))),
        ]),
        const Divider(height: 16),
        for (final r in rows) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: Text(r.$1, style: text.labelLarge)),
              cell(r.$2, r.$3),
              cell(r.$4, r.$5),
            ]),
          ),
          const Divider(height: 1),
        ],
      ]),
    );
  }
}
