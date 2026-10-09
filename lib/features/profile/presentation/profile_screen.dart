import 'package:flutter/material.dart';
import '../../sign_translation/presentation/widgets/translation_panel.dart' show shareText;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/misc_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../history/presentation/history_controller.dart';
import '../../learning/presentation/learning_controller.dart';
import '../../subscription/presentation/subscription_providers.dart';
import '../../subscription/presentation/widgets/trial_status_card.dart';
import '../data/account_service.dart';
import 'profile_controller.dart';
import 'settings/settings_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    var clear = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l.logoutTitle),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.logoutBody),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: clear,
              onChanged: (v) => setState(() => clear = v ?? false),
              title: Text(l.logoutClearData),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.signOut)),
          ],
        ),
      ),
    );
    if (ok == true) await ref.read(accountServiceProvider).signOut(clearLocalData: clear);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final profile = ref.watch(profileProvider).value;
    final ent = ref.watch(entitlementProvider);
    final history = ref.watch(historyProvider).value?.length ?? 0;
    final learned = ref.watch(learningProvider).learned.length;
    final usage = ref.watch(usageServiceProvider);
    final name = (profile?.displayName.isNotEmpty ?? false) ? profile!.displayName : (auth.user?.displayName ?? '');
    final contact = auth.user?.email ?? auth.user?.phone;
    final limit = ent.dailySignLimit;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.navProfile)),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            ProfileAvatar(name: name, photoUrl: profile?.photoUrl ?? auth.user?.photoUrl, size: 72),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Semantics(header: true, child: Text(name.isEmpty ? (auth.isGuest ? l.guestName : l.appName) : name, style: text.titleLarge)),
                if (contact != null) Text(contact, style: text.bodyMedium),
              ]),
            ),
            IconButton(tooltip: l.editProfile, icon: const Icon(Icons.edit_outlined), onPressed: () => context.push(Routes.profileEdit)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TrialStatusCard(entitlement: ent, onTap: () => context.push(Routes.premium)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.usageTitle, style: text.titleMedium),
              const SizedBox(height: 8),
              Text(limit < 0 ? l.usageSigns('${usage.signsToday}') : l.usageSignsOfLimit('${usage.signsToday}', '$limit')),
              Text(l.usageHistory('$history')),
              Text(l.usageLearned('$learned')),
            ]),
          ),
        ),
        SettingsHeader(l.sectionPreferences),
        SettingsTile(icon: Icons.language_rounded, title: l.settingsLanguage, onTap: () => context.push(Routes.settingsLanguage)),
        SettingsTile(icon: Icons.accessibility_new_rounded, title: l.settingsAccessibility, onTap: () => context.push(Routes.settingsAccessibility)),
        SettingsTile(icon: Icons.notifications_none_rounded, title: l.settingsNotifications, onTap: () => context.push(Routes.settingsNotifications)),
        SettingsTile(icon: Icons.tune_rounded, title: l.settingsTitle, onTap: () => context.push(Routes.settings)),
        SettingsHeader(l.sectionAccount),
        SettingsTile(icon: Icons.workspace_premium_outlined, title: l.settingsSubscription, onTap: () => context.push(Routes.premium)),
        SettingsTile(icon: Icons.privacy_tip_outlined, title: l.settingsPrivacy, onTap: () => context.push(Routes.settingsPrivacy)),
        SettingsTile(icon: Icons.lock_outline_rounded, title: l.settingsSecurity, onTap: () => context.push(Routes.settingsSecurity)),
        SettingsHeader(l.sectionSupport),
        SettingsTile(icon: Icons.share_outlined, title: l.shareWithOthers, onTap: () => shareText(l.homeShareMessage)),
        SettingsTile(icon: Icons.help_outline_rounded, title: l.settingsHelp, onTap: () => context.push(Routes.help)),
        SettingsTile(icon: Icons.info_outline_rounded, title: l.settingsAbout, onTap: () => context.push(Routes.about)),
        const Divider(),
        if (auth.isGuest)
          SettingsTile(icon: Icons.person_add_alt_1_rounded, title: l.createAccountAction, onTap: () => ref.read(authControllerProvider.notifier).leaveGuestMode())
        else
          SettingsTile(icon: Icons.logout_rounded, title: l.signOut, onTap: () => _confirmLogout(context, ref)),
        SettingsTile(icon: Icons.delete_forever_outlined, title: l.privacyDeleteAccount, danger: true, onTap: () => context.push(Routes.deleteAccount)),
      ]),
    );
  }
}
