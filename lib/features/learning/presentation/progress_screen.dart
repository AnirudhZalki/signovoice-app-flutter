import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../dictionary/domain/sign_dictionary.dart';
import '../../dictionary/presentation/category_labels.dart';
import '../../dictionary/presentation/dictionary_providers.dart';
import '../../subscription/domain/entitlement.dart';
import '../../subscription/presentation/subscription_providers.dart';
import '../../subscription/presentation/widgets/premium_card.dart';
import 'learning_controller.dart';

/// Detailed learning analytics — a Premium feature (basic progress stays free on the Learn tab).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final allowed = ref.watch(entitlementProvider).allows(PremiumFeature.learningAnalytics);
    return Scaffold(
      appBar: AppBar(title: Text(l.learningAnalytics)),
      body: !allowed
          ? ListView(padding: const EdgeInsets.all(16), children: [PremiumCard(title: l.analyticsLocked, body: l.analyticsLockedBody)])
          : AsyncValueView<SignDictionary>(
              value: ref.watch(dictionaryProvider),
              data: (dict) => _Analytics(dict: dict),
            ),
    );
  }
}

class _Analytics extends ConsumerWidget {
  const _Analytics({required this.dict});
  final SignDictionary dict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = ref.watch(learningProvider);
    final now = ref.watch(clockProvider)();
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final days = [for (var i = 6; i >= 0; i--) dayOnly(now).subtract(Duration(days: i))];
    final counts = [for (final d in days) p.activity[dayKey(d)] ?? 0];
    final maxCount = counts.fold<int>(1, (a, b) => b > a ? b : a);

    return ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(
        child: Row(children: [
          Expanded(child: _Metric(label: l.accuracyLabel, value: '${(p.accuracy * 100).round()}%')),
          Expanded(child: _Metric(label: l.attemptsLabel, value: '${p.practiceAttempts}')),
          Expanded(child: _Metric(label: l.xpValue(''), value: '${p.xp}')),
        ]),
      ),
      const SizedBox(height: 16),
      Text(l.lastSevenDays, style: text.titleMedium),
      const SizedBox(height: 8),
      AppCard(
        child: SizedBox(
          height: 150,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Semantics(
                  label: l.activityDay(DateFormat.E(locale).format(days[i]), '${counts[i]}'),
                  child: ExcludeSemantics(
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('${counts[i]}', style: text.labelSmall),
                      const SizedBox(height: 4),
                      Container(
                        height: 8 + 90 * counts[i] / maxCount,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(color: counts[i] == 0 ? scheme.outlineVariant : scheme.primary, borderRadius: BorderRadius.circular(6)),
                      ),
                      const SizedBox(height: 6),
                      Text(DateFormat.E(locale).format(days[i]), style: text.labelSmall),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Text(l.completionByTopic, style: text.titleMedium),
      const SizedBox(height: 8),
      for (final c in dict.categories) ...[
        Builder(builder: (_) {
          final entries = dict.byCategory[c.id] ?? const <SignEntry>[];
          final done = entries.where((e) => p.learned.contains(e.id)).length;
          final pct = entries.isEmpty ? 0 : (done * 100 / entries.length).round();
          return Semantics(
            label: '${categoryName(l, c.id)}: $pct%',
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(categoryName(l, c.id), style: text.bodyMedium)),
                    Text('$pct%', style: text.labelMedium),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: entries.isEmpty ? 0 : done / entries.length, minHeight: 8, backgroundColor: scheme.surfaceContainerHighest),
                  ),
                ]),
              ),
            ),
          );
        }),
      ],
    ]);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
      ]);
}
