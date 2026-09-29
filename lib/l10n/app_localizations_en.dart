// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SignoVoice';

  @override
  String get tagline => 'Breaking Barriers';

  @override
  String get coreIdea => 'One Gesture. One Voice. One Connection.';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get continueLabel => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get search => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get loading => 'Loading…';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get offlineBanner => 'You\'re offline. Some features are limited.';

  @override
  String get internetRequired =>
      'Internet connection required for this recognition mode.';

  @override
  String get emptyDefaultTitle => 'Nothing here yet';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get statusOn => 'On';

  @override
  String get statusOff => 'Off';

  @override
  String get openSettings => 'Open settings';

  @override
  String get grantPermission => 'Allow access';

  @override
  String get confidenceLabel => 'Confidence';

  @override
  String get confidenceHigh => 'High';

  @override
  String get confidenceMedium => 'Medium';

  @override
  String get confidenceLow => 'Low';

  @override
  String confidenceValue(String percent) {
    return 'Confidence $percent percent';
  }

  @override
  String get failureOffline =>
      'You\'re offline. Check your connection and try again.';

  @override
  String get failureNetwork =>
      'We couldn\'t reach the server. Please try again.';

  @override
  String get failureTimeout =>
      'This is taking longer than expected. Please try again.';

  @override
  String get failureUnauthorized => 'Please sign in again to continue.';

  @override
  String get failureNotConfigured =>
      'This service isn\'t set up yet. Please try again later.';

  @override
  String get failurePermissionDenied => 'Permission is needed to continue.';

  @override
  String get failurePermissionPermanent =>
      'Permission was denied. You can turn it on in your device settings.';

  @override
  String get failureModelUnavailable =>
      'Sign recognition is temporarily unavailable. Please try again.';

  @override
  String get failureServiceUnavailable =>
      'The service is temporarily unavailable. Please try again.';

  @override
  String get failureBilling =>
      'Purchases aren\'t available right now. Please try again later.';

  @override
  String get failureCancelled => 'Cancelled.';

  @override
  String get failureValidation => 'Please check the details and try again.';

  @override
  String get failureNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get failureRecentLogin =>
      'For your security, please sign in again, then retry.';

  @override
  String get failureLimit =>
      'You\'ve reached the limit for now. Please try again later.';

  @override
  String get failureUnknown => 'Something went wrong. Please try again.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Enter a valid email address';

  @override
  String get validationPassword =>
      'Use at least 8 characters with a letter and a number';

  @override
  String get validationPasswordMismatch => 'Passwords don\'t match';

  @override
  String get validationPhone => 'Enter a valid phone number with country code';

  @override
  String get validationOtp => 'Enter the 6-digit code';

  @override
  String get validationName => 'Enter at least 2 characters';

  @override
  String get modeSignToText => 'Sign → Text';

  @override
  String get modeVoiceToSign => 'Voice → Sign';

  @override
  String get modeSignToVoice => 'Sign → Voice';

  @override
  String get modeInterpreter => 'Live Interpreter';

  @override
  String get onb1Title => 'Communication Without Barriers';

  @override
  String get onb1Body =>
      'SignoVoice helps people who sign and people who don\'t know sign language understand each other, using AI, voice, text and live interpreters.';

  @override
  String get onb2Title => 'Translate Sign Language';

  @override
  String get onb2Body =>
      'Point your camera at a signer. Signs are recognised on your device and turned into text you can read or hear.';

  @override
  String get onb3Title => 'Talk Through Voice & Text';

  @override
  String get onb3Body =>
      'Speak or type and see the matching signs. Turn recognised signs into spoken words in your language.';

  @override
  String get onb4Title => 'Learn Indian Sign Language';

  @override
  String get onb4Body =>
      'Short lessons, a searchable dictionary and camera practice with instant feedback.';

  @override
  String get onb5Title => 'Connect With Interpreters';

  @override
  String get onb5Body =>
      'Request a live sign-language interpreter by video, audio or chat when you need a human.';

  @override
  String get onb6Title => 'Your Privacy Matters';

  @override
  String get onb6Body =>
      'The camera is used only while a translation screen is open, and sign recognition runs on your device. You choose what is saved.';

  @override
  String get getStarted => 'Get Started';

  @override
  String pageOf(String current, String total) {
    return 'Page $current of $total';
  }

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Sign in to sync your progress and unlock all features.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get createAccount => 'Create account';

  @override
  String get fullName => 'Full name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotBody =>
      'Enter your email and we\'ll send you a link to choose a new password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetLinkSent =>
      'If an account exists for that email, a reset link is on its way.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithPhone => 'Continue with phone';

  @override
  String get continueAsGuest => 'Continue without an account';

  @override
  String get guestNote =>
      'Guest mode keeps everything on this device. Interpreters, sync and subscriptions need an account.';

  @override
  String get orDivider => 'or';

  @override
  String get noAccount => 'New here? Create an account';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get agreeTerms => 'I agree to the Terms of Service and Privacy Policy';

  @override
  String get mustAgreeTerms =>
      'Please accept the Terms and Privacy Policy to continue';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get backendMissingBanner =>
      'Account sign-in isn\'t available in this build. You can still use SignoVoice without an account.';

  @override
  String get phoneTitle => 'Sign in with your phone';

  @override
  String get phoneBody =>
      'We\'ll text you a 6-digit code. Standard message rates may apply.';

  @override
  String get phoneNumber => 'Phone number (with country code)';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpSentTo(String phone) {
    return 'We sent a 6-digit code to $phone';
  }

  @override
  String get verifyCode => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(String seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get authEmailInUse => 'An account already exists for this email.';

  @override
  String get authWeakPassword => 'That password is too weak.';

  @override
  String get authTooMany =>
      'Too many attempts. Please wait a few minutes and try again.';

  @override
  String get authInvalidCode => 'That code is not correct or has expired.';

  @override
  String get authDisabled => 'This account has been disabled.';

  @override
  String get googleSignInCancelled => 'Google sign-in was cancelled.';

  @override
  String get profileSetupTitle => 'Set up your profile';

  @override
  String get profileSetupSubtitle =>
      'Only your name is needed. Everything else is optional and can be changed later.';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get preferredLanguage => 'Preferred language';

  @override
  String get preferredMode => 'How do you mostly communicate?';

  @override
  String get accessibilityOptional => 'Accessibility preferences (optional)';

  @override
  String get needDeaf => 'I am Deaf';

  @override
  String get needHardOfHearing => 'I am hard of hearing';

  @override
  String get needSpeech => 'I have a speech difference';

  @override
  String get needLowVision => 'I have low vision';

  @override
  String get needMotor => 'I prefer larger touch targets';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get langEnglish => 'English';

  @override
  String get langHindi => 'हिन्दी (Hindi)';

  @override
  String get langKannada => 'ಕನ್ನಡ (Kannada)';

  @override
  String get langSystem => 'Device language';

  @override
  String get navHome => 'Home';

  @override
  String get navTranslate => 'Translate';

  @override
  String get navLearn => 'Learn';

  @override
  String get navLive => 'Live';

  @override
  String get navProfile => 'Profile';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get heroTitle => 'How can we help you communicate today?';

  @override
  String get heroCta => 'Start translating';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get qaSignToTextSub => 'Turn signs into text';

  @override
  String get qaVoiceToSignSub => 'Speak and see signs';

  @override
  String get qaSignToVoiceSub => 'Hear signs spoken aloud';

  @override
  String get qaInterpreterSub => 'Connect with a person';

  @override
  String get qaLearnSub => 'Lessons and dictionary';

  @override
  String get qaPracticeSub => 'Practise with your camera';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get openProfileTooltip => 'Open profile';

  @override
  String get translateTabTitle => 'What would you like to do?';

  @override
  String get translateTabSubtitle => 'Choose a way to communicate.';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get signStatusReady => 'On-device model ready';

  @override
  String get signStatusOnline => 'Online recognition';

  @override
  String get signStatusLoading => 'Loading model…';

  @override
  String get signStatusUnavailable => 'Model unavailable';

  @override
  String get showHandHint => 'Show your hand to the camera';

  @override
  String get handDetected => 'Hand detected';

  @override
  String get currentSign => 'Current sign';

  @override
  String get translationLabel => 'Translation';

  @override
  String get translationPlaceholder =>
      'Recognised signs will appear here as text.';

  @override
  String get recognisedSigns => 'Recognised signs';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get speak => 'Speak';

  @override
  String get stopSpeaking => 'Stop speaking';

  @override
  String get replay => 'Replay';

  @override
  String get play => 'Play';

  @override
  String get flipCamera => 'Flip camera';

  @override
  String get flashOn => 'Turn flash on';

  @override
  String get flashOff => 'Turn flash off';

  @override
  String get historyTitle => 'History';

  @override
  String get cameraPermTitle => 'Camera access needed';

  @override
  String get cameraPermBody =>
      'SignoVoice uses your camera only on this screen to see hands. Hand positions are analysed on your device. Video is never recorded or uploaded.';

  @override
  String get micPermTitle => 'Microphone access needed';

  @override
  String get micPermBody =>
      'SignoVoice listens only while you tap the microphone button, to turn your speech into text. Speech recognition is provided by your device\'s speech service and may need an internet connection.';

  @override
  String get cameraInitError =>
      'The camera couldn\'t start. Close other apps that use the camera and try again.';

  @override
  String get handTrackingUnsupported =>
      'Hand tracking isn\'t supported on this device yet.';

  @override
  String signsLeftToday(String count) {
    return '$count signs left today';
  }

  @override
  String get limitReachedTitle => 'Daily free limit reached';

  @override
  String get limitReachedBody =>
      'Upgrade for unlimited sign recognition, or come back tomorrow.';

  @override
  String get seePremium => 'See Premium';

  @override
  String get saveToHistory => 'Save to history';

  @override
  String get savedToHistory => 'Saved to history';

  @override
  String get historyOffHint => 'History is turned off in Privacy settings.';

  @override
  String get outputLanguage => 'Output language';

  @override
  String get voiceSettings => 'Voice settings';

  @override
  String get voiceSpeed => 'Speaking speed';

  @override
  String get voiceLanguage => 'Voice language';

  @override
  String get voiceSelect => 'Voice';

  @override
  String get voiceDefault => 'Default voice';

  @override
  String get voiceNoneForLanguage =>
      'No voice for this language is installed on your device. Install one in your device\'s text-to-speech settings.';

  @override
  String get pausedLabel => 'Paused';

  @override
  String get listeningLabel => 'Listening…';

  @override
  String get recognitionPaused => 'Recognition paused';

  @override
  String get scanningHand => 'Looking for a hand';

  @override
  String get noSignYet => 'No sign yet';

  @override
  String liveTranslation(String text) {
    return 'Live translation: $text';
  }

  @override
  String get clearedAnnouncement => 'Cleared';

  @override
  String recognisedAnnouncement(String sign) {
    return 'Recognised $sign';
  }

  @override
  String get historySearchHint => 'Search history';

  @override
  String get historyEmptyTitle => 'No history yet';

  @override
  String get historyEmptyBody =>
      'Translations you save will appear here, only on this device.';

  @override
  String get historyNoResults => 'No matches for your search';

  @override
  String get historyClearAll => 'Clear all history';

  @override
  String get historyClearTitle => 'Clear all history?';

  @override
  String get historyClearBody =>
      'This permanently deletes every saved translation from this device.';

  @override
  String get historyDeleted => 'Entry deleted';

  @override
  String get historyCleared => 'History cleared';

  @override
  String historyHidden(String count) {
    return '$count older entries are hidden on the free plan';
  }

  @override
  String get historyHiddenTitle => 'Full history is a Premium feature';

  @override
  String durationSeconds(String seconds) {
    return '${seconds}s';
  }

  @override
  String inputTypeLabel(String type) {
    return 'Input: $type';
  }
}
