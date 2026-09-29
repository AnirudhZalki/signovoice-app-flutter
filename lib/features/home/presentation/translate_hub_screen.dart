import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import 'home_screen.dart';

/// Translate tab: the three translation modes, one tap each.
class TranslateHubScreen extends StatelessWidget {
  const TranslateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final modes = quickActions(context).take(3).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.navTranslate)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.translateTabTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(l.translateTabSubtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          for (final m in modes) ...[
            FeatureCard(icon: m.icon, title: m.title, subtitle: m.subtitle, accent: m.color, onTap: () => context.push(m.route)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
