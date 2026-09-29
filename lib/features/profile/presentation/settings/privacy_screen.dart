import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/providers.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/cards.dart';
import '../../../../shared/widgets/failure_message.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../data/account_service.dart';
import '../preferences_controller.dart';
import 'settings_widgets.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  Future<bool> _confirm(BuildContext context, String title, String body, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
          ],
        ),
      ) ??
      false;

  void _snack(BuildContext context, String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final prefs = ref.watch(preferencesProvider);
    final n = ref.read(preferencesProvider.notifier);
    final acct = ref.read(accountServiceProvider);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsPrivacy)),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.shield_outlined), const SizedBox(width: 8), Expanded(child: Text(l.privacyDataTitle, style: Theme.of(context).textTheme.titleMedium))]),
              const SizedBox(height: 10),
              for (final t in [l.privacyDataCamera, l.privacyDataMic, l.privacyDataAccount, l.privacyDataHistory, l.privacyDataPurchases, l.privacyDataCalls, l.privacyDataAnalytics])
                Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(padding: EdgeInsets.only(top: 3), child: Icon(Icons.circle, size: 6)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(t)),
                ])),
            ]),
          ),
        ),
        SwitchListTile(
          title: Text(l.privacyAnalytics),
          subtitle: Text(l.privacyAnalyticsDesc),
          value: prefs.analyticsEnabled,
          onChanged: (v) async {
            await n.update((p) => p.copyWith(analyticsEnabled: v));
            await ref.read(analyticsServiceProvider).setEnabled(v);
          },
        ),
        SwitchListTile(title: Text(l.privacySaveHistory), value: prefs.saveHistory, onChanged: (v) => n.update((p) => p.copyWith(saveHistory: v))),
        SettingsTile(
          icon: Icons.history_toggle_off_rounded,
          title: l.privacyClearHistory,
          onTap: () async {
            if (await _confirm(context, l.historyClearTitle, l.historyClearBody, l.delete)) {
              await acct.clearHistory();
              if (context.mounted) _snack(context, l.historyCleared);
            }
          },
        ),
        SettingsTile(
          icon: Icons.restart_alt_rounded,
          title: l.privacyClearProgress,
          onTap: () async {
            if (await _confirm(context, l.privacyClearProgress, l.privacyClearProgressBody, l.delete)) {
              await acct.resetLearning();
              if (context.mounted) _snack(context, l.privacyProgressCleared);
            }
          },
        ),
        if (auth.isSignedIn)
          SettingsTile(
            icon: Icons.cloud_off_outlined,
            title: l.privacyRequestDeletion,
            onTap: () async {
              try {
                await acct.requestServerDataDeletion();
                if (context.mounted) _snack(context, l.privacyDeletionRequested);
              } catch (e) {
                if (context.mounted) _snack(context, failureMessage(l, toFailure(e)));
              }
            },
          ),
        SettingsTile(icon: Icons.description_outlined, title: l.legalTitlePrivacy, onTap: () => context.push(Routes.legalPrivacy)),
        SettingsTile(icon: Icons.gavel_rounded, title: l.legalTitleTerms, onTap: () => context.push(Routes.legalTerms)),
        const Divider(),
        SettingsTile(icon: Icons.delete_forever_outlined, title: l.privacyDeleteAccount, danger: true, onTap: () => context.push(Routes.deleteAccount)),
      ]),
    );
  }
}
