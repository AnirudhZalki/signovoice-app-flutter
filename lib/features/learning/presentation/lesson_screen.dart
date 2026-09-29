import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/providers.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../dictionary/domain/sign_dictionary.dart';
import '../../dictionary/presentation/category_labels.dart';
import '../../dictionary/presentation/dictionary_entry_screen.dart';
import '../../dictionary/presentation/dictionary_providers.dart';
import '../../dictionary/presentation/widgets/sign_media_view.dart';
import 'learning_controller.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).log(AnalyticsEvents.learningStarted);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: AsyncValueView<SignDictionary>(
        value: ref.watch(dictionaryProvider),
        onRetry: () => ref.invalidate(dictionaryProvider),
        data: (dict) {
          final lesson = lessonById(dict, widget.lessonId);
          if (lesson == null) return EmptyState(icon: Icons.school_outlined, title: l.entryNotFound);
          final n = lesson.entries.length;
          final finished = _page >= n;
          return SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      '${categoryName(l, lesson.categoryId)} · ${l.lessonN('${lesson.index + 1}')}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (!finished) Text(l.signOfTotal('${_page + 1}', '$n'), style: Theme.of(context).textTheme.labelMedium),
                ]),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: finished ? 1 : (_page / n)),
              Expanded(
                child: finished
                    ? _Summary(lesson: lesson)
                    : _SignPage(
                        key: ValueKey(lesson.entries[_page].id),
                        entry: lesson.entries[_page],
                        labelCount: dict.entries.where((e) => e.isPracticeable).length,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  if (_page > 0)
                    Expanded(
                      child: SecondaryButton(
                        label: l.previous,
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => setState(() => _page--),
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: finished ? l.done : (_page == n - 1 ? l.finishLesson : l.next),
                      onPressed: () => finished ? context.pop() : setState(() => _page++),
                    ),
                  ),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}

class _SignPage extends ConsumerWidget {
  const _SignPage({super.key, required this.entry, required this.labelCount});
  final SignEntry entry;
  final int labelCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final learned = ref.watch(learningProvider).learned.contains(entry.id);
    final text = Theme.of(context).textTheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      SignMediaView(entry: entry),
      const SizedBox(height: 16),
      Semantics(header: true, child: Text(entry.word, style: text.headlineMedium)),
      const SizedBox(height: 8),
      Text(entry.meaning, style: text.bodyLarge),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        FilledButton.tonalIcon(
          icon: const Icon(Icons.volume_up_rounded),
          label: Text(l.listenPronunciation),
          onPressed: () => pronounce(ref, entry.word, 'en'),
        ),
        if (entry.isPracticeable)
          FilledButton.tonalIcon(
            icon: const Icon(Icons.fitness_center_rounded),
            label: Text(l.practiceThisSign),
            onPressed: () => context.push(Routes.practice(entry.id)),
          ),
      ]),
      const SizedBox(height: 12),
      SecondaryButton(
        icon: learned ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
        label: learned ? l.signLearned : l.markLearned,
        onPressed: learned ? null : () => ref.read(learningProvider.notifier).markLearned(entry.id),
      ),
    ]);
  }
}

class _Summary extends ConsumerWidget {
  const _Summary({required this.lesson});
  final LessonRef lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final learned = ref.watch(learningProvider).learned;
    final count = lesson.learnedCount(learned);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.celebration_outlined, size: 72, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 16),
          Text(l.lessonComplete, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(l.lessonCompleteBody('$count'), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
