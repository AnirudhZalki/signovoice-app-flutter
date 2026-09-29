import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/user_preferences.dart';
import '../preferences_controller.dart';
import 'settings_widgets.dart';

class SettingsHubScreen extends ConsumerWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final prefs = ref.watch(preferencesProvider);
    final n = ref.read(preferencesProvider.notifier);
    final themeLabels = {AppThemeMode.system: l.themeSystem, AppThemeMode.light: l.themeLight, AppThemeMode.dark: l.themeDark};

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(children: [
        SettingsHeader(l.settingsTheme),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<AppThemeMode>(
            segments: [
              for (final e in themeLabels.entries)
                ButtonSegment(
                  value: e.key,
                  label: Text(e.value),
                  icon: Icon(switch (e.key) {
                    AppThemeMode.system => Icons.brightness_auto_rounded,
                    AppThemeMode.light => Icons.light_mode_rounded,
                    AppThemeMode.dark => Icons.dark_mode_rounded,
                  }),
                ),
            ],
            selected: {prefs.themeMode},
            onSelectionChanged: (s) => n.update((p) => p.copyWith(themeMode: s.first)),
          ),
        ),
        SettingsHeader(l.sectionPreferences),
        SettingsTile(icon: Icons.language_rounded, title: l.settingsLanguage, onTap: () => context.push(Routes.settingsLanguage)),
        SettingsTile(icon: Icons.accessibility_new_rounded, title: l.settingsAccessibility, onTap: () => context.push(Routes.settingsAccessibility)),
        SettingsTile(icon: Icons.record_voice_over_rounded, title: l.settingsVoice, onTap: () => context.push(Routes.settingsVoice)),
        SettingsTile(icon: Icons.translate_rounded, title: l.settingsTranslation, onTap: () => context.push(Routes.settingsTranslation)),
        SettingsTile(icon: Icons.notifications_none_rounded, title: l.settingsNotifications, onTap: () => context.push(Routes.settingsNotifications)),
        SettingsHeader(l.sectionAccount),
        SettingsTile(icon: Icons.privacy_tip_outlined, title: l.settingsPrivacy, onTap: () => context.push(Routes.settingsPrivacy)),
        SettingsTile(icon: Icons.workspace_premium_outlined, title: l.settingsSubscription, onTap: () => context.push(Routes.premium)),
        SettingsTile(icon: Icons.info_outline_rounded, title: l.settingsAbout, onTap: () => context.push(Routes.about)),
      ]),
    );
  }
}
