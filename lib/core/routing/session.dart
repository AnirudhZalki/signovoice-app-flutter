import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/profile/presentation/profile_controller.dart';
import '../constants/app_constants.dart';
import '../providers.dart';

enum SessionStage { booting, onboarding, needsAuth, needsProfile, trialOffer, ready }

class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.read(keyValueStoreProvider).getBool(PrefKeys.onboardingDone) ?? false;

  Future<void> complete() async {
    await ref.read(keyValueStoreProvider).setBool(PrefKeys.onboardingDone, true);
    state = true;
  }
}

final onboardingDoneProvider = NotifierProvider<OnboardingController, bool>(OnboardingController.new);

/// The animated intro is shown once per launch. The splash screen calls [finish] when its
/// animation has played (immediately with reduced motion); until then the session is "booting".
class IntroController extends Notifier<bool> {
  @override
  bool build() => false;

  void finish() => state = true;
}

final introDoneProvider = NotifierProvider<IntroController, bool>(IntroController.new);

/// Per-account flag: the free-trial offer is shown at most once automatically.
class TrialOfferSeenController extends Notifier<bool> {
  String get _key => '${PrefKeys.trialOfferSeen}_${ref.read(authControllerProvider).uid}';

  @override
  bool build() {
    ref.watch(authControllerProvider.select((a) => a.uid));
    return ref.read(keyValueStoreProvider).getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    await ref.read(keyValueStoreProvider).setBool(_key, true);
    state = true;
  }
}

final trialOfferSeenProvider = NotifierProvider<TrialOfferSeenController, bool>(TrialOfferSeenController.new);

/// Single source of truth for where the person should be in the app.
final sessionStageProvider = Provider<SessionStage>((ref) {
  final auth = ref.watch(authControllerProvider);
  final introDone = ref.watch(introDoneProvider);
  if (!introDone || auth.status == AuthStatus.unknown) return SessionStage.booting;
  if (!ref.watch(onboardingDoneProvider)) return SessionStage.onboarding;
  if (auth.status == AuthStatus.unauthenticated) return SessionStage.needsAuth;

  final profile = ref.watch(profileProvider);
  if (profile.isLoading && !profile.hasValue) return SessionStage.booting;
  if (profile.value == null) return SessionStage.needsProfile;

  if (auth.isSignedIn && !ref.watch(trialOfferSeenProvider)) return SessionStage.trialOffer;
  return SessionStage.ready;
});
