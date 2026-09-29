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
