import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/status_widgets.dart';
import '../../../learning/presentation/learning_controller.dart';
import '../../domain/sign_dictionary.dart';
import '../category_labels.dart';

/// Row card for a dictionary entry (word, meaning, video availability, favourite).
class SignCard extends ConsumerWidget {
  const SignCard({super.key, required this.entry, required this.onTap});
  final SignEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final progress = ref.watch(learningProvider);
    final fav = progress.bookmarked.contains(entry.id);
    final learned = progress.learned.contains(entry.id);
    return AppCard(
      onTap: onTap,
      semanticLabel: '${entry.word}. ${entry.meaning}',
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.word, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(entry.meaning, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              StatusBadge(
                label: entry.hasMedia ? l.hasVideo : l.signVideoUnavailable,
                tone: entry.hasMedia ? StatusTone.success : StatusTone.neutral,
                icon: entry.hasMedia ? Icons.play_circle_outline : Icons.videocam_off_outlined,
              ),
              if (learned) StatusBadge(label: l.signLearned, tone: StatusTone.info, icon: Icons.check_rounded),
            ]),
          ]),
        ),
        IconButton(
          tooltip: fav ? l.bookmarkRemove : l.bookmarkAdd,
          icon: Icon(fav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
          onPressed: () => ref.read(learningProvider.notifier).toggleBookmark(entry.id),
        ),
      ]),
    );
  }
}

/// Small chip showing a topic.
class CategoryChipLabel extends StatelessWidget {
  const CategoryChipLabel({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) => Text(categoryName(context.l10n, id));
}
