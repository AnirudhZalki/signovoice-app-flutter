import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/features/profile/domain/user_preferences.dart';

import 'test_harness.dart';

void main() {
  testWidgets('first launch: splash → onboarding (6 pages) → login → guest → profile setup → home', (tester) async {
    final h = Harness(onboarded: false, guest: false, profileDone: false);
    // Tall surface: the whole profile form is visible, so no scrolling is needed to tap.
    await h.pump(tester, size: const Size(412, 1800));

    // Onboarding
    expect(find.text('Communication Without Barriers'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Next'));
      await settle(tester, frames: 10);
    }
    expect(find.text('Your Privacy Matters'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await settle(tester);

    // Login (Firebase not configured in tests → explains, offers guest)
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.textContaining("isn't available in this build"), findsOneWidget);
    await tester.tap(find.text('Continue without an account'));
    await settle(tester);

    // Profile setup: only the name is required
    expect(find.text('Set up your profile'), findsOneWidget);
    await scrollTo(tester, find.text('Save and continue'));
    await tester.tap(find.text('Save and continue'));
    await settle(tester);
    // An empty name is "required"; a one-letter name is "too short".
    expect(find.text('This field is required'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'A');
    await scrollTo(tester, find.text('Save and continue'));
    await tester.tap(find.text('Save and continue'));
    await pumpUntilFound(tester, find.text('Enter at least 2 characters'), timeout: const Duration(seconds: 3));
    expect(find.text('Enter at least 2 characters'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Asha');
    await scrollTo(tester, find.text('Save and continue'));
    await tester.tap(find.text('Save and continue'));
    await pumpUntilFound(tester, find.text('How can we help you communicate today?'));

    // Home
    expect(find.textContaining('Asha'), findsWidgets);
    expect(find.text('How can we help you communicate today?'), findsOneWidget);
    expect(find.text('Sign → Text'), findsWidgets);
  });

  testWidgets('returning guest lands on Home and can move between all four tabs', (tester) async {
    final h = Harness();
    await h.pump(tester);
    // Home now introduces the app and holds every mode (the separate Translate tab is gone).
    expect(find.text('What is SignoVoice?'), findsOneWidget);
    expect(find.text('Translate'), findsOneWidget); // section header only, not a tab
    expect(find.text('Sign → Text'), findsWidgets);

    await tester.tap(find.text('Learn').last);
    await pumpUntilFound(tester, find.text('Topics'));
    expect(find.text('Learn Indian Sign Language'), findsWidgets);
    await scrollTo(tester, find.text('Greetings'));
    expect(find.text('Greetings'), findsOneWidget);

    await tester.tap(find.text('Live').last);
    await settle(tester);
    expect(find.text('Live interpreter'), findsWidgets);
    // Guests are told an account is needed; no fake interpreters.
    expect(find.text('Sign in to request an interpreter'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await settle(tester);
    expect(find.text('Asha'), findsWidgets); // seeded profile name
    expect(find.text('Free plan'), findsWidgets);
    await scrollTo(tester, find.text('Create an account'));
    expect(find.text('Create an account'), findsOneWidget); // guests are offered sign-up, not sign-out
  });

  testWidgets('dictionary search finds Hindi words and honestly flags missing videos', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.text('Learn').last);
    await pumpUntilFound(tester, find.text('Sign dictionary'));
    await tester.tap(find.text('Sign dictionary'));
    await pumpUntilFound(tester, find.byType(TextField));

    await tester.enterText(find.byType(TextField).first, 'hospital');
    await pumpUntilFound(tester, find.text('Hospital'));
    expect(find.text('Sign video not available yet'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, 'अस्पताल');
    await pumpUntilFound(tester, find.text('Hospital'));

    await tester.enterText(find.byType(TextField).first, 'zzzzzz');
    await pumpUntilFound(tester, find.text('No signs match your search.'));
  });

  testWidgets('Voice → Sign converts typed text to signs and flags unknown words', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await scrollTo(tester, find.text('Voice → Sign').first); // Home lists it below the intro
    await tester.tap(find.text('Voice → Sign').first);
    await settle(tester);
    expect(find.text('Voice → Sign'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Where is the hospital zorblax');
    await pumpUntilFound(tester, find.text('Signs'));
    // Full-screen stage shows one sign at a time; every word is a chip in the panel.
    await scrollTo(tester, find.widgetWithText(ChoiceChip, 'Hospital'));
    expect(find.widgetWithText(ChoiceChip, 'Hospital'), findsOneWidget);
    expect(find.textContaining("1 word(s) don't have a sign"), findsOneWidget);
    // Jump to the word that has no sign: the stage says so plainly.
    await tester.tap(find.widgetWithText(ChoiceChip, 'zorblax'));
    await settle(tester);
    expect(find.text('No sign available yet'), findsWidgets);
  });

  testWidgets('Kannada UI: strings are localised, nothing hard-coded on Home', (tester) async {
    final h = Harness(prefs: const UserPreferences(localeCode: 'kn'));
    await h.pump(tester);
    expect(find.text('ಇಂದು ಸಂವಹನ ಮಾಡಲು ನಾವು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು?'), findsOneWidget);
    expect(find.text('ಸೈನೋವಾಯ್ಸ್ ಎಂದರೇನು?'), findsOneWidget);
  });

  testWidgets('Hindi UI works too', (tester) async {
    final h = Harness(prefs: const UserPreferences(localeCode: 'hi'));
    await h.pump(tester);
    expect(find.text('आज हम आपको संवाद करने में कैसे मदद कर सकते हैं?'), findsOneWidget);
  });

  testWidgets('dark mode + high contrast render without errors', (tester) async {
    final h = Harness(prefs: const UserPreferences(themeMode: AppThemeMode.dark, highContrast: true));
    await h.pump(tester);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold, isNotNull);
    final ctx = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(ctx).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('very large text (2x system + in-app 1.6x) stays usable: no overflow on core screens', (tester) async {
    final h = Harness(prefs: const UserPreferences(textScale: 1.6));
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await h.pump(tester, size: const Size(360, 740));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Learn').last);
    await pumpUntilFound(tester, find.text('Learn Indian Sign Language'));
    await scrollTo(tester, find.text('Topics'));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Profile').last);
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings: switching theme and language updates the app immediately', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.text('Profile').last);
    await settle(tester);
    await tester.tap(find.text('Language'));
    await settle(tester);
    await tester.tap(find.text('हिन्दी (Hindi)'));
    await settle(tester);
    expect(find.text('भाषा'), findsWidgets);
    // persisted
    expect(h.kv.getString('user_preferences_v1'), contains('"localeCode":"hi"'));
  });

  testWidgets('accessibility: home meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    final h = Harness();
    await h.pump(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
