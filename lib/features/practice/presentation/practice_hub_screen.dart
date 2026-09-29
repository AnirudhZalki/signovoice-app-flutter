import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../dictionary/domain/sign_dictionary.dart';
import '../../dictionary/presentation/category_labels.dart';
import '../../dictionary/presentation/dictionary_providers.dart';
import '../../learning/presentation/learning_controller.dart';
import '../../learning/presentation/widgets/badge_wrap.dart';

class PracticeHubScreen extends ConsumerWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = ref.watch(learningProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.practiceHubTitle)),
      body: AsyncValueView<SignDictionary>(
        value: ref.watch(dictionaryProvider),
        onRetry: () => ref.invalidate(dictionaryProvider),
        data: (dict) {
          final signs = dict.entries.where((e) => e.isPracticeable).toList();
          return ListView(padding: const EdgeInsets.all(16), children: [
            Text(l.practiceIntro, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            AppCard(
              child: Wrap(spacing: 20, runSpacing: 8, children: [
                _Chip(Icons.bolt_rounded, l.xpValue('${p.xp}')),
                _Chip(Icons.local_fire_department_outlined, l.streakValue('${p.streakDays}')),
                _Chip(Icons.track_changes_rounded, '${l.accuracyLabel}: ${(p.accuracy * 100).round()}%'),
              ]),
            ),
            const SizedBox(height: 16),
            Text(l.practiceAvailableSigns, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final s in signs) ...[
              AppCard(
                onTap: () => context.push(Routes.practice(s.id)),
                semanticLabel: '${s.word}. ${categoryName(l, s.categoryId)}',
                child: Row(children: [
                  const Icon(Icons.fitness_center_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.word, style: Theme.of(context).textTheme.titleMedium),
                      Text(categoryName(l, s.categoryId), style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                  if ((p.correctBySign[s.id] ?? 0) > 0) ...[
                    const Icon(Icons.check_circle_rounded, size: 20),
                    const SizedBox(width: 4),
                    Text('${p.correctBySign[s.id]}', style: Theme.of(context).textTheme.labelLarge),
                  ],
                  const Icon(Icons.chevron_right_rounded),
                ]),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            Text(l.badgesTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            BadgeWrap(earned: p.badges),
          ]);
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Flexible(child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
      ]);
}
