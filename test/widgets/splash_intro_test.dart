import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/app.dart';

import 'test_harness.dart';

void main() {
  testWidgets('animated intro plays, then hands over to the app', (tester) async {
    final h = Harness(skipIntro: false);
    tester.view.physicalSize = const Size(412, 892) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(overrides: h.overrides, child: const SignoVoiceApp()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('SignoVoice'), findsOneWidget);
    expect(find.byType(Chip), findsWidgets);

    await tester.pump(const Duration(seconds: 4));
    await settle(tester);
    // Onboarding was completed by the harness and the person is a guest → Home.
    expect(find.byType(Chip), findsNothing);
    expect(find.text('SignoVoice'), findsNothing);
  });
}
