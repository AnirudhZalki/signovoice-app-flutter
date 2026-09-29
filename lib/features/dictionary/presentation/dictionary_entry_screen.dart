import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../learning/presentation/learning_controller.dart';
import '../../profile/presentation/preferences_controller.dart';
import '../../sign_translation/presentation/sign_translation_controller.dart';
import '../domain/sign_dictionary.dart';
import 'category_labels.dart';
import 'dictionary_providers.dart';
import 'widgets/sign_media_view.dart';

/// Speaks [text] in [languageCode] using the person's voice settings.
Future<void> pronounce(WidgetRef ref, String text, String languageCode) {
  final p = ref.read(preferencesProvider);
  return ref.read(ttsServiceProvider).speak(text, language: ttsLocaleFor(languageCode), rate: p.ttsRate);
}

class DictionaryEntryScreen extends ConsumerWidget {
  const DictionaryEntryScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: AsyncValueView<SignDictionary>(
        value: ref.watch(dictionaryProvider),
        onRetry: () => ref.invalidate(dictionaryProvider),
        data: (dict) {
          final e = dict.byId[id];
          if (e == null) return EmptyState(icon: Icons.search_off_rounded, title: l.entryNotFound);
          return _EntryBody(entry: e, labelCount: dict.entries.where((x) => x.isPracticeable).length);
        },
      ),
    );
  }
}

class _EntryBody extends ConsumerWidget {
  const _EntryBody({required this.entry, required this.labelCount});
  final SignEntry entry;
  final int labelCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final progress = ref.watch(learningProvider);
    final fav = progress.bookmarked.contains(entry.id);
    final learned = progress.learned.contains(entry.id);
    final text = Theme.of(context).textTheme;
    final langNames = {'hi': l.langHindi, 'kn': l.langKannada};

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        SignMediaView(entry: entry),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Semantics(header: true, child: Text(entry.word, style: text.headlineMedium))),
          IconButton.filledTonal(
            tooltip: fav ? l.bookmarkRemove : l.bookmarkAdd,
            icon: Icon(fav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
            onPressed: () => ref.read(learningProvider.notifier).toggleBookmark(entry.id),
          ),
        ]),
        const SizedBox(height: 4),
        Text(categoryName(l, entry.categoryId), style: text.labelMedium),
        const SizedBox(height: 16),
        Text(l.meaningLabel, style: text.labelMedium),
        const SizedBox(height: 4),
        Text(entry.meaning, style: text.bodyLarge),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.tonalIcon(
            icon: const Icon(Icons.volume_up_rounded),
            label: Text('${l.listenPronunciation} · ${l.langEnglish}'),
            onPressed: () => pronounce(ref, entry.word, 'en'),
          ),
          for (final e in entry.aliases.entries)
            if (langNames.containsKey(e.key))
              FilledButton.tonalIcon(
                icon: const Icon(Icons.volume_up_rounded),
                label: Text('${e.value.first} · ${langNames[e.key]}'),
                onPressed: () => pronounce(ref, e.value.first, e.key),
              ),
        ]),
        const SizedBox(height: 24),
        if (entry.isPracticeable)
          PrimaryButton(
            icon: Icons.fitness_center_rounded,
            label: l.practiceThisSign,
            onPressed: () => context.push(Routes.practice(entry.id)),
          )
        else
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(l.practiceNotAvailable('$labelCount'), style: text.bodySmall)),
          ]),
        const SizedBox(height: 12),
        SecondaryButton(
          icon: learned ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
          label: learned ? l.signLearned : l.markLearned,
          onPressed: learned ? null : () => ref.read(learningProvider.notifier).markLearned(entry.id),
        ),
      ],
    );
  }
}
