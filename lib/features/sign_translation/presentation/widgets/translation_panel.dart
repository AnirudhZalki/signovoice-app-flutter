import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/status_widgets.dart';
import '../sign_translation_controller.dart';

/// Current sign + confidence, translated sentence, glosses and language.
class TranslationCard extends StatelessWidget {
  const TranslationCard({super.key, required this.state, required this.threshold, required this.onLanguage});

  final SignTranslationState state;
  final double threshold;
  final ValueChanged<String> onLanguage;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final cur = state.current;
    final languages = {'en': l.langEnglish, 'hi': l.langHindi, 'kn': l.langKannada};

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l.currentSign, style: text.labelMedium),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  liveRegion: false,
                  child: Text(
                    state.paused ? l.recognitionPaused : (cur?.label ?? (state.handVisible ? l.noSignYet : l.scanningHand)),
                    style: text.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          if (cur != null && !state.paused) ...[
            const SizedBox(height: 8),
            ConfidenceIndicator(confidence: cur.confidence, threshold: threshold),
          ],
          const Divider(height: 24),
          Text(l.translationLabel, style: text.labelMedium),
          const SizedBox(height: 6),
          Semantics(
            liveRegion: true,
            label: state.sentence.isEmpty ? l.translationPlaceholder : l.liveTranslation(state.sentence),
            excludeSemantics: true,
            child: SelectableText(
              state.sentence.isEmpty ? l.translationPlaceholder : state.sentence,
              style: state.sentence.isEmpty
                  ? text.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)
                  : text.headlineSmall,
            ),
          ),
          if (state.glosses.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l.recognisedSigns, style: text.labelMedium),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final g in state.glosses) Chip(label: Text(g), visualDensity: VisualDensity.compact),
            ]),
          ],
          const SizedBox(height: 12),
          Text(l.outputLanguage, style: text.labelMedium),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in languages.entries)
              ChoiceChip(label: Text(e.value), selected: state.languageCode == e.key, onSelected: (_) => onLanguage(e.key)),
          ]),
        ],
      ),
    );
  }
}

/// Copy / share helpers for the translated text.
Future<void> copyText(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.copied)));
  }
}

Future<void> shareText(String text) => SharePlus.instance.share(ShareParams(text: text));
