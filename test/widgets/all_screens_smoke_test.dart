import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:signovoice/core/routing/routes.dart';
import 'package:signovoice/features/profile/domain/user_preferences.dart';

import 'test_harness.dart';

/// Opens every screen in dark mode with large text and asserts nothing throws or overflows.
/// Camera/billing/TTS/etc. are unavailable in tests, so this also exercises the error/empty states.
void main() {
  final routes = <String, String>{
    Routes.notifications: 'Notifications',
    Routes.history: 'History',
    Routes.settings: 'Settings',
    Routes.settingsLanguage: 'Language',
    Routes.settingsAccessibility: 'Accessibility',
    Routes.settingsVoice: 'Voice',
    Routes.settingsTranslation: 'Translation',
    Routes.settingsNotifications: 'Notification settings',
    Routes.settingsPrivacy: 'Privacy & data',
    Routes.settingsSecurity: 'Security',
    Routes.deleteAccount: 'Delete your account',
    Routes.help: 'Help & support',
    Routes.about: 'About SignoVoice',
    Routes.legalPrivacy: 'Privacy Policy',
    Routes.legalTerms: 'Terms of Service',
    Routes.dictionary: 'Sign dictionary',
    '${Routes.dictionary}?saved=1': 'Saved signs',
    Routes.dictionaryEntry('hospital'): 'Hospital',
    Routes.dictionaryEntry('hello'): 'Hello',
    Routes.learnCategory('greetings'): 'Greetings',
    '/learn/lesson/greetings-0': 'Hello',
    Routes.practiceHub: 'Practice',
    Routes.practice('hello'): 'Show the sign for Hello',
    Routes.signToText: "couldn't start",
    Routes.signToVoice: "couldn't start",
    Routes.voiceToSign: 'Voice → Sign',
    Routes.premium: 'Unlock the full SignoVoice experience',
    Routes.premiumBenefits: 'Premium benefits',
    Routes.manageSubscription: 'Manage subscription',
    Routes.profileEdit: 'Set up your profile',
    Routes.interpreterCall: 'Live interpreter',
  };

  for (final dark in [false, true]) {
    testWidgets('every screen renders (${dark ? 'dark' : 'light'}, 1.6x text, no exceptions)', (tester) async {
      final h = Harness(prefs: UserPreferences(themeMode: dark ? AppThemeMode.dark : AppThemeMode.light, textScale: 1.6));
      await h.pump(tester, size: const Size(390, 844));
      final failures = <String>[];

      for (final e in routes.entries) {
        final ctx = tester.element(find.byType(Scaffold).first);
        GoRouter.of(ctx).push(e.key);
        try {
          await pumpUntilFound(tester, find.textContaining(e.value), timeout: const Duration(seconds: 4));
        } catch (_) {
          failures.add('${e.key}: expected text "${e.value}" not shown');
        }
        final ex = tester.takeException();
        if (ex != null) failures.add('${e.key}: $ex');
        // Back to the home shell for the next route.
        GoRouter.of(tester.element(find.byType(Scaffold).last)).go(Routes.home);
        await settle(tester, frames: 8);
        tester.takeException();
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  }
}
