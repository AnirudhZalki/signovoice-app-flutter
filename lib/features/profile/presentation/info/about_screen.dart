import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/brand.dart';
import 'community_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsAbout)),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Center(child: BrandMark(size: 96)),
        const SizedBox(height: 16),
        Text(l.appName, style: text.headlineMedium, textAlign: TextAlign.center),
        Text(l.tagline, style: text.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(l.coreIdea, style: text.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (_, snap) => Text(
            snap.hasData ? l.aboutVersion(snap.data!.version, snap.data!.buildNumber) : '',
            textAlign: TextAlign.center,
            style: text.labelMedium,
          ),
        ),
        const SizedBox(height: 16),
        Text(l.aboutMission, style: text.bodyLarge, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        const CommunityCard(),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 12),
          Expanded(child: Text(l.aboutModelNote('9'))),
        ]))),
        const SizedBox(height: 16),
        ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: Text(l.legalTitlePrivacy), onTap: () => context.push(Routes.legalPrivacy)),
        ListTile(leading: const Icon(Icons.gavel_rounded), title: Text(l.legalTitleTerms), onTap: () => context.push(Routes.legalTerms)),
        ListTile(
          leading: const Icon(Icons.article_outlined),
          title: Text(l.aboutLicenses),
          onTap: () => showLicensePage(context: context, applicationName: AppConstants.appName),
        ),
      ]),
    );
  }
}
