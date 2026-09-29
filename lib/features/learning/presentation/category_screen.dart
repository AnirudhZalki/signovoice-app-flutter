import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../dictionary/domain/sign_dictionary.dart';
import '../../dictionary/presentation/category_labels.dart';
import '../../dictionary/presentation/dictionary_providers.dart';
import 'learning_controller.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final learned = ref.watch(learningProvider).learned;
    return Scaffold(
      appBar: AppBar(title: Text(categoryName(l, categoryId))),
      body: AsyncValueView<SignDictionary>(
        value: ref.watch(dictionaryProvider),
        onRetry: () => ref.invalidate(dictionaryProvider),
        data: (dict) {
          final lessons = lessonsFor(dict, categoryId);
          if (lessons.isEmpty) return EmptyState(icon: Icons.school_outlined, title: l.emptyDefaultTitle);
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final ls = lessons[i];
              final done = ls.learnedCount(learned);
              final complete = ls.isComplete(learned);
              return AppCard(
                onTap: () => context.push('/learn/lesson/${ls.id}'),
                semanticLabel: '${l.lessonN('${i + 1}')}. ${l.lessonProgress('$done', '${ls.entries.length}')}',
                child: Row(children: [
                  Icon(complete ? Icons.check_circle_rounded : Icons.play_circle_outline_rounded, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.lessonN('${i + 1}'), style: Theme.of(context).textTheme.titleMedium),
                      Text(ls.entries.map((e) => e.word).join(', '), style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(l.lessonProgress('$done', '${ls.entries.length}'), style: Theme.of(context).textTheme.labelMedium),
                    ]),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
