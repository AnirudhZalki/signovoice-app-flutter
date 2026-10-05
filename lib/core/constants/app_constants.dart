class AppConstants {
  const AppConstants._();

  static const String appName = 'SignoVoice';
  static const String tagline = 'Breaking Barriers';
  static const String coreIdea = 'One Gesture. One Voice. One Connection.';

  // Recognition pipeline (must match the trained model; see assets/models/labels.json).
  static const int sequenceLength = 30;
  static const int featureCount = 63;
  static const Duration frameInterval = Duration(milliseconds: 50); // ~20 fps
  static const Duration inferenceInterval = Duration(milliseconds: 350);
  static const double defaultConfidenceThreshold = 0.70;
  static const double minHandPresence = 0.6;

  // Free plan limits (premium = unlimited). freeDailyTranslations counts recognised signs per day.
  static const int freeDailyTranslations = 50;
  static const int freeHistoryEntries = 30;

  static const Duration trialLength = Duration(days: 30);
  static const Duration networkTimeout = Duration(seconds: 15);
}

/// Keys used with the key-value store.
class PrefKeys {
  const PrefKeys._();
  static const onboardingDone = 'onboarding_done';
  static const profileSetupDone = 'profile_setup_done';
  static const preferences = 'user_preferences_v1';
  static const guestMode = 'guest_mode';
  static const usagePrefix = 'usage_';
}

/// Android application id (also used for Play Store deep links).
const String kApplicationId = 'com.anirudhzalki.signovoice';
