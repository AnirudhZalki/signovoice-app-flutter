import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SignoVoice'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Breaking Barriers'**
  String get tagline;

  /// No description provided for @coreIdea.
  ///
  /// In en, this message translates to:
  /// **'One Gesture. One Voice. One Connection.'**
  String get coreIdea;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Some features are limited.'**
  String get offlineBanner;

  /// No description provided for @internetRequired.
  ///
  /// In en, this message translates to:
  /// **'Internet connection required for this recognition mode.'**
  String get internetRequired;

  /// No description provided for @emptyDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyDefaultTitle;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @statusOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get statusOn;

  /// No description provided for @statusOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get statusOff;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get grantPermission;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidenceLabel;

  /// No description provided for @confidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get confidenceHigh;

  /// No description provided for @confidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get confidenceMedium;

  /// No description provided for @confidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get confidenceLow;

  /// No description provided for @confidenceValue.
  ///
  /// In en, this message translates to:
  /// **'Confidence {percent} percent'**
  String confidenceValue(String percent);

  /// No description provided for @failureOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Check your connection and try again.'**
  String get failureOffline;

  /// No description provided for @failureNetwork.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the server. Please try again.'**
  String get failureNetwork;

  /// No description provided for @failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'This is taking longer than expected. Please try again.'**
  String get failureTimeout;

  /// No description provided for @failureUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue.'**
  String get failureUnauthorized;

  /// No description provided for @failureNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'This service isn\'t set up yet. Please try again later.'**
  String get failureNotConfigured;

  /// No description provided for @failurePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission is needed to continue.'**
  String get failurePermissionDenied;

  /// No description provided for @failurePermissionPermanent.
  ///
  /// In en, this message translates to:
  /// **'Permission was denied. You can turn it on in your device settings.'**
  String get failurePermissionPermanent;

  /// No description provided for @failureModelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign recognition is temporarily unavailable. Please try again.'**
  String get failureModelUnavailable;

  /// No description provided for @failureServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Please try again.'**
  String get failureServiceUnavailable;

  /// No description provided for @failureBilling.
  ///
  /// In en, this message translates to:
  /// **'Purchases aren\'t available right now. Please try again later.'**
  String get failureBilling;

  /// No description provided for @failureCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled.'**
  String get failureCancelled;

  /// No description provided for @failureValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check the details and try again.'**
  String get failureValidation;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get failureNotFound;

  /// No description provided for @failureRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, please sign in again, then retry.'**
  String get failureRecentLogin;

  /// No description provided for @failureLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the limit for now. Please try again later.'**
  String get failureLimit;

  /// No description provided for @failureUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get failureUnknown;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmail;

  /// No description provided for @validationPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters with a letter and a number'**
  String get validationPassword;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get validationPasswordMismatch;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number with country code'**
  String get validationPhone;

  /// No description provided for @validationOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get validationOtp;

  /// No description provided for @validationName.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters'**
  String get validationName;

  /// No description provided for @modeSignToText.
  ///
  /// In en, this message translates to:
  /// **'Sign → Text'**
  String get modeSignToText;

  /// No description provided for @modeVoiceToSign.
  ///
  /// In en, this message translates to:
  /// **'Voice → Sign'**
  String get modeVoiceToSign;

  /// No description provided for @modeSignToVoice.
  ///
  /// In en, this message translates to:
  /// **'Sign → Voice'**
  String get modeSignToVoice;

  /// No description provided for @modeInterpreter.
  ///
  /// In en, this message translates to:
  /// **'Live Interpreter'**
  String get modeInterpreter;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'Communication Without Barriers'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'SignoVoice helps people who sign and people who don\'t know sign language understand each other, using AI, voice, text and live interpreters.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Translate Sign Language'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a signer. Signs are recognised on your device and turned into text you can read or hear.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Talk Through Voice & Text'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'Speak or type and see the matching signs. Turn recognised signs into spoken words in your language.'**
  String get onb3Body;

  /// No description provided for @onb4Title.
  ///
  /// In en, this message translates to:
  /// **'Learn Indian Sign Language'**
  String get onb4Title;

  /// No description provided for @onb4Body.
  ///
  /// In en, this message translates to:
  /// **'Short lessons, a searchable dictionary and camera practice with instant feedback.'**
  String get onb4Body;

  /// No description provided for @onb5Title.
  ///
  /// In en, this message translates to:
  /// **'Connect With Interpreters'**
  String get onb5Title;

  /// No description provided for @onb5Body.
  ///
  /// In en, this message translates to:
  /// **'Request a live sign-language interpreter by video, audio or chat when you need a human.'**
  String get onb5Body;

  /// No description provided for @onb6Title.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Matters'**
  String get onb6Title;

  /// No description provided for @onb6Body.
  ///
  /// In en, this message translates to:
  /// **'The camera is used only while a translation screen is open, and sign recognition runs on your device. You choose what is saved.'**
  String get onb6Body;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(String current, String total);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your progress and unlock all features.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @forgotBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to choose a new password.'**
  String get forgotBody;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a reset link is on its way.'**
  String get resetLinkSent;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get continueWithPhone;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get continueAsGuest;

  /// No description provided for @guestNote.
  ///
  /// In en, this message translates to:
  /// **'Guest mode keeps everything on this device. Interpreters, sync and subscriptions need an account.'**
  String get guestNote;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get agreeTerms;

  /// No description provided for @mustAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms and Privacy Policy to continue'**
  String get mustAgreeTerms;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @backendMissingBanner.
  ///
  /// In en, this message translates to:
  /// **'Account sign-in isn\'t available in this build. You can still use SignoVoice without an account.'**
  String get backendMissingBanner;

  /// No description provided for @phoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone'**
  String get phoneTitle;

  /// No description provided for @phoneBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll text you a 6-digit code. Standard message rates may apply.'**
  String get phoneBody;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number (with country code)'**
  String get phoneNumber;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(String seconds);

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'That password is too weak.'**
  String get authWeakPassword;

  /// No description provided for @authTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a few minutes and try again.'**
  String get authTooMany;

  /// No description provided for @authInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code is not correct or has expired.'**
  String get authInvalidCode;

  /// No description provided for @authDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authDisabled;

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get googleSignInCancelled;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only your name is needed. Everything else is optional and can be changed later.'**
  String get profileSetupSubtitle;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @preferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get preferredLanguage;

  /// No description provided for @preferredMode.
  ///
  /// In en, this message translates to:
  /// **'How do you mostly communicate?'**
  String get preferredMode;

  /// No description provided for @accessibilityOptional.
  ///
  /// In en, this message translates to:
  /// **'Accessibility preferences (optional)'**
  String get accessibilityOptional;

  /// No description provided for @needDeaf.
  ///
  /// In en, this message translates to:
  /// **'I am Deaf'**
  String get needDeaf;

  /// No description provided for @needHardOfHearing.
  ///
  /// In en, this message translates to:
  /// **'I am hard of hearing'**
  String get needHardOfHearing;

  /// No description provided for @needSpeech.
  ///
  /// In en, this message translates to:
  /// **'I have a speech difference'**
  String get needSpeech;

  /// No description provided for @needLowVision.
  ///
  /// In en, this message translates to:
  /// **'I have low vision'**
  String get needLowVision;

  /// No description provided for @needMotor.
  ///
  /// In en, this message translates to:
  /// **'I prefer larger touch targets'**
  String get needMotor;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी (Hindi)'**
  String get langHindi;

  /// No description provided for @langKannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ (Kannada)'**
  String get langKannada;

  /// No description provided for @langSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get langSystem;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get navTranslate;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get navLive;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'How can we help you communicate today?'**
  String get heroTitle;

  /// No description provided for @heroCta.
  ///
  /// In en, this message translates to:
  /// **'Start translating'**
  String get heroCta;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @qaSignToTextSub.
  ///
  /// In en, this message translates to:
  /// **'Turn signs into text'**
  String get qaSignToTextSub;

  /// No description provided for @qaVoiceToSignSub.
  ///
  /// In en, this message translates to:
  /// **'Speak and see signs'**
  String get qaVoiceToSignSub;

  /// No description provided for @qaSignToVoiceSub.
  ///
  /// In en, this message translates to:
  /// **'Hear signs spoken aloud'**
  String get qaSignToVoiceSub;

  /// No description provided for @qaInterpreterSub.
  ///
  /// In en, this message translates to:
  /// **'Connect with a person'**
  String get qaInterpreterSub;

  /// No description provided for @qaLearnSub.
  ///
  /// In en, this message translates to:
  /// **'Lessons and dictionary'**
  String get qaLearnSub;

  /// No description provided for @qaPracticeSub.
  ///
  /// In en, this message translates to:
  /// **'Practise with your camera'**
  String get qaPracticeSub;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @openProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfileTooltip;

  /// No description provided for @translateTabTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get translateTabTitle;

  /// No description provided for @translateTabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a way to communicate.'**
  String get translateTabSubtitle;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Your saved translations will appear here.'**
  String get noRecentActivity;

  /// No description provided for @todayUsage.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayUsage;

  /// No description provided for @aiShortcutTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced AI translation'**
  String get aiShortcutTitle;

  /// No description provided for @aiShortcutBody.
  ///
  /// In en, this message translates to:
  /// **'Smoother sentences from an online AI service.'**
  String get aiShortcutBody;

  /// No description provided for @aiShortcutIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included with your plan'**
  String get aiShortcutIncluded;

  /// No description provided for @aiShortcutPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium feature'**
  String get aiShortcutPremium;

  /// No description provided for @homeAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'What is SignoVoice?'**
  String get homeAboutTitle;

  /// No description provided for @homeAboutBody.
  ///
  /// In en, this message translates to:
  /// **'SignoVoice helps people who sign and people who don\'t know sign language understand each other. Translate signs into text and speech, turn speech into signs, talk to a live interpreter, and learn Indian Sign Language.'**
  String get homeAboutBody;

  /// No description provided for @homeMore.
  ///
  /// In en, this message translates to:
  /// **'More with SignoVoice'**
  String get homeMore;

  /// No description provided for @homeHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get homeHowTitle;

  /// No description provided for @homeHow1.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to do: sign to text, voice to sign, or a live interpreter.'**
  String get homeHow1;

  /// No description provided for @homeHow2.
  ///
  /// In en, this message translates to:
  /// **'Show your hands to the camera or speak. Recognition runs on your phone.'**
  String get homeHow2;

  /// No description provided for @homeHow3.
  ///
  /// In en, this message translates to:
  /// **'Read, hear or see the translation instantly, and find it later in History.'**
  String get homeHow3;

  /// No description provided for @homeCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Made for the deaf and speech-impaired community'**
  String get homeCommunityTitle;

  /// No description provided for @homeCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'You deserve to be understood — at home, at school, at work and at the doctor. SignoVoice turns your signs into text and speech, turns what others say into signs, and connects you with a live interpreter when it matters.'**
  String get homeCommunityBody;

  /// No description provided for @homeBenefit1Title.
  ///
  /// In en, this message translates to:
  /// **'Be understood anywhere'**
  String get homeBenefit1Title;

  /// No description provided for @homeBenefit1Body.
  ///
  /// In en, this message translates to:
  /// **'Sign to the camera and the phone speaks for you.'**
  String get homeBenefit1Body;

  /// No description provided for @homeBenefit2Title.
  ///
  /// In en, this message translates to:
  /// **'Understand others'**
  String get homeBenefit2Title;

  /// No description provided for @homeBenefit2Body.
  ///
  /// In en, this message translates to:
  /// **'Speak or type and watch the signs for every word.'**
  String get homeBenefit2Body;

  /// No description provided for @homeBenefit3Title.
  ///
  /// In en, this message translates to:
  /// **'Family and friends can learn too'**
  String get homeBenefit3Title;

  /// No description provided for @homeBenefit3Body.
  ///
  /// In en, this message translates to:
  /// **'Short Indian Sign Language lessons for everyone.'**
  String get homeBenefit3Body;

  /// No description provided for @homeBenefit4Title.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get homeBenefit4Title;

  /// No description provided for @homeBenefit4Body.
  ///
  /// In en, this message translates to:
  /// **'Hand recognition runs on your phone; your camera video is not uploaded.'**
  String get homeBenefit4Body;

  /// No description provided for @homeShareCta.
  ///
  /// In en, this message translates to:
  /// **'Tell someone who could use SignoVoice'**
  String get homeShareCta;

  /// No description provided for @homeShareMessage.
  ///
  /// In en, this message translates to:
  /// **'SignoVoice helps deaf and speech-impaired people communicate — it turns signs into text and speech and speech into signs. Get it free: https://play.google.com/store/apps/details?id=com.anirudhzalki.signovoiceapp'**
  String get homeShareMessage;

  /// No description provided for @shareWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Share SignoVoice with others'**
  String get shareWithOthers;

  /// No description provided for @introSignToText.
  ///
  /// In en, this message translates to:
  /// **'Sign → Text'**
  String get introSignToText;

  /// No description provided for @introVoiceToSign.
  ///
  /// In en, this message translates to:
  /// **'Voice → Sign'**
  String get introVoiceToSign;

  /// No description provided for @introLive.
  ///
  /// In en, this message translates to:
  /// **'Live interpreter'**
  String get introLive;

  /// No description provided for @introLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn signs'**
  String get introLearn;

  /// No description provided for @signStatusReady.
  ///
  /// In en, this message translates to:
  /// **'On-device model ready'**
  String get signStatusReady;

  /// No description provided for @signStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online recognition'**
  String get signStatusOnline;

  /// No description provided for @signStatusLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading model…'**
  String get signStatusLoading;

  /// No description provided for @signStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Model unavailable'**
  String get signStatusUnavailable;

  /// No description provided for @showHandHint.
  ///
  /// In en, this message translates to:
  /// **'Show your hand to the camera'**
  String get showHandHint;

  /// No description provided for @handDetected.
  ///
  /// In en, this message translates to:
  /// **'Hand detected'**
  String get handDetected;

  /// No description provided for @currentSign.
  ///
  /// In en, this message translates to:
  /// **'Current sign'**
  String get currentSign;

  /// No description provided for @translationLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translationLabel;

  /// No description provided for @translationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Recognised signs will appear here as text.'**
  String get translationPlaceholder;

  /// No description provided for @recognisedSigns.
  ///
  /// In en, this message translates to:
  /// **'Recognised signs'**
  String get recognisedSigns;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @speak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get speak;

  /// No description provided for @stopSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Stop speaking'**
  String get stopSpeaking;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @flipCamera.
  ///
  /// In en, this message translates to:
  /// **'Flip camera'**
  String get flipCamera;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Turn flash on'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Turn flash off'**
  String get flashOff;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @cameraPermTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get cameraPermTitle;

  /// No description provided for @cameraPermBody.
  ///
  /// In en, this message translates to:
  /// **'SignoVoice uses your camera only on this screen to see hands. Hand positions are analysed on your device. Video is never recorded or uploaded.'**
  String get cameraPermBody;

  /// No description provided for @micPermTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access needed'**
  String get micPermTitle;

  /// No description provided for @micPermBody.
  ///
  /// In en, this message translates to:
  /// **'SignoVoice listens only while you tap the microphone button, to turn your speech into text. Speech recognition is provided by your device\'s speech service and may need an internet connection.'**
  String get micPermBody;

  /// No description provided for @cameraInitError.
  ///
  /// In en, this message translates to:
  /// **'The camera couldn\'t start. Close other apps that use the camera and try again.'**
  String get cameraInitError;

  /// No description provided for @handTrackingUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Hand tracking isn\'t supported on this device yet.'**
  String get handTrackingUnsupported;

  /// No description provided for @signsLeftToday.
  ///
  /// In en, this message translates to:
  /// **'{count} signs left today'**
  String signsLeftToday(String count);

  /// No description provided for @limitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily free limit reached'**
  String get limitReachedTitle;

  /// No description provided for @limitReachedBody.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for unlimited sign recognition, or come back tomorrow.'**
  String get limitReachedBody;

  /// No description provided for @seePremium.
  ///
  /// In en, this message translates to:
  /// **'See Premium'**
  String get seePremium;

  /// No description provided for @saveToHistory.
  ///
  /// In en, this message translates to:
  /// **'Save to history'**
  String get saveToHistory;

  /// No description provided for @savedToHistory.
  ///
  /// In en, this message translates to:
  /// **'Saved to history'**
  String get savedToHistory;

  /// No description provided for @historyOffHint.
  ///
  /// In en, this message translates to:
  /// **'History is turned off in Privacy settings.'**
  String get historyOffHint;

  /// No description provided for @outputLanguage.
  ///
  /// In en, this message translates to:
  /// **'Output language'**
  String get outputLanguage;

  /// No description provided for @voiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice settings'**
  String get voiceSettings;

  /// No description provided for @voiceSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speaking speed'**
  String get voiceSpeed;

  /// No description provided for @voiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Voice language'**
  String get voiceLanguage;

  /// No description provided for @voiceSelect.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceSelect;

  /// No description provided for @voiceDefault.
  ///
  /// In en, this message translates to:
  /// **'Default voice'**
  String get voiceDefault;

  /// No description provided for @voiceNoneForLanguage.
  ///
  /// In en, this message translates to:
  /// **'No voice for this language is installed on your device. Install one in your device\'s text-to-speech settings.'**
  String get voiceNoneForLanguage;

  /// No description provided for @pausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedLabel;

  /// No description provided for @listeningLabel.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listeningLabel;

  /// No description provided for @recognitionPaused.
  ///
  /// In en, this message translates to:
  /// **'Recognition paused'**
  String get recognitionPaused;

  /// No description provided for @scanningHand.
  ///
  /// In en, this message translates to:
  /// **'Looking for a hand'**
  String get scanningHand;

  /// No description provided for @noSignYet.
  ///
  /// In en, this message translates to:
  /// **'No sign yet'**
  String get noSignYet;

  /// No description provided for @liveTranslation.
  ///
  /// In en, this message translates to:
  /// **'Live translation: {text}'**
  String liveTranslation(String text);

  /// No description provided for @clearedAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get clearedAnnouncement;

  /// No description provided for @recognisedAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Recognised {sign}'**
  String recognisedAnnouncement(String sign);

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get historySearchHint;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Translations you save will appear here, only on this device.'**
  String get historyEmptyBody;

  /// No description provided for @historyNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matches for your search'**
  String get historyNoResults;

  /// No description provided for @historyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all history'**
  String get historyClearAll;

  /// No description provided for @historyClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all history?'**
  String get historyClearTitle;

  /// No description provided for @historyClearBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes every saved translation from this device.'**
  String get historyClearBody;

  /// No description provided for @historyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get historyDeleted;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @historyHidden.
  ///
  /// In en, this message translates to:
  /// **'{count} older entries are hidden on the free plan'**
  String historyHidden(String count);

  /// No description provided for @historyHiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Full history is a Premium feature'**
  String get historyHiddenTitle;

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String durationSeconds(String seconds);

  /// No description provided for @inputTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Input: {type}'**
  String inputTypeLabel(String type);

  /// No description provided for @catAlphabet.
  ///
  /// In en, this message translates to:
  /// **'Alphabet'**
  String get catAlphabet;

  /// No description provided for @catNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get catNumbers;

  /// No description provided for @catGreetings.
  ///
  /// In en, this message translates to:
  /// **'Greetings'**
  String get catGreetings;

  /// No description provided for @catDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Conversation'**
  String get catDaily;

  /// No description provided for @catFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get catFamily;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get catHealthcare;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get catEmergency;

  /// No description provided for @catWorkplace.
  ///
  /// In en, this message translates to:
  /// **'Workplace'**
  String get catWorkplace;

  /// No description provided for @catPhrases.
  ///
  /// In en, this message translates to:
  /// **'Common Phrases'**
  String get catPhrases;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn Indian Sign Language'**
  String get learnTitle;

  /// No description provided for @learnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short lessons, one topic at a time.'**
  String get learnSubtitle;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get yourProgress;

  /// No description provided for @xpValue.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String xpValue(String xp);

  /// No description provided for @levelValue.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelValue(String level);

  /// No description provided for @streakValue.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String streakValue(String days);

  /// No description provided for @learnedOf.
  ///
  /// In en, this message translates to:
  /// **'{learned} of {total} signs learned'**
  String learnedOf(String learned, String total);

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @lessonN.
  ///
  /// In en, this message translates to:
  /// **'Lesson {n}'**
  String lessonN(String n);

  /// No description provided for @lessonProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} learned'**
  String lessonProgress(String done, String total);

  /// No description provided for @lessonComplete.
  ///
  /// In en, this message translates to:
  /// **'Lesson complete'**
  String get lessonComplete;

  /// No description provided for @lessonCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Nice work. You have learned {count} signs in this lesson.'**
  String lessonCompleteBody(String count);

  /// No description provided for @markLearned.
  ///
  /// In en, this message translates to:
  /// **'I know this sign'**
  String get markLearned;

  /// No description provided for @signLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get signLearned;

  /// No description provided for @savedSigns.
  ///
  /// In en, this message translates to:
  /// **'Saved signs'**
  String get savedSigns;

  /// No description provided for @bookmarkAdd.
  ///
  /// In en, this message translates to:
  /// **'Save this sign'**
  String get bookmarkAdd;

  /// No description provided for @bookmarkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get bookmarkRemove;

  /// No description provided for @noSavedSigns.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved any signs yet.'**
  String get noSavedSigns;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @finishLesson.
  ///
  /// In en, this message translates to:
  /// **'Finish lesson'**
  String get finishLesson;

  /// No description provided for @signOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Sign {current} of {total}'**
  String signOfTotal(String current, String total);

  /// No description provided for @learningAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Learning analytics'**
  String get learningAnalytics;

  /// No description provided for @analyticsLocked.
  ///
  /// In en, this message translates to:
  /// **'Detailed learning analytics is a Premium feature.'**
  String get analyticsLocked;

  /// No description provided for @analyticsLockedBody.
  ///
  /// In en, this message translates to:
  /// **'See accuracy, completion by topic and your activity over the last week.'**
  String get analyticsLockedBody;

  /// No description provided for @accuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Practice accuracy'**
  String get accuracyLabel;

  /// No description provided for @attemptsLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get attemptsLabel;

  /// No description provided for @completionByTopic.
  ///
  /// In en, this message translates to:
  /// **'Completion by topic'**
  String get completionByTopic;

  /// No description provided for @lastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get lastSevenDays;

  /// No description provided for @activityDay.
  ///
  /// In en, this message translates to:
  /// **'{day}: {count} actions'**
  String activityDay(String count, String day);

  /// No description provided for @badgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badgesTitle;

  /// No description provided for @badgeLocked.
  ///
  /// In en, this message translates to:
  /// **'Not earned yet'**
  String get badgeLocked;

  /// No description provided for @badgeFirstSign.
  ///
  /// In en, this message translates to:
  /// **'First sign learned'**
  String get badgeFirstSign;

  /// No description provided for @badgeTenSigns.
  ///
  /// In en, this message translates to:
  /// **'10 signs learned'**
  String get badgeTenSigns;

  /// No description provided for @badgeFirstCorrect.
  ///
  /// In en, this message translates to:
  /// **'First correct practice'**
  String get badgeFirstCorrect;

  /// No description provided for @badgeTenCorrect.
  ///
  /// In en, this message translates to:
  /// **'10 correct practices'**
  String get badgeTenCorrect;

  /// No description provided for @badgeStreak3.
  ///
  /// In en, this message translates to:
  /// **'3-day streak'**
  String get badgeStreak3;

  /// No description provided for @badgeStreak7.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get badgeStreak7;

  /// No description provided for @dictionaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign dictionary'**
  String get dictionaryTitle;

  /// No description provided for @dictionarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search signs, e.g. Hello or Water'**
  String get dictionarySearchHint;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @dictionaryNoResults.
  ///
  /// In en, this message translates to:
  /// **'No signs match your search.'**
  String get dictionaryNoResults;

  /// No description provided for @signVideoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign video not available yet'**
  String get signVideoUnavailable;

  /// No description provided for @signVideoUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This sign is listed, but its video hasn\'t been added yet.'**
  String get signVideoUnavailableBody;

  /// No description provided for @hasVideo.
  ///
  /// In en, this message translates to:
  /// **'Video available'**
  String get hasVideo;

  /// No description provided for @listenPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listenPronunciation;

  /// No description provided for @practiceThisSign.
  ///
  /// In en, this message translates to:
  /// **'Practise this sign'**
  String get practiceThisSign;

  /// No description provided for @practiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera practice isn\'t available for this sign yet. The recogniser currently knows {count} signs.'**
  String practiceNotAvailable(String count);

  /// No description provided for @meaningLabel.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaningLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get categoryLabel;

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play video'**
  String get playVideo;

  /// No description provided for @pauseVideo.
  ///
  /// In en, this message translates to:
  /// **'Pause video'**
  String get pauseVideo;

  /// No description provided for @videoError.
  ///
  /// In en, this message translates to:
  /// **'The video couldn\'t be played.'**
  String get videoError;

  /// No description provided for @entryNotFound.
  ///
  /// In en, this message translates to:
  /// **'That sign couldn\'t be found.'**
  String get entryNotFound;

  /// No description provided for @practiceHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceHubTitle;

  /// No description provided for @practiceIntro.
  ///
  /// In en, this message translates to:
  /// **'Show a sign to your camera. Your device checks it and gives instant feedback.'**
  String get practiceIntro;

  /// No description provided for @practiceAvailableSigns.
  ///
  /// In en, this message translates to:
  /// **'Signs you can practise now'**
  String get practiceAvailableSigns;

  /// No description provided for @practicePrompt.
  ///
  /// In en, this message translates to:
  /// **'Show the sign for {sign}'**
  String practicePrompt(String sign);

  /// No description provided for @startPractice.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startPractice;

  /// No description provided for @getReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready…'**
  String get getReady;

  /// No description provided for @signNow.
  ///
  /// In en, this message translates to:
  /// **'Sign now'**
  String get signNow;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @recognisedLabel.
  ///
  /// In en, this message translates to:
  /// **'Recognised'**
  String get recognisedLabel;

  /// No description provided for @resultCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get resultCorrect;

  /// No description provided for @resultTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get resultTryAgain;

  /// No description provided for @resultNoHand.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t see your hand clearly. Try again with better light.'**
  String get resultNoHand;

  /// No description provided for @nextSign.
  ///
  /// In en, this message translates to:
  /// **'Next sign'**
  String get nextSign;

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpEarned(String xp);

  /// No description provided for @watchReference.
  ///
  /// In en, this message translates to:
  /// **'Watch the sign'**
  String get watchReference;

  /// No description provided for @countdownNumber.
  ///
  /// In en, this message translates to:
  /// **'{n}'**
  String countdownNumber(String n);

  /// No description provided for @vsTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice → Sign'**
  String get vsTitle;

  /// No description provided for @vsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone and speak, or type below.'**
  String get vsHint;

  /// No description provided for @typeHere.
  ///
  /// In en, this message translates to:
  /// **'Type or paste text'**
  String get typeHere;

  /// No description provided for @showSigns.
  ///
  /// In en, this message translates to:
  /// **'Show signs'**
  String get showSigns;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get tapToSpeak;

  /// No description provided for @tapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop'**
  String get tapToStop;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition isn\'t available on this device. You can type instead.'**
  String get speechUnavailable;

  /// No description provided for @speechNothingHeard.
  ///
  /// In en, this message translates to:
  /// **'We didn\'t hear anything. Try again.'**
  String get speechNothingHeard;

  /// No description provided for @speechLanguage.
  ///
  /// In en, this message translates to:
  /// **'Speech language'**
  String get speechLanguage;

  /// No description provided for @signsForText.
  ///
  /// In en, this message translates to:
  /// **'Signs'**
  String get signsForText;

  /// No description provided for @noSignYetForWord.
  ///
  /// In en, this message translates to:
  /// **'No sign available yet'**
  String get noSignYetForWord;

  /// No description provided for @missingSignsNote.
  ///
  /// In en, this message translates to:
  /// **'{count} word(s) don\'t have a sign in the dictionary yet.'**
  String missingSignsNote(String count);

  /// No description provided for @heardLabel.
  ///
  /// In en, this message translates to:
  /// **'What we heard'**
  String get heardLabel;

  /// No description provided for @liveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live interpreter'**
  String get liveTitle;

  /// No description provided for @liveIntro.
  ///
  /// In en, this message translates to:
  /// **'Connect with a human sign-language interpreter by video, audio or chat.'**
  String get liveIntro;

  /// No description provided for @findInterpreter.
  ///
  /// In en, this message translates to:
  /// **'Available interpreters'**
  String get findInterpreter;

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// No description provided for @statusBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get statusBusy;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @ratingValue.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count} ratings)'**
  String ratingValue(String count, String rating);

  /// No description provided for @noRatingsYet.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get noRatingsYet;

  /// No description provided for @requestInterpreter.
  ///
  /// In en, this message translates to:
  /// **'Request an interpreter'**
  String get requestInterpreter;

  /// No description provided for @requestVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get requestVideoCall;

  /// No description provided for @requestAudioCall.
  ///
  /// In en, this message translates to:
  /// **'Audio call'**
  String get requestAudioCall;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note for the interpreter (optional)'**
  String get noteOptional;

  /// No description provided for @noInterpretersNow.
  ///
  /// In en, this message translates to:
  /// **'No interpreters are available right now. Try again in a few minutes.'**
  String get noInterpretersNow;

  /// No description provided for @interpreterNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'The live interpreter service isn\'t set up in this build yet.'**
  String get interpreterNotConfigured;

  /// No description provided for @signInForInterpreter.
  ///
  /// In en, this message translates to:
  /// **'Sign in to request an interpreter'**
  String get signInForInterpreter;

  /// No description provided for @signInForInterpreterBody.
  ///
  /// In en, this message translates to:
  /// **'Interpreter sessions need an account so calls can be connected and rated.'**
  String get signInForInterpreterBody;

  /// No description provided for @callRequesting.
  ///
  /// In en, this message translates to:
  /// **'Sending your request…'**
  String get callRequesting;

  /// No description provided for @callWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an interpreter…'**
  String get callWaiting;

  /// No description provided for @callQueue.
  ///
  /// In en, this message translates to:
  /// **'You are number {n} in the queue'**
  String callQueue(String n);

  /// No description provided for @callConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get callConnecting;

  /// No description provided for @callConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get callConnected;

  /// No description provided for @callReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get callReconnecting;

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get callEnded;

  /// No description provided for @callFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'The call couldn\'t be completed'**
  String get callFailedTitle;

  /// No description provided for @callDeclined.
  ///
  /// In en, this message translates to:
  /// **'No interpreter could take your request. Please try again.'**
  String get callDeclined;

  /// No description provided for @callExpired.
  ///
  /// In en, this message translates to:
  /// **'No interpreter accepted in time. Please try again.'**
  String get callExpired;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @muteMic.
  ///
  /// In en, this message translates to:
  /// **'Mute microphone'**
  String get muteMic;

  /// No description provided for @unmuteMic.
  ///
  /// In en, this message translates to:
  /// **'Unmute microphone'**
  String get unmuteMic;

  /// No description provided for @cameraOffAction.
  ///
  /// In en, this message translates to:
  /// **'Turn camera off'**
  String get cameraOffAction;

  /// No description provided for @cameraOnAction.
  ///
  /// In en, this message translates to:
  /// **'Turn camera on'**
  String get cameraOnAction;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get endCall;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get chatHint;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportIssue;

  /// No description provided for @issueAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio problem'**
  String get issueAudio;

  /// No description provided for @issueVideo.
  ///
  /// In en, this message translates to:
  /// **'Video problem'**
  String get issueVideo;

  /// No description provided for @issueInterpreter.
  ///
  /// In en, this message translates to:
  /// **'Interpreter conduct'**
  String get issueInterpreter;

  /// No description provided for @issueConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection problem'**
  String get issueConnection;

  /// No description provided for @issueOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get issueOther;

  /// No description provided for @issueDescribe.
  ///
  /// In en, this message translates to:
  /// **'Tell us more (optional)'**
  String get issueDescribe;

  /// No description provided for @issueSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks. We\'ll look into it.'**
  String get issueSent;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your call?'**
  String get feedbackTitle;

  /// No description provided for @feedbackStars.
  ///
  /// In en, this message translates to:
  /// **'{n} of 5 stars'**
  String feedbackStars(String n);

  /// No description provided for @feedbackComment.
  ///
  /// In en, this message translates to:
  /// **'Comments (optional)'**
  String get feedbackComment;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get submitFeedback;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback.'**
  String get feedbackThanks;

  /// No description provided for @skipFeedback.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipFeedback;

  /// No description provided for @callDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration {time}'**
  String callDuration(String time);

  /// No description provided for @interpreterConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'In a call with {name}'**
  String interpreterConnectedTo(String name);

  /// No description provided for @waitingForVideo.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the interpreter\'s video…'**
  String get waitingForVideo;

  /// No description provided for @audioCallActive.
  ///
  /// In en, this message translates to:
  /// **'Audio call in progress'**
  String get audioCallActive;

  /// No description provided for @devRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Test room (debug build only)'**
  String get devRoomTitle;

  /// No description provided for @devRoomBody.
  ///
  /// In en, this message translates to:
  /// **'Joins the LiveKit room your development token was issued for, so you can test video, audio and chat without the backend.'**
  String get devRoomBody;

  /// No description provided for @roomTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a live room'**
  String get roomTitle;

  /// No description provided for @roomBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the same room code as the other person (or interpreter) to start a live call.'**
  String get roomBody;

  /// No description provided for @roomCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Room code'**
  String get roomCodeLabel;

  /// No description provided for @roomCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use 3–40 letters, numbers, - or _'**
  String get roomCodeInvalid;

  /// No description provided for @deskTitle.
  ///
  /// In en, this message translates to:
  /// **'Interpreter desk'**
  String get deskTitle;

  /// No description provided for @deskNotInterpreter.
  ///
  /// In en, this message translates to:
  /// **'This account isn\'t approved as an interpreter.'**
  String get deskNotInterpreter;

  /// No description provided for @deskOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re online'**
  String get deskOnline;

  /// No description provided for @deskOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get deskOffline;

  /// No description provided for @deskOnlineHint.
  ///
  /// In en, this message translates to:
  /// **'Go online to receive requests that match your languages.'**
  String get deskOnlineHint;

  /// No description provided for @deskQueue.
  ///
  /// In en, this message translates to:
  /// **'Waiting requests'**
  String get deskQueue;

  /// No description provided for @deskGoOnline.
  ///
  /// In en, this message translates to:
  /// **'Go online to see waiting requests.'**
  String get deskGoOnline;

  /// No description provided for @deskEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one is waiting right now. This list updates automatically.'**
  String get deskEmpty;

  /// No description provided for @deskSomeone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get deskSomeone;

  /// No description provided for @deskWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting {seconds} s'**
  String deskWaiting(String seconds);

  /// No description provided for @deskAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept and join'**
  String get deskAccept;

  /// No description provided for @priceFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get priceFree;

  /// No description provided for @pricePerSession.
  ///
  /// In en, this message translates to:
  /// **'{price} / {minutes} min'**
  String pricePerSession(String minutes, String price);

  /// No description provided for @payAndConnect.
  ///
  /// In en, this message translates to:
  /// **'Pay {price} and connect'**
  String payAndConnect(String price);

  /// No description provided for @connectNow.
  ///
  /// In en, this message translates to:
  /// **'Connect now'**
  String get connectNow;

  /// No description provided for @payRefundNote.
  ///
  /// In en, this message translates to:
  /// **'You pay only if the interpreter accepts: if nobody accepts in time or you cancel while waiting, you are refunded automatically.'**
  String get payRefundNote;

  /// No description provided for @sessionWith.
  ///
  /// In en, this message translates to:
  /// **'Session with {name}'**
  String sessionWith(String name);

  /// No description provided for @becomeInterpreter.
  ///
  /// In en, this message translates to:
  /// **'Become an interpreter'**
  String get becomeInterpreter;

  /// No description provided for @becomeInterpreterBody.
  ///
  /// In en, this message translates to:
  /// **'Help people communicate and earn per session. Set your languages and your rate, then go online whenever you are free.'**
  String get becomeInterpreterBody;

  /// No description provided for @applicationPending.
  ///
  /// In en, this message translates to:
  /// **'Your interpreter application is waiting for approval.'**
  String get applicationPending;

  /// No description provided for @interpreterProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Interpreter profile'**
  String get interpreterProfileTitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileName;

  /// No description provided for @profileLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages you interpret'**
  String get profileLanguages;

  /// No description provided for @profileRate.
  ///
  /// In en, this message translates to:
  /// **'Your rate per {minutes}-minute session (₹)'**
  String profileRate(String minutes);

  /// No description provided for @profileRateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 0 to offer sessions for free, or 1 to 5000. The platform keeps a service fee from paid sessions.'**
  String get profileRateHint;

  /// No description provided for @profileBio.
  ///
  /// In en, this message translates to:
  /// **'About you (optional)'**
  String get profileBio;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get profileSave;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSaved;

  /// No description provided for @profileInvalidRate.
  ///
  /// In en, this message translates to:
  /// **'Enter 0 or a whole number from 1 to 5000.'**
  String get profileInvalidRate;

  /// No description provided for @profilePickLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one language.'**
  String get profilePickLanguage;

  /// No description provided for @deskRate.
  ///
  /// In en, this message translates to:
  /// **'Your rate'**
  String get deskRate;

  /// No description provided for @deskEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total earned: {amount}'**
  String deskEarnings(String amount);

  /// No description provided for @deskEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile and rate'**
  String get deskEditProfile;

  /// No description provided for @deskYouEarn.
  ///
  /// In en, this message translates to:
  /// **'You earn {amount}'**
  String deskYouEarn(String amount);

  /// No description provided for @deskDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get deskDecline;

  /// No description provided for @callPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment wasn\'t completed. You haven\'t been charged.'**
  String get callPaymentCancelled;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin: interpreters'**
  String get adminTitle;

  /// No description provided for @adminPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminPending;

  /// No description provided for @adminApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminApproved;

  /// No description provided for @adminApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApprove;

  /// No description provided for @adminRevoke.
  ///
  /// In en, this message translates to:
  /// **'Remove approval'**
  String get adminRevoke;

  /// No description provided for @adminNonePending.
  ///
  /// In en, this message translates to:
  /// **'No applications waiting.'**
  String get adminNonePending;

  /// No description provided for @adminNoneApproved.
  ///
  /// In en, this message translates to:
  /// **'No approved interpreters yet.'**
  String get adminNoneApproved;

  /// No description provided for @adminNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only an administrator can open this page.'**
  String get adminNotAllowed;

  /// No description provided for @premiumHeader.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full SignoVoice experience'**
  String get premiumHeader;

  /// No description provided for @premiumSubheader.
  ///
  /// In en, this message translates to:
  /// **'Free stays genuinely useful. Premium removes limits and adds deeper tools.'**
  String get premiumSubheader;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freePlan;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlan;

  /// No description provided for @featRecognition.
  ///
  /// In en, this message translates to:
  /// **'Sign recognition'**
  String get featRecognition;

  /// No description provided for @featRecognitionFree.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} signs a day'**
  String featRecognitionFree(String count);

  /// No description provided for @featUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get featUnlimited;

  /// No description provided for @featHistory.
  ///
  /// In en, this message translates to:
  /// **'Translation history'**
  String get featHistory;

  /// No description provided for @featHistoryFree.
  ///
  /// In en, this message translates to:
  /// **'Latest {count} entries'**
  String featHistoryFree(String count);

  /// No description provided for @featFullHistory.
  ///
  /// In en, this message translates to:
  /// **'Full history'**
  String get featFullHistory;

  /// No description provided for @featAi.
  ///
  /// In en, this message translates to:
  /// **'Advanced AI translation'**
  String get featAi;

  /// No description provided for @featNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'Not included'**
  String get featNotIncluded;

  /// No description provided for @featIncludedOnline.
  ///
  /// In en, this message translates to:
  /// **'Included (needs internet)'**
  String get featIncludedOnline;

  /// No description provided for @featAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Learning analytics'**
  String get featAnalytics;

  /// No description provided for @featBasicProgress.
  ///
  /// In en, this message translates to:
  /// **'Basic progress'**
  String get featBasicProgress;

  /// No description provided for @featFullAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Detailed analytics'**
  String get featFullAnalytics;

  /// No description provided for @featCore.
  ///
  /// In en, this message translates to:
  /// **'Lessons, dictionary, practice, voice → sign'**
  String get featCore;

  /// No description provided for @featIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get featIncluded;

  /// No description provided for @trialOneMonthFree.
  ///
  /// In en, this message translates to:
  /// **'1 month free'**
  String get trialOneMonthFree;

  /// No description provided for @trialThenPrice.
  ///
  /// In en, this message translates to:
  /// **'Then {price} per {period}'**
  String trialThenPrice(String period, String price);

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get periodYear;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get periodWeek;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get periodDay;

  /// No description provided for @renewsAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Renews automatically'**
  String get renewsAutomatically;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime in your store subscription settings'**
  String get cancelAnytime;

  /// No description provided for @trialTerms.
  ///
  /// In en, this message translates to:
  /// **'Your first month is free. When it ends, your subscription renews automatically at {price} per {period} unless you cancel before the trial ends. Cancel any time in Google Play: Menu › Payments & subscriptions › Subscriptions. You will always see the final price and confirm in Google Play before you are charged.'**
  String trialTerms(String period, String price);

  /// No description provided for @subscribeTerms.
  ///
  /// In en, this message translates to:
  /// **'Your subscription renews automatically at {price} per {period} until you cancel. Cancel any time in Google Play: Menu › Payments & subscriptions › Subscriptions. You will confirm the final price in Google Play before you are charged.'**
  String subscribeTerms(String period, String price);

  /// No description provided for @priceShownAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'The price is shown by Google Play before you confirm.'**
  String get priceShownAtCheckout;

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start free trial'**
  String get startFreeTrial;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribeNow;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @planPerPeriod.
  ///
  /// In en, this message translates to:
  /// **'{price} / {period}'**
  String planPerPeriod(String period, String price);

  /// No description provided for @planFirstFree.
  ///
  /// In en, this message translates to:
  /// **'First month free'**
  String get planFirstFree;

  /// No description provided for @trialOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first month is free'**
  String get trialOfferTitle;

  /// No description provided for @trialOfferBody.
  ///
  /// In en, this message translates to:
  /// **'Try every Premium feature for a month.'**
  String get trialOfferBody;

  /// No description provided for @trialOfferPrice.
  ///
  /// In en, this message translates to:
  /// **'{price} per {period} after your trial'**
  String trialOfferPrice(String period, String price);

  /// No description provided for @trialNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'A free trial isn\'t available for this account. You can still subscribe from the Premium page.'**
  String get trialNotAvailable;

  /// No description provided for @signInToSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Sign in to start your free trial'**
  String get signInToSubscribe;

  /// No description provided for @purchasePending.
  ///
  /// In en, this message translates to:
  /// **'Your payment is pending. Premium unlocks once it completes.'**
  String get purchasePending;

  /// No description provided for @purchaseVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying your purchase…'**
  String get purchaseVerifying;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Premium is active. Thank you!'**
  String get purchaseSuccess;

  /// No description provided for @purchaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled. You haven\'t been charged.'**
  String get purchaseCancelled;

  /// No description provided for @purchaseNeedsVerification.
  ///
  /// In en, this message translates to:
  /// **'Your purchase went through, but we couldn\'t verify it yet. Nothing is lost — tap retry.'**
  String get purchaseNeedsVerification;

  /// No description provided for @billingUnavailableMsg.
  ///
  /// In en, this message translates to:
  /// **'Google Play purchases aren\'t available on this device right now.'**
  String get billingUnavailableMsg;

  /// No description provided for @productsUnavailableMsg.
  ///
  /// In en, this message translates to:
  /// **'Subscription plans couldn\'t be loaded. Please try again later.'**
  String get productsUnavailableMsg;

  /// No description provided for @restoreNone.
  ///
  /// In en, this message translates to:
  /// **'No active subscription was found for this account.'**
  String get restoreNone;

  /// No description provided for @restoreOk.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has been restored.'**
  String get restoreOk;

  /// No description provided for @statusFree.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get statusFree;

  /// No description provided for @statusTrial.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get statusTrial;

  /// No description provided for @statusPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get statusPremium;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @trialDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left in your trial'**
  String trialDaysLeft(String days);

  /// No description provided for @trialEnds.
  ///
  /// In en, this message translates to:
  /// **'Trial ends {date}'**
  String trialEnds(String date);

  /// No description provided for @renewsOn.
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String renewsOn(String date);

  /// No description provided for @accessEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Access ends {date}'**
  String accessEndsOn(String date);

  /// No description provided for @expiredBody.
  ///
  /// In en, this message translates to:
  /// **'Your Premium access has ended. Resubscribe any time.'**
  String get expiredBody;

  /// No description provided for @freeBody.
  ///
  /// In en, this message translates to:
  /// **'You are on the Free plan.'**
  String get freeBody;

  /// No description provided for @autoRenewOn.
  ///
  /// In en, this message translates to:
  /// **'Auto-renew is on'**
  String get autoRenewOn;

  /// No description provided for @autoRenewOff.
  ///
  /// In en, this message translates to:
  /// **'Auto-renew is off'**
  String get autoRenewOff;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @manageInStore.
  ///
  /// In en, this message translates to:
  /// **'Manage in Google Play'**
  String get manageInStore;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;

  /// No description provided for @statusRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get statusRefreshed;

  /// No description provided for @lastVerified.
  ///
  /// In en, this message translates to:
  /// **'Last verified {date}'**
  String lastVerified(String date);

  /// No description provided for @notVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Not verified with the server yet'**
  String get notVerifiedYet;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan: {name}'**
  String planName(String name);

  /// No description provided for @premiumBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium benefits'**
  String get premiumBenefitsTitle;

  /// No description provided for @benefitUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited sign recognition'**
  String get benefitUnlimited;

  /// No description provided for @benefitUnlimitedBody.
  ///
  /// In en, this message translates to:
  /// **'Recognise as many signs as you like. Free accounts can recognise up to {count} signs a day.'**
  String benefitUnlimitedBody(String count);

  /// No description provided for @benefitHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your full translation history on this device. Free keeps the latest {count} entries.'**
  String benefitHistoryBody(String count);

  /// No description provided for @benefitAiBody.
  ///
  /// In en, this message translates to:
  /// **'Smoother sentences from an online AI translation service. Needs an internet connection; on-device translation is used otherwise.'**
  String get benefitAiBody;

  /// No description provided for @benefitAnalyticsBody.
  ///
  /// In en, this message translates to:
  /// **'See accuracy, completion by topic and your activity over the last week.'**
  String get benefitAnalyticsBody;

  /// No description provided for @alwaysFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Always free'**
  String get alwaysFreeTitle;

  /// No description provided for @alwaysFreeBody.
  ///
  /// In en, this message translates to:
  /// **'On-device sign recognition (with a daily limit), voice → sign, the sign dictionary, all lessons and practice.'**
  String get alwaysFreeBody;

  /// No description provided for @seeAllBenefits.
  ///
  /// In en, this message translates to:
  /// **'See all benefits'**
  String get seeAllBenefits;

  /// No description provided for @payWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get payWith;

  /// No description provided for @payGooglePlay.
  ///
  /// In en, this message translates to:
  /// **'Google Play'**
  String get payGooglePlay;

  /// No description provided for @payRazorpay.
  ///
  /// In en, this message translates to:
  /// **'UPI, cards & wallets'**
  String get payRazorpay;

  /// No description provided for @payRazorpayNote.
  ///
  /// In en, this message translates to:
  /// **'Secure checkout by Razorpay. Google Pay, PhonePe, Paytm and other UPI apps support auto-pay; you approve the mandate in your UPI app.'**
  String get payRazorpayNote;

  /// No description provided for @priceAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'Price shown at checkout'**
  String get priceAtCheckout;

  /// No description provided for @razorpayTerms.
  ///
  /// In en, this message translates to:
  /// **'Auto-pay renews your subscription until you cancel. You approve the payment and see the final price in the Razorpay checkout. Cancel any time from Manage subscription.'**
  String get razorpayTerms;

  /// No description provided for @cancelAutoRenew.
  ///
  /// In en, this message translates to:
  /// **'Cancel auto-renew'**
  String get cancelAutoRenew;

  /// No description provided for @cancelAutoRenewBody.
  ///
  /// In en, this message translates to:
  /// **'You keep Premium until the end of the period you already paid for. No further payments will be taken.'**
  String get cancelAutoRenewBody;

  /// No description provided for @cancelAutoRenewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel auto-renew'**
  String get cancelAutoRenewConfirm;

  /// No description provided for @keepSubscription.
  ///
  /// In en, this message translates to:
  /// **'Keep subscription'**
  String get keepSubscription;

  /// No description provided for @autoRenewCancelled.
  ///
  /// In en, this message translates to:
  /// **'Auto-renew cancelled. Premium stays until the end of the paid period.'**
  String get autoRenewCancelled;

  /// No description provided for @premiumHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign without limits'**
  String get premiumHeroTitle;

  /// No description provided for @premiumHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Unlimited recognition, full history, detailed progress and smarter sentences.'**
  String get premiumHeroBody;

  /// No description provided for @testPaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Test payment ₹1 (Razorpay)'**
  String get testPaymentButton;

  /// No description provided for @testPaymentOk.
  ///
  /// In en, this message translates to:
  /// **'Test payment verified.'**
  String get testPaymentOk;

  /// No description provided for @testPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled.'**
  String get testPaymentCancelled;

  /// No description provided for @testPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed or could not be verified.'**
  String get testPaymentFailed;

  /// No description provided for @razorpayUnavailableMsg.
  ///
  /// In en, this message translates to:
  /// **'Online payments aren\'t set up on this build yet. Try Google Play, or contact support.'**
  String get razorpayUnavailableMsg;

  /// No description provided for @razorpayPlansUnavailableMsg.
  ///
  /// In en, this message translates to:
  /// **'Plans couldn\'t be loaded from the payment server. Check your connection and retry.'**
  String get razorpayPlansUnavailableMsg;

  /// No description provided for @tryOtherPayment.
  ///
  /// In en, this message translates to:
  /// **'Play plans unavailable? Pay with UPI, cards or wallets instead.'**
  String get tryOtherPayment;

  /// No description provided for @planSixMonth.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get planSixMonth;

  /// No description provided for @periodMonths.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String periodMonths(String count);

  /// No description provided for @periodYears.
  ///
  /// In en, this message translates to:
  /// **'{count} years'**
  String periodYears(String count);

  /// No description provided for @planSave.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String planSave(String percent);

  /// No description provided for @notifLearnTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to practise'**
  String get notifLearnTitle;

  /// No description provided for @notifLearnBody.
  ///
  /// In en, this message translates to:
  /// **'A few signs a day keeps them fresh. Open SignoVoice to learn today.'**
  String get notifLearnBody;

  /// No description provided for @notifStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak going'**
  String get notifStreakTitle;

  /// No description provided for @notifStreakBody.
  ///
  /// In en, this message translates to:
  /// **'A quick practice keeps your streak alive.'**
  String get notifStreakBody;

  /// No description provided for @notifTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'Your free trial is ending'**
  String get notifTrialTitle;

  /// No description provided for @notifTrialBody.
  ///
  /// In en, this message translates to:
  /// **'Your free trial ends in {days} day(s), on {date}. Cancel in Google Play if you don\'t want to continue.'**
  String notifTrialBody(String date, String days);

  /// No description provided for @notifRenewalTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium renews soon'**
  String get notifRenewalTitle;

  /// No description provided for @notifRenewalBody.
  ///
  /// In en, this message translates to:
  /// **'Your Premium subscription renews on {date}. You can manage it in Google Play any time.'**
  String notifRenewalBody(String date);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders, subscription updates and interpreter messages will appear here.'**
  String get notificationsEmptyBody;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @notificationNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationNew;

  /// No description provided for @unreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread notifications'**
  String unreadCount(String count);

  /// No description provided for @notifSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notifSettingsTitle;

  /// No description provided for @notifPermissionOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for SignoVoice on this device.'**
  String get notifPermissionOff;

  /// No description provided for @notifPermissionAsk.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notifPermissionAsk;

  /// No description provided for @notifLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning reminders'**
  String get notifLearning;

  /// No description provided for @notifStreakSetting.
  ///
  /// In en, this message translates to:
  /// **'Practice streak'**
  String get notifStreakSetting;

  /// No description provided for @notifTrialSetting.
  ///
  /// In en, this message translates to:
  /// **'Free trial reminders'**
  String get notifTrialSetting;

  /// No description provided for @notifRenewalSetting.
  ///
  /// In en, this message translates to:
  /// **'Renewal information'**
  String get notifRenewalSetting;

  /// No description provided for @notifInterpreterSetting.
  ///
  /// In en, this message translates to:
  /// **'Interpreter request updates'**
  String get notifInterpreterSetting;

  /// No description provided for @notifSystemSetting.
  ///
  /// In en, this message translates to:
  /// **'System notifications'**
  String get notifSystemSetting;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestName;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @usageTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usageTitle;

  /// No description provided for @usageSigns.
  ///
  /// In en, this message translates to:
  /// **'Signs recognised today: {count}'**
  String usageSigns(String count);

  /// No description provided for @usageSignsOfLimit.
  ///
  /// In en, this message translates to:
  /// **'Signs recognised today: {count} of {limit}'**
  String usageSignsOfLimit(String count, String limit);

  /// No description provided for @usageHistory.
  ///
  /// In en, this message translates to:
  /// **'Saved translations: {count}'**
  String usageHistory(String count);

  /// No description provided for @usageLearned.
  ///
  /// In en, this message translates to:
  /// **'Signs learned: {count}'**
  String usageLearned(String count);

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get sectionPreferences;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match device'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsAccessibility;

  /// No description provided for @settingsVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsVoice;

  /// No description provided for @settingsTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get settingsTranslation;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get settingsPrivacy;

  /// No description provided for @settingsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get settingsSubscription;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About SignoVoice'**
  String get settingsAbout;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get settingsHelp;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @accTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get accTextSize;

  /// No description provided for @accTextSizePreview.
  ///
  /// In en, this message translates to:
  /// **'Hello! This is how text will look.'**
  String get accTextSizePreview;

  /// No description provided for @accHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get accHighContrast;

  /// No description provided for @accHighContrastDesc.
  ///
  /// In en, this message translates to:
  /// **'Stronger borders and text colours.'**
  String get accHighContrastDesc;

  /// No description provided for @accReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get accReduceMotion;

  /// No description provided for @accReduceMotionDesc.
  ///
  /// In en, this message translates to:
  /// **'Turns off scanning sweeps, pulses and page transitions.'**
  String get accReduceMotionDesc;

  /// No description provided for @accHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get accHaptics;

  /// No description provided for @accHapticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Short vibrations when a sign is recognised.'**
  String get accHapticsDesc;

  /// No description provided for @accVoiceFeedback.
  ///
  /// In en, this message translates to:
  /// **'Spoken feedback'**
  String get accVoiceFeedback;

  /// No description provided for @accVoiceFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Speak practice results aloud.'**
  String get accVoiceFeedbackDesc;

  /// No description provided for @transMode.
  ///
  /// In en, this message translates to:
  /// **'Recognition mode'**
  String get transMode;

  /// No description provided for @transOnDevice.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get transOnDevice;

  /// No description provided for @transOnDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Private and works offline.'**
  String get transOnDeviceDesc;

  /// No description provided for @transOnline.
  ///
  /// In en, this message translates to:
  /// **'Online (server)'**
  String get transOnline;

  /// No description provided for @transOnlineDesc.
  ///
  /// In en, this message translates to:
  /// **'Sends hand-landmark numbers, never video. Needs internet and a configured server.'**
  String get transOnlineDesc;

  /// No description provided for @transOnlineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Online recognition isn\'t set up in this build.'**
  String get transOnlineUnavailable;

  /// No description provided for @transConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence threshold'**
  String get transConfidence;

  /// No description provided for @transConfidenceDesc.
  ///
  /// In en, this message translates to:
  /// **'Higher means fewer but more reliable signs.'**
  String get transConfidenceDesc;

  /// No description provided for @transAutoSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak signs automatically'**
  String get transAutoSpeak;

  /// No description provided for @transMirror.
  ///
  /// In en, this message translates to:
  /// **'Mirror hand input'**
  String get transMirror;

  /// No description provided for @transMirrorDesc.
  ///
  /// In en, this message translates to:
  /// **'Matches the training data. Turn off only if left and right seem swapped.'**
  String get transMirrorDesc;

  /// No description provided for @transModelNote.
  ///
  /// In en, this message translates to:
  /// **'The on-device model currently recognises {count} signs and can make mistakes.'**
  String transModelNote(String count);

  /// No description provided for @privacyAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage and crash data'**
  String get privacyAnalytics;

  /// No description provided for @privacyAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Helps us fix problems. Never includes video, signs or translations.'**
  String get privacyAnalyticsDesc;

  /// No description provided for @privacySaveHistory.
  ///
  /// In en, this message translates to:
  /// **'Save translation history on this device'**
  String get privacySaveHistory;

  /// No description provided for @privacyClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear translation history'**
  String get privacyClearHistory;

  /// No description provided for @privacyClearProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset learning progress'**
  String get privacyClearProgress;

  /// No description provided for @privacyClearProgressBody.
  ///
  /// In en, this message translates to:
  /// **'This removes learned signs, saved signs, XP, streak and badges from this device.'**
  String get privacyClearProgressBody;

  /// No description provided for @privacyProgressCleared.
  ///
  /// In en, this message translates to:
  /// **'Learning progress reset'**
  String get privacyProgressCleared;

  /// No description provided for @privacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'What data is processed'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera: analysed on your device to find hand positions. Video is never recorded or uploaded. In online mode only hand-landmark numbers are sent.'**
  String get privacyDataCamera;

  /// No description provided for @privacyDataMic.
  ///
  /// In en, this message translates to:
  /// **'Microphone: used only when you tap the mic or join an interpreter call. Speech-to-text uses your device\'s speech service.'**
  String get privacyDataMic;

  /// No description provided for @privacyDataAccount.
  ///
  /// In en, this message translates to:
  /// **'Account: your name, email or phone, and profile photo are stored with our authentication and database provider (Firebase).'**
  String get privacyDataAccount;

  /// No description provided for @privacyDataHistory.
  ///
  /// In en, this message translates to:
  /// **'History and learning progress: stored only on this device.'**
  String get privacyDataHistory;

  /// No description provided for @privacyDataPurchases.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions: payments are handled by Google Play. We receive a purchase token to verify your plan, not your card details.'**
  String get privacyDataPurchases;

  /// No description provided for @privacyDataCalls.
  ///
  /// In en, this message translates to:
  /// **'Interpreter calls: audio and video are streamed to your interpreter through our call provider. We store call time, duration and your rating.'**
  String get privacyDataCalls;

  /// No description provided for @privacyDataAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Usage and crash data: anonymous events (like \"practice started\") and crash reports, only if you allow it above.'**
  String get privacyDataAnalytics;

  /// No description provided for @privacyRequestDeletion.
  ///
  /// In en, this message translates to:
  /// **'Request deletion of my server data'**
  String get privacyRequestDeletion;

  /// No description provided for @privacyDeletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Deletion requested. Your server-side data will be erased.'**
  String get privacyDeletionRequested;

  /// No description provided for @privacyDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get privacyDeleteAccount;

  /// No description provided for @securitySignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {who}'**
  String securitySignedInAs(String who);

  /// No description provided for @securityChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get securityChangePassword;

  /// No description provided for @securityPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to your email.'**
  String get securityPasswordSent;

  /// No description provided for @securityGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest mode keeps data on this device only. Create an account to secure and sync your plan.'**
  String get securityGuest;

  /// No description provided for @createAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccountAction;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in any time.'**
  String get logoutBody;

  /// No description provided for @logoutClearData.
  ///
  /// In en, this message translates to:
  /// **'Also clear history and progress on this device'**
  String get logoutClearData;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and the data we hold about you, and clears data on this device. This cannot be undone. Deleting your account does not cancel a Google Play subscription; cancel it in Google Play first.'**
  String get deleteBody;

  /// No description provided for @deleteGuestBody.
  ///
  /// In en, this message translates to:
  /// **'This clears everything SignoVoice stored on this device.'**
  String get deleteGuestBody;

  /// No description provided for @deleteConfirmCheck.
  ///
  /// In en, this message translates to:
  /// **'I understand this is permanent'**
  String get deleteConfirmCheck;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAction;

  /// No description provided for @deleteRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, sign in again, then delete your account.'**
  String get deleteRecentLogin;

  /// No description provided for @deleteAndSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out and sign in again'**
  String get deleteAndSignOut;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpTitle;

  /// No description provided for @faq1q.
  ///
  /// In en, this message translates to:
  /// **'Why isn\'t my sign recognised?'**
  String get faq1q;

  /// No description provided for @faq1a.
  ///
  /// In en, this message translates to:
  /// **'Use good light, keep your whole hand in view and sign at a steady pace. The on-device model currently recognises {count} signs.'**
  String faq1a(String count);

  /// No description provided for @faq2q.
  ///
  /// In en, this message translates to:
  /// **'Does SignoVoice record my video?'**
  String get faq2q;

  /// No description provided for @faq2a.
  ///
  /// In en, this message translates to:
  /// **'No. Video is analysed on your device to find hand positions and is never recorded or uploaded.'**
  String get faq2a;

  /// No description provided for @faq3q.
  ///
  /// In en, this message translates to:
  /// **'How does the free trial work?'**
  String get faq3q;

  /// No description provided for @faq3a.
  ///
  /// In en, this message translates to:
  /// **'New accounts can start a one-month free trial. It renews automatically at the price shown unless you cancel in Google Play before it ends.'**
  String get faq3a;

  /// No description provided for @faq4q.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel my subscription?'**
  String get faq4q;

  /// No description provided for @faq4a.
  ///
  /// In en, this message translates to:
  /// **'Open Google Play › Payments & subscriptions › Subscriptions › SignoVoice › Cancel subscription.'**
  String get faq4a;

  /// No description provided for @faq5q.
  ///
  /// In en, this message translates to:
  /// **'Can I use SignoVoice offline?'**
  String get faq5q;

  /// No description provided for @faq5a.
  ///
  /// In en, this message translates to:
  /// **'Yes for on-device sign recognition, the dictionary and lessons. Live interpreters, online recognition and AI translation need internet.'**
  String get faq5a;

  /// No description provided for @faq6q.
  ///
  /// In en, this message translates to:
  /// **'Why do some signs have no video?'**
  String get faq6q;

  /// No description provided for @faq6a.
  ///
  /// In en, this message translates to:
  /// **'The dictionary lists more signs than we have videos for. Videos are added over time.'**
  String get faq6a;

  /// No description provided for @helpContact.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get helpContact;

  /// No description provided for @helpEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'SignoVoice support'**
  String get helpEmailSubject;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersion(String build, String version);

  /// No description provided for @aboutMission.
  ///
  /// In en, this message translates to:
  /// **'Breaking communication barriers with AI-powered sign-language technology.'**
  String get aboutMission;

  /// No description provided for @aboutModelNote.
  ///
  /// In en, this message translates to:
  /// **'Sign recognition is an aid, not a certified interpreter. It currently knows {count} signs and can make mistakes. For important conversations, use a human interpreter.'**
  String aboutModelNote(String count);

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get aboutLicenses;

  /// No description provided for @legalTitlePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalTitlePrivacy;

  /// No description provided for @legalTitleTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTitleTerms;

  /// No description provided for @legalEnglishOnly.
  ///
  /// In en, this message translates to:
  /// **'The legal text is provided in English.'**
  String get legalEnglishOnly;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open online version'**
  String get openInBrowser;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
