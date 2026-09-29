import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/buttons.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _contact(BuildContext context) async {
    final l = context.l10n;
    final info = await PackageInfo.fromPlatform();
    final uri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      queryParameters: {'subject': '${l.helpEmailSubject} (${info.version}+${info.buildNumber})'},
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final faqs = [
      (l.faq1q, l.faq1a('9')),
      (l.faq2q, l.faq2a),
      (l.faq3q, l.faq3a),
      (l.faq4q, l.faq4a),
      (l.faq5q, l.faq5a),
      (l.faq6q, l.faq6a),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.helpTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final f in faqs)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(f.$1, style: Theme.of(context).textTheme.titleSmall),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(f.$2)],
          ),
        const SizedBox(height: 16),
        if (AppConfig.supportEmail.isNotEmpty) PrimaryButton(label: l.helpContact, icon: Icons.mail_outline_rounded, onPressed: () => _contact(context)),
        const SizedBox(height: 8),
        TextButton(onPressed: () => context.push(Routes.legalPrivacy), child: Text(l.legalTitlePrivacy)),
        TextButton(onPressed: () => context.push(Routes.legalTerms), child: Text(l.legalTitleTerms)),
      ]),
    );
  }
}
