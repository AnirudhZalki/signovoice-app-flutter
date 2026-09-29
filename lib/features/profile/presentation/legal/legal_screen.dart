import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/l10n_ext.dart';
import 'legal_content.dart';

enum LegalDoc { privacy, terms }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isPrivacy = doc == LegalDoc.privacy;
    final sections = isPrivacy ? LegalContent.privacyPolicy : LegalContent.terms;
    final url = isPrivacy ? AppConfig.privacyPolicyUrl : AppConfig.termsUrl;
    final text = Theme.of(context).textTheme;
    final english = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      appBar: AppBar(title: Text(isPrivacy ? l.legalTitlePrivacy : l.legalTitleTerms)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(LegalContent.lastUpdated, style: text.labelMedium),
        if (!english) Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.legalEnglishOnly, style: text.bodySmall)),
        if (url.startsWith('https://'))
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication), icon: const Icon(Icons.open_in_new_rounded), label: Text(l.openInBrowser)),
          ),
        for (final s in sections) ...[
          const SizedBox(height: 16),
          Semantics(header: true, child: Text(s.heading, style: text.titleMedium)),
          const SizedBox(height: 6),
          Text(s.body, style: text.bodyMedium),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }
}
