import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../dictionary/domain/sign_dictionary.dart';
import '../../dictionary/presentation/category_labels.dart';
import '../../dictionary/presentation/dictionary_providers.dart';
import '../domain/learning_progress.dart';
import 'learning_controller.dart';
import 'widgets/badge_wrap.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.navLearn)),
      body: AsyncValueView<SignDictionary>(
        value: ref.watch(dictionaryProvider),
        onRetry: () => ref.invalidate(dictionaryProvider),
        data: (dict) => _Body(dict: dict),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.dict});
  final SignDictionary dict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = ref.watch(learningProvider);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final total = dict.entries.length;
    final learned = p.learned.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(l.learnTitle, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(l.learnSubtitle, style: text.bodyMedium),
        const SizedBox(height: 16),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.yourProgress, style: text.titleMedium),
            const SizedBox(height: 12),
            Wrap(spacing: 16, runSpacing: 8, children: [
              _Stat(icon: Icons.bolt_rounded, label: l.xpValue('${p.xp}')),
              _Stat(icon: Icons.emoji_events_outlined, label: l.levelValue('${ProgressRules.level(p.xp)}')),
              _Stat(icon: Icons.local_fire_department_outlined, label: l.streakValue('${p.streakDays}')),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: total == 0 ? 0 : learned / total, minHeight: 10, backgroundColor: scheme.surfaceContainerHighest),
            ),
            const SizedBox(height: 6),
            Text(l.learnedOf('$learned', '$total'), style: text.bodySmall),
          ]),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.tonalIcon(icon: const Icon(Icons.menu_book_rounded), label: Text(l.dictionaryTitle), onPressed: () => context.push(Routes.dictionary)),
          FilledButton.tonalIcon(icon: const Icon(Icons.bookmark_rounded), label: Text(l.savedSigns), onPressed: () => context.push('${Routes.dictionary}?saved=1')),
          FilledButton.tonalIcon(icon: const Icon(Icons.fitness_center_rounded), label: Text(l.practiceHubTitle), onPressed: () => context.push(Routes.practiceHub)),
          FilledButton.tonalIcon(icon: const Icon(Icons.insights_rounded), label: Text(l.learningAnalytics), onPressed: () => context.push(Routes.progress)),
        ]),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
          child: Semantics(header: true, child: Text(l.topics, style: text.titleLarge)),
        ),
        for (final c in dict.categories) ...[
          _CategoryTile(category: c, dict: dict, learned: p.learned),
          const SizedBox(height: 10),
        ],
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
          child: Semantics(header: true, child: Text(l.badgesTitle, style: text.titleLarge)),
        ),
        BadgeWrap(earned: p.badges),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Flexible(child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
      ]);
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.dict, required this.learned});
  final SignCategory category;
  final SignDictionary dict;
  final Set<String> learned;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final entries = dict.byCategory[category.id] ?? const <SignEntry>[];
    final done = entries.where((e) => learned.contains(e.id)).length;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: () => context.push(Routes.learnCategory(category.id)),
      semanticLabel: '${categoryName(l, category.id)}. ${l.learnedOf('$done', '${entries.length}')}',
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Icon(categoryIcon(category.icon), color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(categoryName(l, category.id), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: entries.isEmpty ? 0 : done / entries.length, minHeight: 6, backgroundColor: scheme.surfaceContainerHighest),
            ),
            const SizedBox(height: 4),
            Text(l.learnedOf('$done', '${entries.length}'), style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded),
      ]),
    );
  }
}
