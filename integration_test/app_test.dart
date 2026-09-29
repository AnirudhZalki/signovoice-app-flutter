// Device/emulator integration tests. Run with:
//   flutter test integration_test --dart-define-from-file=config/dev.json
//
// These use the real plugins but hermetic in-memory storage so runs are repeatable.
// Camera / microphone / purchase / interpreter steps need real hardware and accounts and are
// listed in docs/QA_CHECKLIST.md as manual device steps.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:signovoice/app.dart';
import 'package:signovoice/core/providers.dart';
import 'package:signovoice/core/services/storage.dart';

List<Override> _hermetic() => [
      keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
      collectionStoreProvider.overrideWithValue(InMemoryCollectionStore()),
      secureStoreProvider.overrideWithValue(InMemorySecureStore()),
    ];

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(ProviderScope(overrides: _hermetic(), child: const SignoVoiceApp()));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('guest journey', () {
    testWidgets('onboarding → guest → profile → home → dictionary', (tester) async {
      await _pumpApp(tester);

      // Onboarding: six pages, then "Get Started".
      expect(find.text('Communication Without Barriers'), findsOneWidget);
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Continue without an account (Firebase may be absent in a dev build, guest mode always works).
      await tester.tap(find.text('Continue without an account'));
      await tester.pumpAndSettle();

      // Profile setup: only the name is required.
      await tester.enterText(find.byType(TextFormField).first, 'Test User');
      await tester.ensureVisible(find.text('Save and continue'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      expect(find.text('How can we help you communicate today?'), findsOneWidget);

      // Learn → dictionary → search
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign dictionary'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'hello');
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsWidgets);
    });
  });
}
