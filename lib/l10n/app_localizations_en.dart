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
  String get recentActivity => 'Recent activity';

  @override
  String get seeAll => 'See all';

  @override
  String get noRecentActivity => 'Your saved translations will appear here.';

  @override
  String get todayUsage => 'Today';

  @override
  String get aiShortcutTitle => 'Advanced AI translation';

  @override
  String get aiShortcutBody => 'Smoother sentences from an online AI service.';

  @override
  String get aiShortcutIncluded => 'Included with your plan';

  @override
  String get aiShortcutPremium => 'Premium feature';

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

  @override
  String get catAlphabet => 'Alphabet';

  @override
  String get catNumbers => 'Numbers';

  @override
  String get catGreetings => 'Greetings';

  @override
  String get catDaily => 'Daily Conversation';

  @override
  String get catFamily => 'Family';

  @override
  String get catFood => 'Food';

  @override
  String get catEducation => 'Education';

  @override
  String get catHealthcare => 'Healthcare';

  @override
  String get catTravel => 'Travel';

  @override
  String get catEmergency => 'Emergency';

  @override
  String get catWorkplace => 'Workplace';

  @override
  String get catPhrases => 'Common Phrases';

  @override
  String get learnTitle => 'Learn Indian Sign Language';

  @override
  String get learnSubtitle => 'Short lessons, one topic at a time.';

  @override
  String get yourProgress => 'Your progress';

  @override
  String xpValue(String xp) {
    return '$xp XP';
  }

  @override
  String levelValue(String level) {
    return 'Level $level';
  }

  @override
  String streakValue(String days) {
    return '$days-day streak';
  }

  @override
  String learnedOf(String learned, String total) {
    return '$learned of $total signs learned';
  }

  @override
  String get topics => 'Topics';

  @override
  String lessonN(String n) {
    return 'Lesson $n';
  }

  @override
  String lessonProgress(String done, String total) {
    return '$done of $total learned';
  }

  @override
  String get lessonComplete => 'Lesson complete';

  @override
  String lessonCompleteBody(String count) {
    return 'Nice work. You have learned $count signs in this lesson.';
  }

  @override
  String get markLearned => 'I know this sign';

  @override
  String get signLearned => 'Learned';

  @override
  String get savedSigns => 'Saved signs';

  @override
  String get bookmarkAdd => 'Save this sign';

  @override
  String get bookmarkRemove => 'Remove from saved';

  @override
  String get noSavedSigns => 'You haven\'t saved any signs yet.';

  @override
  String get previous => 'Previous';

  @override
  String get finishLesson => 'Finish lesson';

  @override
  String signOfTotal(String current, String total) {
    return 'Sign $current of $total';
  }

  @override
  String get learningAnalytics => 'Learning analytics';

  @override
  String get analyticsLocked =>
      'Detailed learning analytics is a Premium feature.';

  @override
  String get analyticsLockedBody =>
      'See accuracy, completion by topic and your activity over the last week.';

  @override
  String get accuracyLabel => 'Practice accuracy';

  @override
  String get attemptsLabel => 'Attempts';

  @override
  String get completionByTopic => 'Completion by topic';

  @override
  String get lastSevenDays => 'Last 7 days';

  @override
  String activityDay(String count, String day) {
    return '$day: $count actions';
  }

  @override
  String get badgesTitle => 'Badges';

  @override
  String get badgeLocked => 'Not earned yet';

  @override
  String get badgeFirstSign => 'First sign learned';

  @override
  String get badgeTenSigns => '10 signs learned';

  @override
  String get badgeFirstCorrect => 'First correct practice';

  @override
  String get badgeTenCorrect => '10 correct practices';

  @override
  String get badgeStreak3 => '3-day streak';

  @override
  String get badgeStreak7 => '7-day streak';

  @override
  String get dictionaryTitle => 'Sign dictionary';

  @override
  String get dictionarySearchHint => 'Search signs, e.g. Hello or Water';

  @override
  String get allCategories => 'All';

  @override
  String get dictionaryNoResults => 'No signs match your search.';

  @override
  String get signVideoUnavailable => 'Sign video not available yet';

  @override
  String get signVideoUnavailableBody =>
      'This sign is listed, but its video hasn\'t been added yet.';

  @override
  String get hasVideo => 'Video available';

  @override
  String get listenPronunciation => 'Listen';

  @override
  String get practiceThisSign => 'Practise this sign';

  @override
  String practiceNotAvailable(String count) {
    return 'Camera practice isn\'t available for this sign yet. The recogniser currently knows $count signs.';
  }

  @override
  String get meaningLabel => 'Meaning';

  @override
  String get categoryLabel => 'Topic';

  @override
  String get playVideo => 'Play video';

  @override
  String get pauseVideo => 'Pause video';

  @override
  String get videoError => 'The video couldn\'t be played.';

  @override
  String get entryNotFound => 'That sign couldn\'t be found.';

  @override
  String get practiceHubTitle => 'Practice';

  @override
  String get practiceIntro =>
      'Show a sign to your camera. Your device checks it and gives instant feedback.';

  @override
  String get practiceAvailableSigns => 'Signs you can practise now';

  @override
  String practicePrompt(String sign) {
    return 'Show the sign for $sign';
  }

  @override
  String get startPractice => 'Start';

  @override
  String get getReady => 'Get ready…';

  @override
  String get signNow => 'Sign now';

  @override
  String get checking => 'Checking…';

  @override
  String get recognisedLabel => 'Recognised';

  @override
  String get resultCorrect => 'Correct';

  @override
  String get resultTryAgain => 'Try again';

  @override
  String get resultNoHand =>
      'We couldn\'t see your hand clearly. Try again with better light.';

  @override
  String get nextSign => 'Next sign';

  @override
  String xpEarned(String xp) {
    return '+$xp XP';
  }

  @override
  String get watchReference => 'Watch the sign';

  @override
  String countdownNumber(String n) {
    return '$n';
  }

  @override
  String get vsTitle => 'Voice → Sign';

  @override
  String get vsHint => 'Tap the microphone and speak, or type below.';

  @override
  String get typeHere => 'Type or paste text';

  @override
  String get showSigns => 'Show signs';

  @override
  String get tapToSpeak => 'Tap to speak';

  @override
  String get tapToStop => 'Tap to stop';

  @override
  String get speechUnavailable =>
      'Speech recognition isn\'t available on this device. You can type instead.';

  @override
  String get speechNothingHeard => 'We didn\'t hear anything. Try again.';

  @override
  String get speechLanguage => 'Speech language';

  @override
  String get signsForText => 'Signs';

  @override
  String get noSignYetForWord => 'No sign available yet';

  @override
  String missingSignsNote(String count) {
    return '$count word(s) don\'t have a sign in the dictionary yet.';
  }

  @override
  String get heardLabel => 'What we heard';

  @override
  String get liveTitle => 'Live interpreter';

  @override
  String get liveIntro =>
      'Connect with a human sign-language interpreter by video, audio or chat.';

  @override
  String get findInterpreter => 'Available interpreters';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusBusy => 'Busy';

  @override
  String get statusOffline => 'Offline';

  @override
  String ratingValue(String count, String rating) {
    return '$rating ($count ratings)';
  }

  @override
  String get noRatingsYet => 'No ratings yet';

  @override
  String get requestInterpreter => 'Request an interpreter';

  @override
  String get requestVideoCall => 'Video call';

  @override
  String get requestAudioCall => 'Audio call';

  @override
  String get noteOptional => 'Note for the interpreter (optional)';

  @override
  String get noInterpretersNow =>
      'No interpreters are available right now. Try again in a few minutes.';

  @override
  String get interpreterNotConfigured =>
      'The live interpreter service isn\'t set up in this build yet.';

  @override
  String get signInForInterpreter => 'Sign in to request an interpreter';

  @override
  String get signInForInterpreterBody =>
      'Interpreter sessions need an account so calls can be connected and rated.';

  @override
  String get callRequesting => 'Sending your request…';

  @override
  String get callWaiting => 'Waiting for an interpreter…';

  @override
  String callQueue(String n) {
    return 'You are number $n in the queue';
  }

  @override
  String get callConnecting => 'Connecting…';

  @override
  String get callConnected => 'Connected';

  @override
  String get callReconnecting => 'Reconnecting…';

  @override
  String get callEnded => 'Call ended';

  @override
  String get callFailedTitle => 'The call couldn\'t be completed';

  @override
  String get callDeclined =>
      'No interpreter could take your request. Please try again.';

  @override
  String get callExpired =>
      'No interpreter accepted in time. Please try again.';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get muteMic => 'Mute microphone';

  @override
  String get unmuteMic => 'Unmute microphone';

  @override
  String get cameraOffAction => 'Turn camera off';

  @override
  String get cameraOnAction => 'Turn camera on';

  @override
  String get endCall => 'End call';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatHint => 'Type a message';

  @override
  String get sendMessage => 'Send';

  @override
  String get reportIssue => 'Report an issue';

  @override
  String get issueAudio => 'Audio problem';

  @override
  String get issueVideo => 'Video problem';

  @override
  String get issueInterpreter => 'Interpreter conduct';

  @override
  String get issueConnection => 'Connection problem';

  @override
  String get issueOther => 'Something else';

  @override
  String get issueDescribe => 'Tell us more (optional)';

  @override
  String get issueSent => 'Thanks. We\'ll look into it.';

  @override
  String get feedbackTitle => 'How was your call?';

  @override
  String feedbackStars(String n) {
    return '$n of 5 stars';
  }

  @override
  String get feedbackComment => 'Comments (optional)';

  @override
  String get submitFeedback => 'Submit feedback';

  @override
  String get feedbackThanks => 'Thank you for your feedback.';

  @override
  String get skipFeedback => 'Skip';

  @override
  String callDuration(String time) {
    return 'Duration $time';
  }

  @override
  String interpreterConnectedTo(String name) {
    return 'In a call with $name';
  }

  @override
  String get waitingForVideo => 'Waiting for the interpreter\'s video…';

  @override
  String get audioCallActive => 'Audio call in progress';

  @override
  String get devRoomTitle => 'Test room (debug build only)';

  @override
  String get devRoomBody =>
      'Joins the LiveKit room your development token was issued for, so you can test video, audio and chat without the backend.';

  @override
  String get premiumHeader => 'Unlock the full SignoVoice experience';

  @override
  String get premiumSubheader =>
      'Free stays genuinely useful. Premium removes limits and adds deeper tools.';

  @override
  String get freePlan => 'Free';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get featRecognition => 'Sign recognition';

  @override
  String featRecognitionFree(String count) {
    return 'Up to $count signs a day';
  }

  @override
  String get featUnlimited => 'Unlimited';

  @override
  String get featHistory => 'Translation history';

  @override
  String featHistoryFree(String count) {
    return 'Latest $count entries';
  }

  @override
  String get featFullHistory => 'Full history';

  @override
  String get featAi => 'Advanced AI translation';

  @override
  String get featNotIncluded => 'Not included';

  @override
  String get featIncludedOnline => 'Included (needs internet)';

  @override
  String get featAnalytics => 'Learning analytics';

  @override
  String get featBasicProgress => 'Basic progress';

  @override
  String get featFullAnalytics => 'Detailed analytics';

  @override
  String get featCore => 'Lessons, dictionary, practice, voice → sign';

  @override
  String get featIncluded => 'Included';

  @override
  String get trialOneMonthFree => '1 month free';

  @override
  String trialThenPrice(String period, String price) {
    return 'Then $price per $period';
  }

  @override
  String get periodMonth => 'month';

  @override
  String get periodYear => 'year';

  @override
  String get periodWeek => 'week';

  @override
  String get periodDay => 'day';

  @override
  String get renewsAutomatically => 'Renews automatically';

  @override
  String get cancelAnytime =>
      'Cancel anytime in your store subscription settings';

  @override
  String trialTerms(String period, String price) {
    return 'Your first month is free. When it ends, your subscription renews automatically at $price per $period unless you cancel before the trial ends. Cancel any time in Google Play: Menu › Payments & subscriptions › Subscriptions. You will always see the final price and confirm in Google Play before you are charged.';
  }

  @override
  String subscribeTerms(String period, String price) {
    return 'Your subscription renews automatically at $price per $period until you cancel. Cancel any time in Google Play: Menu › Payments & subscriptions › Subscriptions. You will confirm the final price in Google Play before you are charged.';
  }

  @override
  String get priceShownAtCheckout =>
      'The price is shown by Google Play before you confirm.';

  @override
  String get startFreeTrial => 'Start free trial';

  @override
  String get subscribeNow => 'Subscribe';

  @override
  String get notNow => 'Not now';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planYearly => 'Yearly';

  @override
  String planPerPeriod(String period, String price) {
    return '$price / $period';
  }

  @override
  String get planFirstFree => 'First month free';

  @override
  String get trialOfferTitle => 'Your first month is free';

  @override
  String get trialOfferBody => 'Try every Premium feature for a month.';

  @override
  String trialOfferPrice(String period, String price) {
    return '$price per $period after your trial';
  }

  @override
  String get trialNotAvailable =>
      'A free trial isn\'t available for this account. You can still subscribe from the Premium page.';

  @override
  String get signInToSubscribe => 'Sign in to start your free trial';

  @override
  String get purchasePending =>
      'Your payment is pending. Premium unlocks once it completes.';

  @override
  String get purchaseVerifying => 'Verifying your purchase…';

  @override
  String get purchaseSuccess => 'Premium is active. Thank you!';

  @override
  String get purchaseCancelled =>
      'Purchase cancelled. You haven\'t been charged.';

  @override
  String get purchaseNeedsVerification =>
      'Your purchase went through, but we couldn\'t verify it yet. Nothing is lost — tap retry.';

  @override
  String get billingUnavailableMsg =>
      'Google Play purchases aren\'t available on this device right now.';

  @override
  String get productsUnavailableMsg =>
      'Subscription plans couldn\'t be loaded. Please try again later.';

  @override
  String get restoreNone =>
      'No active subscription was found for this account.';

  @override
  String get restoreOk => 'Your subscription has been restored.';

  @override
  String get statusFree => 'Free plan';

  @override
  String get statusTrial => 'Free trial';

  @override
  String get statusPremium => 'Premium';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String trialDaysLeft(String days) {
    return '$days days left in your trial';
  }

  @override
  String trialEnds(String date) {
    return 'Trial ends $date';
  }

  @override
  String renewsOn(String date) {
    return 'Renews on $date';
  }

  @override
  String accessEndsOn(String date) {
    return 'Access ends $date';
  }

  @override
  String get expiredBody =>
      'Your Premium access has ended. Resubscribe any time.';

  @override
  String get freeBody => 'You are on the Free plan.';

  @override
  String get autoRenewOn => 'Auto-renew is on';

  @override
  String get autoRenewOff => 'Auto-renew is off';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get manageInStore => 'Manage in Google Play';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get statusRefreshed => 'Status updated';

  @override
  String lastVerified(String date) {
    return 'Last verified $date';
  }

  @override
  String get notVerifiedYet => 'Not verified with the server yet';

  @override
  String planName(String name) {
    return 'Plan: $name';
  }

  @override
  String get premiumBenefitsTitle => 'Premium benefits';

  @override
  String get benefitUnlimited => 'Unlimited sign recognition';

  @override
  String benefitUnlimitedBody(String count) {
    return 'Recognise as many signs as you like. Free accounts can recognise up to $count signs a day.';
  }

  @override
  String benefitHistoryBody(String count) {
    return 'Keep your full translation history on this device. Free keeps the latest $count entries.';
  }

  @override
  String get benefitAiBody =>
      'Smoother sentences from an online AI translation service. Needs an internet connection; on-device translation is used otherwise.';

  @override
  String get benefitAnalyticsBody =>
      'See accuracy, completion by topic and your activity over the last week.';

  @override
  String get alwaysFreeTitle => 'Always free';

  @override
  String get alwaysFreeBody =>
      'On-device sign recognition (with a daily limit), voice → sign, the sign dictionary, all lessons and practice.';

  @override
  String get seeAllBenefits => 'See all benefits';

  @override
  String get notifLearnTitle => 'Time to practise';

  @override
  String get notifLearnBody =>
      'A few signs a day keeps them fresh. Open SignoVoice to learn today.';

  @override
  String get notifStreakTitle => 'Keep your streak going';

  @override
  String get notifStreakBody => 'A quick practice keeps your streak alive.';

  @override
  String get notifTrialTitle => 'Your free trial is ending';

  @override
  String notifTrialBody(String date, String days) {
    return 'Your free trial ends in $days day(s), on $date. Cancel in Google Play if you don\'t want to continue.';
  }

  @override
  String get notifRenewalTitle => 'Premium renews soon';

  @override
  String notifRenewalBody(String date) {
    return 'Your Premium subscription renews on $date. You can manage it in Google Play any time.';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'You\'re all caught up.';

  @override
  String get notificationsEmptyBody =>
      'Reminders, subscription updates and interpreter messages will appear here.';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get notificationNew => 'New';

  @override
  String unreadCount(String count) {
    return '$count unread notifications';
  }

  @override
  String get notifSettingsTitle => 'Notification settings';

  @override
  String get notifPermissionOff =>
      'Notifications are turned off for SignoVoice on this device.';

  @override
  String get notifPermissionAsk => 'Allow notifications';

  @override
  String get notifLearning => 'Learning reminders';

  @override
  String get notifStreakSetting => 'Practice streak';

  @override
  String get notifTrialSetting => 'Free trial reminders';

  @override
  String get notifRenewalSetting => 'Renewal information';

  @override
  String get notifInterpreterSetting => 'Interpreter request updates';

  @override
  String get notifSystemSetting => 'System notifications';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get guestName => 'Guest';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get usageTitle => 'Usage';

  @override
  String usageSigns(String count) {
    return 'Signs recognised today: $count';
  }

  @override
  String usageSignsOfLimit(String count, String limit) {
    return 'Signs recognised today: $count of $limit';
  }

  @override
  String usageHistory(String count) {
    return 'Saved translations: $count';
  }

  @override
  String usageLearned(String count) {
    return 'Signs learned: $count';
  }

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionPreferences => 'Preferences';

  @override
  String get sectionSupport => 'Support';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Match device';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsAccessibility => 'Accessibility';

  @override
  String get settingsVoice => 'Voice';

  @override
  String get settingsTranslation => 'Translation';

  @override
  String get settingsPrivacy => 'Privacy & data';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsAbout => 'About SignoVoice';

  @override
  String get settingsHelp => 'Help & support';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get accTextSize => 'Text size';

  @override
  String get accTextSizePreview => 'Hello! This is how text will look.';

  @override
  String get accHighContrast => 'High contrast';

  @override
  String get accHighContrastDesc => 'Stronger borders and text colours.';

  @override
  String get accReduceMotion => 'Reduce motion';

  @override
  String get accReduceMotionDesc =>
      'Turns off scanning sweeps, pulses and page transitions.';

  @override
  String get accHaptics => 'Haptic feedback';

  @override
  String get accHapticsDesc => 'Short vibrations when a sign is recognised.';

  @override
  String get accVoiceFeedback => 'Spoken feedback';

  @override
  String get accVoiceFeedbackDesc => 'Speak practice results aloud.';

  @override
  String get transMode => 'Recognition mode';

  @override
  String get transOnDevice => 'On this device';

  @override
  String get transOnDeviceDesc => 'Private and works offline.';

  @override
  String get transOnline => 'Online (server)';

  @override
  String get transOnlineDesc =>
      'Sends hand-landmark numbers, never video. Needs internet and a configured server.';

  @override
  String get transOnlineUnavailable =>
      'Online recognition isn\'t set up in this build.';

  @override
  String get transConfidence => 'Confidence threshold';

  @override
  String get transConfidenceDesc =>
      'Higher means fewer but more reliable signs.';

  @override
  String get transAutoSpeak => 'Speak signs automatically';

  @override
  String get transMirror => 'Mirror hand input';

  @override
  String get transMirrorDesc =>
      'Matches the training data. Turn off only if left and right seem swapped.';

  @override
  String transModelNote(String count) {
    return 'The on-device model currently recognises $count signs and can make mistakes.';
  }

  @override
  String get privacyAnalytics => 'Share anonymous usage and crash data';

  @override
  String get privacyAnalyticsDesc =>
      'Helps us fix problems. Never includes video, signs or translations.';

  @override
  String get privacySaveHistory => 'Save translation history on this device';

  @override
  String get privacyClearHistory => 'Clear translation history';

  @override
  String get privacyClearProgress => 'Reset learning progress';

  @override
  String get privacyClearProgressBody =>
      'This removes learned signs, saved signs, XP, streak and badges from this device.';

  @override
  String get privacyProgressCleared => 'Learning progress reset';

  @override
  String get privacyDataTitle => 'What data is processed';

  @override
  String get privacyDataCamera =>
      'Camera: analysed on your device to find hand positions. Video is never recorded or uploaded. In online mode only hand-landmark numbers are sent.';

  @override
  String get privacyDataMic =>
      'Microphone: used only when you tap the mic or join an interpreter call. Speech-to-text uses your device\'s speech service.';

  @override
  String get privacyDataAccount =>
      'Account: your name, email or phone, and profile photo are stored with our authentication and database provider (Firebase).';

  @override
  String get privacyDataHistory =>
      'History and learning progress: stored only on this device.';

  @override
  String get privacyDataPurchases =>
      'Subscriptions: payments are handled by Google Play. We receive a purchase token to verify your plan, not your card details.';

  @override
  String get privacyDataCalls =>
      'Interpreter calls: audio and video are streamed to your interpreter through our call provider. We store call time, duration and your rating.';

  @override
  String get privacyDataAnalytics =>
      'Usage and crash data: anonymous events (like \"practice started\") and crash reports, only if you allow it above.';

  @override
  String get privacyRequestDeletion => 'Request deletion of my server data';

  @override
  String get privacyDeletionRequested =>
      'Deletion requested. Your server-side data will be erased.';

  @override
  String get privacyDeleteAccount => 'Delete account';

  @override
  String securitySignedInAs(String who) {
    return 'Signed in as $who';
  }

  @override
  String get securityChangePassword => 'Change password';

  @override
  String get securityPasswordSent =>
      'We sent a password reset link to your email.';

  @override
  String get securityGuest =>
      'Guest mode keeps data on this device only. Create an account to secure and sync your plan.';

  @override
  String get createAccountAction => 'Create an account';

  @override
  String get logoutTitle => 'Sign out?';

  @override
  String get logoutBody => 'You can sign back in any time.';

  @override
  String get logoutClearData =>
      'Also clear history and progress on this device';

  @override
  String get deleteTitle => 'Delete your account';

  @override
  String get deleteBody =>
      'This permanently deletes your account and the data we hold about you, and clears data on this device. This cannot be undone. Deleting your account does not cancel a Google Play subscription; cancel it in Google Play first.';

  @override
  String get deleteGuestBody =>
      'This clears everything SignoVoice stored on this device.';

  @override
  String get deleteConfirmCheck => 'I understand this is permanent';

  @override
  String get deleteAction => 'Delete permanently';

  @override
  String get deleteRecentLogin =>
      'For your security, sign in again, then delete your account.';

  @override
  String get deleteAndSignOut => 'Sign out and sign in again';

  @override
  String get helpTitle => 'Help & support';

  @override
  String get faq1q => 'Why isn\'t my sign recognised?';

  @override
  String faq1a(String count) {
    return 'Use good light, keep your whole hand in view and sign at a steady pace. The on-device model currently recognises $count signs.';
  }

  @override
  String get faq2q => 'Does SignoVoice record my video?';

  @override
  String get faq2a =>
      'No. Video is analysed on your device to find hand positions and is never recorded or uploaded.';

  @override
  String get faq3q => 'How does the free trial work?';

  @override
  String get faq3a =>
      'New accounts can start a one-month free trial. It renews automatically at the price shown unless you cancel in Google Play before it ends.';

  @override
  String get faq4q => 'How do I cancel my subscription?';

  @override
  String get faq4a =>
      'Open Google Play › Payments & subscriptions › Subscriptions › SignoVoice › Cancel subscription.';

  @override
  String get faq5q => 'Can I use SignoVoice offline?';

  @override
  String get faq5a =>
      'Yes for on-device sign recognition, the dictionary and lessons. Live interpreters, online recognition and AI translation need internet.';

  @override
  String get faq6q => 'Why do some signs have no video?';

  @override
  String get faq6a =>
      'The dictionary lists more signs than we have videos for. Videos are added over time.';

  @override
  String get helpContact => 'Contact support';

  @override
  String get helpEmailSubject => 'SignoVoice support';

  @override
  String aboutVersion(String build, String version) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutMission =>
      'Breaking communication barriers with AI-powered sign-language technology.';

  @override
  String aboutModelNote(String count) {
    return 'Sign recognition is an aid, not a certified interpreter. It currently knows $count signs and can make mistakes. For important conversations, use a human interpreter.';
  }

  @override
  String get aboutLicenses => 'Open-source licenses';

  @override
  String get legalTitlePrivacy => 'Privacy Policy';

  @override
  String get legalTitleTerms => 'Terms of Service';

  @override
  String get legalEnglishOnly => 'The legal text is provided in English.';

  @override
  String get openInBrowser => 'Open online version';

  @override
  String get settingsNotifications => 'Notifications';
}
