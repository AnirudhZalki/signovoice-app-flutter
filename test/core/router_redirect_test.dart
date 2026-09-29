import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/routing/app_router.dart';
import 'package:signovoice/core/routing/routes.dart';
import 'package:signovoice/core/routing/session.dart';

void main() {
  test('booting always shows splash', () {
    expect(redirectFor(SessionStage.booting, Routes.home), Routes.splash);
    expect(redirectFor(SessionStage.booting, Routes.splash), isNull);
  });

  test('onboarding is enforced first', () {
    expect(redirectFor(SessionStage.onboarding, Routes.login), Routes.onboarding);
    expect(redirectFor(SessionStage.onboarding, Routes.onboarding), isNull);
  });

  test('unauthenticated users can only reach auth and legal pages', () {
    expect(redirectFor(SessionStage.needsAuth, Routes.home), Routes.login);
    expect(redirectFor(SessionStage.needsAuth, Routes.signToText), Routes.login);
    expect(redirectFor(SessionStage.needsAuth, Routes.register), isNull);
    expect(redirectFor(SessionStage.needsAuth, Routes.legalPrivacy), isNull);
  });

  test('profile setup and trial offer gate the app', () {
    expect(redirectFor(SessionStage.needsProfile, Routes.home), Routes.profileSetup);
    expect(redirectFor(SessionStage.trialOffer, Routes.home), Routes.trialOffer);
    expect(redirectFor(SessionStage.trialOffer, Routes.trialOffer), isNull);
    // The offer links to benefits and legal pages; those must stay reachable.
    expect(redirectFor(SessionStage.trialOffer, Routes.premiumBenefits), isNull);
    expect(redirectFor(SessionStage.trialOffer, Routes.legalTerms), isNull);
  });

  test('ready users are moved off entry screens but keep deep links', () {
    expect(redirectFor(SessionStage.ready, Routes.login), Routes.home);
    expect(redirectFor(SessionStage.ready, Routes.splash), Routes.home);
    expect(redirectFor(SessionStage.ready, '/learn/category/greetings'), isNull);
  });
}
