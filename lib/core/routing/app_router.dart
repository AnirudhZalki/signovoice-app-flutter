import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screens.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/dictionary/presentation/dictionary_entry_screen.dart';
import '../../features/dictionary/presentation/dictionary_screen.dart';
import '../../features/interpreter/presentation/call_screen.dart';
import '../../features/interpreter/presentation/feedback_screen.dart';
import '../../features/interpreter/presentation/live_screen.dart';
import '../../features/learning/presentation/category_screen.dart';
import '../../features/learning/presentation/learn_screen.dart';
import '../../features/learning/presentation/lesson_screen.dart';
import '../../features/learning/presentation/progress_screen.dart';
import '../../features/practice/presentation/practice_hub_screen.dart';
import '../../features/practice/presentation/practice_screen.dart';
import '../../features/subscription/domain/entitlement.dart';
import '../../features/subscription/presentation/manage_subscription_screen.dart';
import '../../features/subscription/presentation/premium_benefits_screen.dart';
import '../../features/subscription/presentation/subscription_providers.dart';
import '../../features/subscription/presentation/subscription_screen.dart';
import '../../features/subscription/presentation/trial_offer_screen.dart';
import '../../features/voice_translation/presentation/voice_to_sign_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/app_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/home/presentation/translate_hub_screen.dart';
import '../../features/sign_translation/presentation/sign_translation_controller.dart';
import '../../features/sign_translation/presentation/sign_translation_screen.dart';
import 'routes.dart';
import 'session.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

const _authPaths = {
  Routes.login,
  Routes.register,
  Routes.forgotPassword,
  Routes.phone,
  Routes.otp,
};

bool _isLegal(String loc) => loc.startsWith('/legal/');

/// Pure redirect rule (unit-tested): where should [location] go in [stage]?
String? redirectFor(SessionStage stage, String location) {
  switch (stage) {
    case SessionStage.booting:
      return location == Routes.splash ? null : Routes.splash;
    case SessionStage.onboarding:
      return location == Routes.onboarding ? null : Routes.onboarding;
    case SessionStage.needsAuth:
      return (_authPaths.contains(location) || _isLegal(location)) ? null : Routes.login;
    case SessionStage.needsProfile:
      return location == Routes.profileSetup || _isLegal(location) ? null : Routes.profileSetup;
    case SessionStage.trialOffer:
      return location == Routes.trialOffer || location == Routes.premiumBenefits || _isLegal(location) ? null : Routes.trialOffer;
    case SessionStage.ready:
      const gated = {
        Routes.splash,
        Routes.onboarding,
        Routes.login,
        Routes.register,
        Routes.forgotPassword,
        Routes.phone,
        Routes.otp,
        Routes.profileSetup,
        Routes.trialOffer,
      };
      return gated.contains(location) ? Routes.home : null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionStageProvider, (_, _) => refresh.value++);
  ref.listen(isPremiumProvider, (_, _) => refresh.value++); // re-run premium route guards
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(ref.read(sessionStageProvider), state.uri.path),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: Routes.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: Routes.phone, builder: (_, _) => const PhoneAuthScreen()),
      GoRoute(
        path: Routes.otp,
        redirect: (_, state) => state.extra is OtpArgs ? null : Routes.phone,
        builder: (_, state) => OtpScreen(args: state.extra! as OtpArgs),
      ),
      GoRoute(path: Routes.profileSetup, builder: (_, _) => const ProfileSetupScreen()),
      GoRoute(path: Routes.signToText, builder: (_, _) => const SignTranslationScreen(mode: SignMode.signToText)),
      GoRoute(path: Routes.signToVoice, builder: (_, _) => const SignTranslationScreen(mode: SignMode.signToVoice)),
      GoRoute(path: Routes.voiceToSign, builder: (_, _) => const VoiceToSignScreen()),
      GoRoute(path: Routes.history, builder: (_, _) => const HistoryScreen()),
      GoRoute(
        path: Routes.dictionary,
        builder: (_, state) => DictionaryScreen(
          initialCategory: state.uri.queryParameters['category'],
          bookmarksOnly: state.uri.queryParameters['saved'] == '1',
        ),
      ),
      GoRoute(path: Routes.dictionaryEntryPattern, builder: (_, state) => DictionaryEntryScreen(id: state.pathParameters['id']!)),
      GoRoute(path: Routes.learnCategoryPattern, builder: (_, state) => CategoryScreen(categoryId: state.pathParameters['id']!)),
      GoRoute(path: '/learn/lesson/:id', builder: (_, state) => LessonScreen(lessonId: state.pathParameters['id']!)),
      GoRoute(path: Routes.practiceHub, builder: (_, _) => const PracticeHubScreen()),
      GoRoute(path: Routes.practicePattern, builder: (_, state) => PracticeScreen(signId: state.pathParameters['id']!)),
      // Premium-only route: non-entitled users are sent to the upgrade page.
      GoRoute(
        path: Routes.progress,
        redirect: (_, _) => ref.read(entitlementProvider).allows(PremiumFeature.learningAnalytics) ? null : Routes.premium,
        builder: (_, _) => const ProgressScreen(),
      ),
      GoRoute(path: Routes.trialOffer, builder: (_, _) => const TrialOfferScreen()),
      GoRoute(path: Routes.premium, builder: (_, _) => const SubscriptionScreen()),
      GoRoute(path: Routes.premiumBenefits, builder: (_, _) => const PremiumBenefitsScreen()),
      GoRoute(path: Routes.manageSubscription, builder: (_, _) => const ManageSubscriptionScreen()),
      GoRoute(path: Routes.interpreterCall, builder: (_, _) => const CallScreen()),
      GoRoute(
        path: Routes.interpreterFeedback,
        redirect: (_, state) => state.extra is String ? null : Routes.live,
        builder: (_, state) => FeedbackScreen(callId: state.extra! as String),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.translate, builder: (_, _) => const TranslateHubScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.learn, builder: (_, _) => const LearnScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.live, builder: (_, _) => const LiveScreen())]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
