import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../sign_translation/presentation/widgets/translation_panel.dart' show shareText;

/// Says who the app is for and why it helps, instead of explaining what it is.
class CommunityCard extends StatelessWidget {
  const CommunityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final benefits = [
      (Icons.record_voice_over_rounded, l.homeBenefit1Title, l.homeBenefit1Body),
      (Icons.hearing_rounded, l.homeBenefit2Title, l.homeBenefit2Body),
      (Icons.family_restroom_rounded, l.homeBenefit3Title, l.homeBenefit3Body),
      (Icons.lock_outline_rounded, l.homeBenefit4Title, l.homeBenefit4Body),
    ];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.favorite_rounded, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Semantics(header: true, child: Text(l.homeCommunityTitle, style: text.titleMedium))),
        ]),
        const SizedBox(height: 8),
        Text(l.homeCommunityBody),
        const SizedBox(height: 12),
        for (final b in benefits)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ExcludeSemantics(child: Icon(b.$1, size: 22, color: scheme.secondary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.$2, style: text.titleSmall),
                  Text(b.$3, style: text.bodySmall),
                ]),
              ),
            ]),
          ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => shareText(l.homeShareMessage),
            icon: const Icon(Icons.share_rounded),
            label: Text(l.homeShareCta),
          ),
        ),
      ]),
    );
  }
}
