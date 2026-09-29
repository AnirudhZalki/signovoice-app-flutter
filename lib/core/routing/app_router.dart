import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screens.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/home/presentation/app_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/home/presentation/translate_hub_screen.dart';
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
      return location == Routes.trialOffer || _isLegal(location) ? null : Routes.trialOffer;
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.translate, builder: (_, _) => const TranslateHubScreen())]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
