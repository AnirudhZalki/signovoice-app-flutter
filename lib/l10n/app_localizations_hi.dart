// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'साइनोवॉइस';

  @override
  String get tagline => 'बाधाओं को तोड़ते हुए';

  @override
  String get coreIdea => 'एक इशारा। एक आवाज़। एक जुड़ाव।';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get back => 'वापस';

  @override
  String get close => 'बंद करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएं';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get share => 'साझा करें';

  @override
  String get search => 'खोजें';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get done => 'पूर्ण';

  @override
  String get next => 'आगे';

  @override
  String get skip => 'छोड़ें';

  @override
  String get loading => 'लोड हो रहा है…';

  @override
  String get copied => 'क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get offlineBanner => 'आप ऑफ़लाइन हैं। कुछ सुविधाएं सीमित हैं।';

  @override
  String get internetRequired =>
      'इस पहचान मोड के लिए इंटरनेट कनेक्शन आवश्यक है।';

  @override
  String get emptyDefaultTitle => 'यहाँ अभी कुछ नहीं है';

  @override
  String get errorTitle => 'कुछ गलत हो गया';

  @override
  String get statusOn => 'चालू';

  @override
  String get statusOff => 'बंद';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get grantPermission => 'अनुमति दें';

  @override
  String get confidenceLabel => 'विश्वसनीयता';

  @override
  String get confidenceHigh => 'उच्च';

  @override
  String get confidenceMedium => 'मध्यम';

  @override
  String get confidenceLow => 'कम';

  @override
  String confidenceValue(String percent) {
    return 'विश्वसनीयता $percent प्रतिशत';
  }

  @override
  String get failureOffline =>
      'आप ऑफ़लाइन हैं। अपना कनेक्शन जाँचें और पुनः प्रयास करें।';

  @override
  String get failureNetwork =>
      'हम सर्वर तक नहीं पहुँच सके। कृपया पुनः प्रयास करें।';

  @override
  String get failureTimeout =>
      'इसमें अपेक्षा से अधिक समय लग रहा है। कृपया पुनः प्रयास करें।';

  @override
  String get failureUnauthorized =>
      'जारी रखने के लिए कृपया फिर से साइन इन करें।';

  @override
  String get failureNotConfigured =>
      'यह सेवा अभी सेट अप नहीं है। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get failurePermissionDenied => 'जारी रखने के लिए अनुमति आवश्यक है।';

  @override
  String get failurePermissionPermanent =>
      'अनुमति अस्वीकार की गई। आप इसे डिवाइस सेटिंग्स में चालू कर सकते हैं।';

  @override
  String get failureModelUnavailable =>
      'साइन पहचान अस्थायी रूप से उपलब्ध नहीं है। कृपया पुनः प्रयास करें।';

  @override
  String get failureServiceUnavailable =>
      'सेवा अस्थायी रूप से उपलब्ध नहीं है। कृपया पुनः प्रयास करें।';

  @override
  String get failureBilling =>
      'खरीदारी अभी उपलब्ध नहीं है। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get failureCancelled => 'रद्द किया गया।';

  @override
  String get failureValidation => 'कृपया विवरण जाँचें और पुनः प्रयास करें।';

  @override
  String get failureNotFound => 'आप जो खोज रहे थे वह हमें नहीं मिला।';

  @override
  String get failureRecentLogin =>
      'आपकी सुरक्षा के लिए, कृपया फिर से साइन इन करें और पुनः प्रयास करें।';

  @override
  String get failureLimit =>
      'आप फ़िलहाल सीमा तक पहुँच गए हैं। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get failureUnknown => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get validationRequired => 'यह फ़ील्ड आवश्यक है';

  @override
  String get validationEmail => 'मान्य ईमेल पता दर्ज करें';

  @override
  String get validationPassword =>
      'कम से कम 8 अक्षर, एक अक्षर और एक संख्या का उपयोग करें';

  @override
  String get validationPasswordMismatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get validationPhone => 'देश कोड के साथ मान्य फ़ोन नंबर दर्ज करें';

  @override
  String get validationOtp => '6 अंकों का कोड दर्ज करें';

  @override
  String get validationName => 'कम से कम 2 अक्षर दर्ज करें';

  @override
  String get modeSignToText => 'साइन → टेक्स्ट';

  @override
  String get modeVoiceToSign => 'आवाज़ → साइन';

  @override
  String get modeSignToVoice => 'साइन → आवाज़';

  @override
  String get modeInterpreter => 'लाइव दुभाषिया';

  @override
  String get onb1Title => 'बाधाओं के बिना संवाद';

  @override
  String get onb1Body =>
      'साइनोवॉइस एआई, आवाज़, टेक्स्ट और लाइव दुभाषियों की मदद से साइन करने वालों और साइन भाषा न जानने वालों को एक-दूसरे को समझने में मदद करता है।';

  @override
  String get onb2Title => 'साइन भाषा का अनुवाद करें';

  @override
  String get onb2Body =>
      'कैमरा साइन करने वाले की ओर करें। साइन आपके डिवाइस पर पहचाने जाते हैं और पढ़ने या सुनने योग्य टेक्स्ट में बदल जाते हैं।';

  @override
  String get onb3Title => 'आवाज़ और टेक्स्ट से बात करें';

  @override
  String get onb3Body =>
      'बोलें या टाइप करें और मेल खाते साइन देखें। पहचाने गए साइन को अपनी भाषा में बोले गए शब्दों में बदलें।';

  @override
  String get onb4Title => 'भारतीय साइन भाषा सीखें';

  @override
  String get onb4Body =>
      'छोटे पाठ, खोजने योग्य शब्दकोश और तुरंत प्रतिक्रिया के साथ कैमरा अभ्यास।';

  @override
  String get onb5Title => 'दुभाषियों से जुड़ें';

  @override
  String get onb5Body =>
      'जब आपको किसी व्यक्ति की ज़रूरत हो, तो वीडियो, ऑडियो या चैट से लाइव साइन-भाषा दुभाषिया का अनुरोध करें।';

  @override
  String get onb6Title => 'आपकी गोपनीयता महत्वपूर्ण है';

  @override
  String get onb6Body =>
      'कैमरा केवल तब उपयोग होता है जब अनुवाद स्क्रीन खुली हो, और साइन पहचान आपके डिवाइस पर चलती है। क्या सहेजा जाए, यह आप चुनते हैं।';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String pageOf(String current, String total) {
    return 'पृष्ठ $current / $total';
  }

  @override
  String get loginTitle => 'वापसी पर स्वागत है';

  @override
  String get loginSubtitle =>
      'अपनी प्रगति सिंक करने और सभी सुविधाएं अनलॉक करने के लिए साइन इन करें।';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get showPassword => 'पासवर्ड दिखाएं';

  @override
  String get hidePassword => 'पासवर्ड छिपाएं';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get signOut => 'साइन आउट करें';

  @override
  String get registerTitle => 'अपना खाता बनाएं';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get forgotTitle => 'अपना पासवर्ड रीसेट करें';

  @override
  String get forgotBody =>
      'अपना ईमेल दर्ज करें, हम नया पासवर्ड चुनने का लिंक भेजेंगे।';

  @override
  String get sendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get resetLinkSent =>
      'यदि उस ईमेल का खाता मौजूद है, तो रीसेट लिंक भेजा जा रहा है।';

  @override
  String get continueWithGoogle => 'Google से जारी रखें';

  @override
  String get continueWithPhone => 'फ़ोन से जारी रखें';

  @override
  String get continueAsGuest => 'बिना खाते के जारी रखें';

  @override
  String get guestNote =>
      'अतिथि मोड सब कुछ इसी डिवाइस पर रखता है। दुभाषिये, सिंक और सदस्यता के लिए खाता चाहिए।';

  @override
  String get orDivider => 'या';

  @override
  String get noAccount => 'नए हैं? खाता बनाएं';

  @override
  String get haveAccount => 'पहले से खाता है? साइन इन करें';

  @override
  String get agreeTerms => 'मैं सेवा की शर्तों और गोपनीयता नीति से सहमत हूँ';

  @override
  String get mustAgreeTerms =>
      'जारी रखने के लिए कृपया शर्तें और गोपनीयता नीति स्वीकार करें';

  @override
  String get termsOfService => 'सेवा की शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get backendMissingBanner =>
      'इस बिल्ड में खाता साइन-इन उपलब्ध नहीं है। आप फिर भी बिना खाते के साइनोवॉइस का उपयोग कर सकते हैं।';

  @override
  String get phoneTitle => 'अपने फ़ोन से साइन इन करें';

  @override
  String get phoneBody =>
      'हम आपको 6 अंकों का कोड भेजेंगे। सामान्य संदेश शुल्क लग सकता है।';

  @override
  String get phoneNumber => 'फ़ोन नंबर (देश कोड सहित)';

  @override
  String get sendCode => 'कोड भेजें';

  @override
  String get otpTitle => 'कोड दर्ज करें';

  @override
  String otpSentTo(String phone) {
    return 'हमने $phone पर 6 अंकों का कोड भेजा है';
  }

  @override
  String get verifyCode => 'सत्यापित करें';

  @override
  String get resendCode => 'कोड फिर भेजें';

  @override
  String resendIn(String seconds) {
    return '$seconds सेकंड में फिर भेजें';
  }

  @override
  String get authInvalidCredentials => 'ईमेल या पासवर्ड गलत है।';

  @override
  String get authEmailInUse => 'इस ईमेल के लिए खाता पहले से मौजूद है।';

  @override
  String get authWeakPassword => 'वह पासवर्ड बहुत कमज़ोर है।';

  @override
  String get authTooMany =>
      'बहुत अधिक प्रयास। कृपया कुछ मिनट प्रतीक्षा करें और पुनः प्रयास करें।';

  @override
  String get authInvalidCode => 'वह कोड सही नहीं है या समाप्त हो गया है।';

  @override
  String get authDisabled => 'यह खाता अक्षम कर दिया गया है।';

  @override
  String get googleSignInCancelled => 'Google साइन-इन रद्द किया गया।';

  @override
  String get profileSetupTitle => 'अपनी प्रोफ़ाइल सेट करें';

  @override
  String get profileSetupSubtitle =>
      'केवल आपका नाम आवश्यक है। बाकी सब वैकल्पिक है और बाद में बदला जा सकता है।';

  @override
  String get addPhoto => 'फ़ोटो जोड़ें';

  @override
  String get changePhoto => 'फ़ोटो बदलें';

  @override
  String get preferredLanguage => 'पसंदीदा भाषा';

  @override
  String get preferredMode => 'आप ज़्यादातर कैसे संवाद करते हैं?';

  @override
  String get accessibilityOptional => 'पहुँच संबंधी प्राथमिकताएं (वैकल्पिक)';

  @override
  String get needDeaf => 'मैं बधिर हूँ';

  @override
  String get needHardOfHearing => 'मुझे कम सुनाई देता है';

  @override
  String get needSpeech => 'मुझे बोलने में कठिनाई है';

  @override
  String get needLowVision => 'मुझे कम दिखाई देता है';

  @override
  String get needMotor => 'मुझे बड़े टच लक्ष्य पसंद हैं';

  @override
  String get skipForNow => 'अभी छोड़ें';

  @override
  String get saveAndContinue => 'सहेजें और जारी रखें';

  @override
  String get langEnglish => 'अंग्रेज़ी';

  @override
  String get langHindi => 'हिन्दी';

  @override
  String get langKannada => 'कन्नड़ (ಕನ್ನಡ)';

  @override
  String get langSystem => 'डिवाइस की भाषा';

  @override
  String get navHome => 'होम';

  @override
  String get navTranslate => 'अनुवाद';

  @override
  String get navLearn => 'सीखें';

  @override
  String get navLive => 'लाइव';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingAfternoon => 'नमस्कार';

  @override
  String get greetingEvening => 'शुभ संध्या';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get heroTitle => 'आज हम आपको संवाद करने में कैसे मदद कर सकते हैं?';

  @override
  String get heroCta => 'अनुवाद शुरू करें';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get qaSignToTextSub => 'साइन को टेक्स्ट में बदलें';

  @override
  String get qaVoiceToSignSub => 'बोलें और साइन देखें';

  @override
  String get qaSignToVoiceSub => 'साइन को बोलते हुए सुनें';

  @override
  String get qaInterpreterSub => 'किसी व्यक्ति से जुड़ें';

  @override
  String get qaLearnSub => 'पाठ और शब्दकोश';

  @override
  String get qaPracticeSub => 'कैमरे से अभ्यास करें';

  @override
  String get notificationsTooltip => 'सूचनाएं';

  @override
  String get openProfileTooltip => 'प्रोफ़ाइल खोलें';

  @override
  String get translateTabTitle => 'आप क्या करना चाहेंगे?';

  @override
  String get translateTabSubtitle => 'संवाद करने का तरीका चुनें।';

  @override
  String get practiceTitle => 'अभ्यास';
}
