import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../sign_translation/presentation/widgets/translation_panel.dart';
import '../../subscription/presentation/widgets/premium_card.dart';
import '../data/history_repository.dart';
import '../domain/history_entry.dart';
import 'history_controller.dart';

String historyTypeLabel(AppLocalizations l, HistoryInputType t) => switch (t) {
      HistoryInputType.signToText => l.modeSignToText,
      HistoryInputType.signToVoice => l.modeSignToVoice,
      HistoryInputType.voiceToSign => l.modeVoiceToSign,
    };

IconData historyTypeIcon(HistoryInputType t) => switch (t) {
      HistoryInputType.signToText => Icons.sign_language_rounded,
      HistoryInputType.signToVoice => Icons.volume_up_rounded,
      HistoryInputType.voiceToSign => Icons.mic_rounded,
    };

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmClear() async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.historyClearTitle),
        content: Text(l.historyClearBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(historyProvider.notifier).clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.historyCleared)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hidden = ref.watch(historyHiddenCountProvider);
    final hasAny = (ref.watch(historyProvider).value ?? const []).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.historyTitle),
        actions: [
          if (hasAny)
            IconButton(tooltip: l.historyClearAll, icon: const Icon(Icons.delete_sweep_outlined), onPressed: _confirmClear),
        ],
      ),
      body: AsyncValueView<List<HistoryEntry>>(
        value: ref.watch(visibleHistoryProvider),
        onRetry: () => ref.invalidate(historyProvider),
        data: (all) {
          if (all.isEmpty && hidden == 0) {
            return EmptyState(icon: Icons.history_rounded, title: l.historyEmptyTitle, message: l.historyEmptyBody);
          }
          final items = HistoryRepository.search(all, _query);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: l.historySearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l.clear,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l.historyNoResults))),
              for (final e in items) ...[
                _HistoryTile(entry: e),
                const SizedBox(height: 10),
              ],
              if (hidden > 0)
                PremiumCard(title: l.historyHiddenTitle, body: l.historyHidden('$hidden')),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final when = DateFormat.yMMMd(locale).add_jm().format(entry.timestamp);
    final secs = (entry.durationMs / 1000).round();
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      onDismissed: (_) {
        ref.read(historyProvider.notifier).delete(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.historyDeleted)));
      },
      child: AppCard(
        semanticLabel: '${historyTypeLabel(l, entry.inputType)}. ${entry.text}. $when',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(historyTypeIcon(entry.inputType), size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(historyTypeLabel(l, entry.inputType), style: Theme.of(context).textTheme.labelMedium)),
              Text(entry.languageCode.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            ]),
            const SizedBox(height: 8),
            Text(entry.text.isEmpty ? entry.glosses.join(' ') : entry.text, style: Theme.of(context).textTheme.titleMedium),
            if (entry.glosses.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(entry.glosses.join(' · '), style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text('$when · ${l.durationSeconds('$secs')}', style: Theme.of(context).textTheme.labelSmall)),
              IconButton(
                tooltip: l.copy,
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: () => copyText(context, entry.text),
              ),
              IconButton(tooltip: l.share, icon: const Icon(Icons.share_rounded, size: 20), onPressed: () => shareText(entry.text)),
              IconButton(
                tooltip: l.delete,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: () {
                  ref.read(historyProvider.notifier).delete(entry.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.historyDeleted)));
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
