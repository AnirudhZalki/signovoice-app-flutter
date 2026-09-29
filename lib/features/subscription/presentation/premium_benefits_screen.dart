import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';

class PremiumBenefitsScreen extends StatelessWidget {
  const PremiumBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final items = <(IconData, String, String)>[
      (Icons.all_inclusive_rounded, l.benefitUnlimited, l.benefitUnlimitedBody('${AppConstants.freeDailyTranslations}')),
      (Icons.history_rounded, l.featFullHistory, l.benefitHistoryBody('${AppConstants.freeHistoryEntries}')),
      (Icons.auto_awesome_rounded, l.featAi, l.benefitAiBody),
      (Icons.insights_rounded, l.learningAnalytics, l.benefitAnalyticsBody),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.premiumBenefitsTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final i in items) ...[
          AppCard(
            semanticLabel: '${i.$2}. ${i.$3}',
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(i.$1, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(i.$2, style: text.titleMedium),
                const SizedBox(height: 4),
                Text(i.$3, style: text.bodyMedium),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        AppCard(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.favorite_border_rounded), const SizedBox(width: 8), Text(l.alwaysFreeTitle, style: text.titleMedium)]),
            const SizedBox(height: 6),
            Text(l.alwaysFreeBody),
          ]),
        ),
      ]),
    );
  }
}
