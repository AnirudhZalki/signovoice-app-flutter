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

  @override
  String get recentActivity => 'हाल की गतिविधि';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get noRecentActivity => 'आपके सहेजे गए अनुवाद यहाँ दिखेंगे।';

  @override
  String get todayUsage => 'आज';

  @override
  String get aiShortcutTitle => 'उन्नत एआई अनुवाद';

  @override
  String get aiShortcutBody => 'ऑनलाइन एआई सेवा से अधिक सहज वाक्य।';

  @override
  String get aiShortcutIncluded => 'आपकी योजना में शामिल';

  @override
  String get aiShortcutPremium => 'प्रीमियम सुविधा';

  @override
  String get homeAboutTitle => 'साइनोवॉइस क्या है?';

  @override
  String get homeAboutBody =>
      'साइनोवॉइस साइन करने वालों और साइन भाषा न जानने वालों को एक-दूसरे को समझने में मदद करता है। साइन को टेक्स्ट और आवाज़ में बदलें, आवाज़ को साइन में बदलें, लाइव दुभाषिये से बात करें और भारतीय साइन भाषा सीखें।';

  @override
  String get homeMore => 'साइनोवॉइस के साथ और';

  @override
  String get homeHowTitle => 'यह कैसे काम करता है';

  @override
  String get homeHow1 =>
      'चुनें कि आप क्या करना चाहते हैं: साइन से टेक्स्ट, आवाज़ से साइन, या लाइव दुभाषिया।';

  @override
  String get homeHow2 =>
      'कैमरे को अपने हाथ दिखाएं या बोलें। पहचान आपके फ़ोन पर ही होती है।';

  @override
  String get homeHow3 =>
      'अनुवाद तुरंत पढ़ें, सुनें या देखें, और बाद में इतिहास में पाएं।';

  @override
  String get homeCommunityTitle => 'बधिर और वाक्-बाधित समुदाय के लिए बनाया गया';

  @override
  String get homeCommunityBody =>
      'आप समझे जाने के हक़दार हैं — घर पर, स्कूल में, काम पर और डॉक्टर के पास। साइनोवॉइस आपके साइन को टेक्स्ट और आवाज़ में बदलता है, दूसरों की बात को साइन में बदलता है, और ज़रूरत पड़ने पर लाइव दुभाषिये से जोड़ता है।';

  @override
  String get homeBenefit1Title => 'कहीं भी समझे जाएं';

  @override
  String get homeBenefit1Body =>
      'कैमरे के सामने साइन करें और फ़ोन आपकी ओर से बोलेगा।';

  @override
  String get homeBenefit2Title => 'दूसरों को समझें';

  @override
  String get homeBenefit2Body => 'बोलें या लिखें और हर शब्द का साइन देखें।';

  @override
  String get homeBenefit3Title => 'परिवार और दोस्त भी सीख सकते हैं';

  @override
  String get homeBenefit3Body => 'सभी के लिए भारतीय साइन भाषा के छोटे पाठ।';

  @override
  String get homeBenefit4Title => 'डिज़ाइन से निजी';

  @override
  String get homeBenefit4Body =>
      'हाथ की पहचान आपके फ़ोन पर चलती है; आपका कैमरा वीडियो अपलोड नहीं होता।';

  @override
  String get homeShareCta => 'जिसे साइनोवॉइस की ज़रूरत हो उसे बताएं';

  @override
  String get homeShareMessage =>
      'साइनोवॉइस बधिर और वाक्-बाधित लोगों को संवाद करने में मदद करता है — यह साइन को टेक्स्ट और आवाज़ में, और आवाज़ को साइन में बदलता है। मुफ़्त पाएं: https://play.google.com/store/apps/details?id=com.anirudhzalki.signovoice';

  @override
  String get shareWithOthers => 'साइनोवॉइस दूसरों के साथ साझा करें';

  @override
  String get introSignToText => 'साइन → टेक्स्ट';

  @override
  String get introVoiceToSign => 'आवाज़ → साइन';

  @override
  String get introLive => 'लाइव दुभाषिया';

  @override
  String get introLearn => 'साइन सीखें';

  @override
  String get signStatusReady => 'ऑन-डिवाइस मॉडल तैयार';

  @override
  String get signStatusOnline => 'ऑनलाइन पहचान';

  @override
  String get signStatusLoading => 'मॉडल लोड हो रहा है…';

  @override
  String get signStatusUnavailable => 'मॉडल उपलब्ध नहीं';

  @override
  String get showHandHint => 'कैमरे को अपना हाथ दिखाएं';

  @override
  String get handDetected => 'हाथ मिला';

  @override
  String get currentSign => 'वर्तमान साइन';

  @override
  String get translationLabel => 'अनुवाद';

  @override
  String get translationPlaceholder =>
      'पहचाने गए साइन यहाँ टेक्स्ट के रूप में दिखेंगे।';

  @override
  String get recognisedSigns => 'पहचाने गए साइन';

  @override
  String get pause => 'रोकें';

  @override
  String get resume => 'फिर शुरू करें';

  @override
  String get speak => 'बोलें';

  @override
  String get stopSpeaking => 'बोलना रोकें';

  @override
  String get replay => 'दोबारा चलाएं';

  @override
  String get play => 'चलाएं';

  @override
  String get flipCamera => 'कैमरा पलटें';

  @override
  String get flashOn => 'फ़्लैश चालू करें';

  @override
  String get flashOff => 'फ़्लैश बंद करें';

  @override
  String get historyTitle => 'इतिहास';

  @override
  String get cameraPermTitle => 'कैमरा एक्सेस आवश्यक है';

  @override
  String get cameraPermBody =>
      'साइनोवॉइस कैमरे का उपयोग केवल इस स्क्रीन पर हाथ देखने के लिए करता है। हाथ की स्थिति आपके डिवाइस पर विश्लेषित होती है। वीडियो कभी रिकॉर्ड या अपलोड नहीं किया जाता।';

  @override
  String get micPermTitle => 'माइक्रोफ़ोन एक्सेस आवश्यक है';

  @override
  String get micPermBody =>
      'साइनोवॉइस केवल तब सुनता है जब आप माइक्रोफ़ोन बटन दबाते हैं, ताकि आपकी बोली को टेक्स्ट में बदला जा सके। बोली पहचान आपके डिवाइस की स्पीच सेवा द्वारा दी जाती है और इसके लिए इंटरनेट आवश्यक हो सकता है।';

  @override
  String get cameraInitError =>
      'कैमरा शुरू नहीं हो सका। कैमरा उपयोग करने वाले अन्य ऐप बंद करें और पुनः प्रयास करें।';

  @override
  String get handTrackingUnsupported =>
      'इस डिवाइस पर हैंड ट्रैकिंग अभी समर्थित नहीं है।';

  @override
  String signsLeftToday(String count) {
    return 'आज $count साइन शेष';
  }

  @override
  String get limitReachedTitle => 'दैनिक निःशुल्क सीमा पूरी हुई';

  @override
  String get limitReachedBody =>
      'असीमित साइन पहचान के लिए अपग्रेड करें, या कल फिर आएं।';

  @override
  String get seePremium => 'प्रीमियम देखें';

  @override
  String get saveToHistory => 'इतिहास में सहेजें';

  @override
  String get savedToHistory => 'इतिहास में सहेजा गया';

  @override
  String get historyOffHint => 'गोपनीयता सेटिंग्स में इतिहास बंद है।';

  @override
  String get outputLanguage => 'आउटपुट भाषा';

  @override
  String get voiceSettings => 'आवाज़ सेटिंग्स';

  @override
  String get voiceSpeed => 'बोलने की गति';

  @override
  String get voiceLanguage => 'आवाज़ की भाषा';

  @override
  String get voiceSelect => 'आवाज़';

  @override
  String get voiceDefault => 'डिफ़ॉल्ट आवाज़';

  @override
  String get voiceNoneForLanguage =>
      'इस भाषा की कोई आवाज़ आपके डिवाइस पर इंस्टॉल नहीं है। अपने डिवाइस की टेक्स्ट-टू-स्पीच सेटिंग्स में इंस्टॉल करें।';

  @override
  String get pausedLabel => 'रुका हुआ';

  @override
  String get listeningLabel => 'सुन रहा है…';

  @override
  String get recognitionPaused => 'पहचान रुकी हुई है';

  @override
  String get scanningHand => 'हाथ खोज रहा है';

  @override
  String get noSignYet => 'अभी कोई साइन नहीं';

  @override
  String liveTranslation(String text) {
    return 'लाइव अनुवाद: $text';
  }

  @override
  String get clearedAnnouncement => 'साफ़ किया गया';

  @override
  String recognisedAnnouncement(String sign) {
    return 'पहचाना गया $sign';
  }

  @override
  String get historySearchHint => 'इतिहास खोजें';

  @override
  String get historyEmptyTitle => 'अभी कोई इतिहास नहीं';

  @override
  String get historyEmptyBody =>
      'आपके सहेजे गए अनुवाद यहाँ दिखेंगे, केवल इसी डिवाइस पर।';

  @override
  String get historyNoResults => 'आपकी खोज से कोई मेल नहीं';

  @override
  String get historyClearAll => 'पूरा इतिहास साफ़ करें';

  @override
  String get historyClearTitle => 'पूरा इतिहास साफ़ करें?';

  @override
  String get historyClearBody =>
      'यह इस डिवाइस से सभी सहेजे गए अनुवाद स्थायी रूप से हटा देगा।';

  @override
  String get historyDeleted => 'प्रविष्टि हटाई गई';

  @override
  String get historyCleared => 'इतिहास साफ़ किया गया';

  @override
  String historyHidden(String count) {
    return 'निःशुल्क योजना में $count पुरानी प्रविष्टियाँ छिपी हैं';
  }

  @override
  String get historyHiddenTitle => 'पूरा इतिहास प्रीमियम सुविधा है';

  @override
  String durationSeconds(String seconds) {
    return '$seconds सेकंड';
  }

  @override
  String inputTypeLabel(String type) {
    return 'इनपुट: $type';
  }

  @override
  String get catAlphabet => 'वर्णमाला';

  @override
  String get catNumbers => 'संख्याएँ';

  @override
  String get catGreetings => 'अभिवादन';

  @override
  String get catDaily => 'दैनिक बातचीत';

  @override
  String get catFamily => 'परिवार';

  @override
  String get catFood => 'भोजन';

  @override
  String get catEducation => 'शिक्षा';

  @override
  String get catHealthcare => 'स्वास्थ्य सेवा';

  @override
  String get catTravel => 'यात्रा';

  @override
  String get catEmergency => 'आपातकाल';

  @override
  String get catWorkplace => 'कार्यस्थल';

  @override
  String get catPhrases => 'आम वाक्यांश';

  @override
  String get learnTitle => 'भारतीय साइन भाषा सीखें';

  @override
  String get learnSubtitle => 'छोटे पाठ, एक बार में एक विषय।';

  @override
  String get yourProgress => 'आपकी प्रगति';

  @override
  String xpValue(String xp) {
    return '$xp XP';
  }

  @override
  String levelValue(String level) {
    return 'स्तर $level';
  }

  @override
  String streakValue(String days) {
    return '$days दिन की लगातार गतिविधि';
  }

  @override
  String learnedOf(String learned, String total) {
    return '$total में से $learned साइन सीखे';
  }

  @override
  String get topics => 'विषय';

  @override
  String lessonN(String n) {
    return 'पाठ $n';
  }

  @override
  String lessonProgress(String done, String total) {
    return '$total में से $done सीखे';
  }

  @override
  String get lessonComplete => 'पाठ पूर्ण';

  @override
  String lessonCompleteBody(String count) {
    return 'बहुत बढ़िया। आपने इस पाठ में $count साइन सीखे।';
  }

  @override
  String get markLearned => 'मुझे यह साइन आता है';

  @override
  String get signLearned => 'सीख लिया';

  @override
  String get savedSigns => 'सहेजे गए साइन';

  @override
  String get bookmarkAdd => 'यह साइन सहेजें';

  @override
  String get bookmarkRemove => 'सहेजे गए से हटाएं';

  @override
  String get noSavedSigns => 'आपने अभी कोई साइन सहेजा नहीं है।';

  @override
  String get previous => 'पिछला';

  @override
  String get finishLesson => 'पाठ समाप्त करें';

  @override
  String signOfTotal(String current, String total) {
    return 'साइन $current / $total';
  }

  @override
  String get learningAnalytics => 'सीखने का विश्लेषण';

  @override
  String get analyticsLocked => 'विस्तृत सीखने का विश्लेषण प्रीमियम सुविधा है।';

  @override
  String get analyticsLockedBody =>
      'सटीकता, विषय अनुसार प्रगति और पिछले सप्ताह की गतिविधि देखें।';

  @override
  String get accuracyLabel => 'अभ्यास की सटीकता';

  @override
  String get attemptsLabel => 'प्रयास';

  @override
  String get completionByTopic => 'विषय अनुसार पूर्णता';

  @override
  String get lastSevenDays => 'पिछले 7 दिन';

  @override
  String activityDay(String count, String day) {
    return '$day: $count गतिविधियाँ';
  }

  @override
  String get badgesTitle => 'बैज';

  @override
  String get badgeLocked => 'अभी अर्जित नहीं';

  @override
  String get badgeFirstSign => 'पहला साइन सीखा';

  @override
  String get badgeTenSigns => '10 साइन सीखे';

  @override
  String get badgeFirstCorrect => 'पहला सही अभ्यास';

  @override
  String get badgeTenCorrect => '10 सही अभ्यास';

  @override
  String get badgeStreak3 => '3 दिन की लगातार गतिविधि';

  @override
  String get badgeStreak7 => '7 दिन की लगातार गतिविधि';

  @override
  String get dictionaryTitle => 'साइन शब्दकोश';

  @override
  String get dictionarySearchHint => 'साइन खोजें, जैसे Hello या Water';

  @override
  String get allCategories => 'सभी';

  @override
  String get dictionaryNoResults => 'आपकी खोज से कोई साइन मेल नहीं खाता।';

  @override
  String get signVideoUnavailable => 'साइन वीडियो अभी उपलब्ध नहीं';

  @override
  String get signVideoUnavailableBody =>
      'यह साइन सूचीबद्ध है, लेकिन इसका वीडियो अभी जोड़ा नहीं गया है।';

  @override
  String get hasVideo => 'वीडियो उपलब्ध';

  @override
  String get listenPronunciation => 'सुनें';

  @override
  String get practiceThisSign => 'इस साइन का अभ्यास करें';

  @override
  String practiceNotAvailable(String count) {
    return 'इस साइन के लिए कैमरा अभ्यास अभी उपलब्ध नहीं है। पहचानकर्ता अभी $count साइन जानता है।';
  }

  @override
  String get meaningLabel => 'अर्थ';

  @override
  String get categoryLabel => 'विषय';

  @override
  String get playVideo => 'वीडियो चलाएं';

  @override
  String get pauseVideo => 'वीडियो रोकें';

  @override
  String get videoError => 'वीडियो नहीं चलाया जा सका।';

  @override
  String get entryNotFound => 'वह साइन नहीं मिला।';

  @override
  String get practiceHubTitle => 'अभ्यास';

  @override
  String get practiceIntro =>
      'अपने कैमरे को साइन दिखाएं। आपका डिवाइस उसे जाँचता है और तुरंत प्रतिक्रिया देता है।';

  @override
  String get practiceAvailableSigns => 'जिनका अभ्यास आप अभी कर सकते हैं';

  @override
  String practicePrompt(String sign) {
    return '$sign का साइन दिखाएं';
  }

  @override
  String get startPractice => 'शुरू करें';

  @override
  String get getReady => 'तैयार हो जाएं…';

  @override
  String get signNow => 'अब साइन करें';

  @override
  String get checking => 'जाँच रहा है…';

  @override
  String get recognisedLabel => 'पहचाना गया';

  @override
  String get resultCorrect => 'सही';

  @override
  String get resultTryAgain => 'फिर कोशिश करें';

  @override
  String get resultNoHand =>
      'हम आपका हाथ स्पष्ट नहीं देख सके। बेहतर रोशनी में फिर कोशिश करें।';

  @override
  String get nextSign => 'अगला साइन';

  @override
  String xpEarned(String xp) {
    return '+$xp XP';
  }

  @override
  String get watchReference => 'साइन देखें';

  @override
  String countdownNumber(String n) {
    return '$n';
  }

  @override
  String get vsTitle => 'आवाज़ → साइन';

  @override
  String get vsHint => 'माइक्रोफ़ोन दबाकर बोलें, या नीचे टाइप करें।';

  @override
  String get typeHere => 'टेक्स्ट टाइप या पेस्ट करें';

  @override
  String get showSigns => 'साइन दिखाएं';

  @override
  String get tapToSpeak => 'बोलने के लिए दबाएं';

  @override
  String get tapToStop => 'रोकने के लिए दबाएं';

  @override
  String get speechUnavailable =>
      'इस डिवाइस पर बोली पहचान उपलब्ध नहीं है। आप टाइप कर सकते हैं।';

  @override
  String get speechNothingHeard => 'हमने कुछ नहीं सुना। फिर कोशिश करें।';

  @override
  String get speechLanguage => 'बोली की भाषा';

  @override
  String get signsForText => 'साइन';

  @override
  String get noSignYetForWord => 'अभी कोई साइन उपलब्ध नहीं';

  @override
  String missingSignsNote(String count) {
    return '$count शब्दों के लिए शब्दकोश में अभी साइन नहीं है।';
  }

  @override
  String get heardLabel => 'हमने क्या सुना';

  @override
  String get liveTitle => 'लाइव दुभाषिया';

  @override
  String get liveIntro =>
      'वीडियो, ऑडियो या चैट से किसी मानव साइन-भाषा दुभाषिये से जुड़ें।';

  @override
  String get findInterpreter => 'उपलब्ध दुभाषिये';

  @override
  String get statusAvailable => 'उपलब्ध';

  @override
  String get statusBusy => 'व्यस्त';

  @override
  String get statusOffline => 'ऑफ़लाइन';

  @override
  String ratingValue(String count, String rating) {
    return '$rating ($count रेटिंग)';
  }

  @override
  String get noRatingsYet => 'अभी कोई रेटिंग नहीं';

  @override
  String get requestInterpreter => 'दुभाषिये का अनुरोध करें';

  @override
  String get requestVideoCall => 'वीडियो कॉल';

  @override
  String get requestAudioCall => 'ऑडियो कॉल';

  @override
  String get noteOptional => 'दुभाषिये के लिए नोट (वैकल्पिक)';

  @override
  String get noInterpretersNow =>
      'अभी कोई दुभाषिया उपलब्ध नहीं है। कुछ मिनट बाद फिर कोशिश करें।';

  @override
  String get interpreterNotConfigured =>
      'इस बिल्ड में लाइव दुभाषिया सेवा अभी सेट अप नहीं है।';

  @override
  String get signInForInterpreter =>
      'दुभाषिये का अनुरोध करने के लिए साइन इन करें';

  @override
  String get signInForInterpreterBody =>
      'दुभाषिया सत्रों के लिए खाता चाहिए ताकि कॉल जोड़े और रेट किए जा सकें।';

  @override
  String get callRequesting => 'आपका अनुरोध भेजा जा रहा है…';

  @override
  String get callWaiting => 'दुभाषिये की प्रतीक्षा…';

  @override
  String callQueue(String n) {
    return 'आप कतार में $n नंबर पर हैं';
  }

  @override
  String get callConnecting => 'जुड़ रहा है…';

  @override
  String get callConnected => 'जुड़ा हुआ';

  @override
  String get callReconnecting => 'फिर से जुड़ रहा है…';

  @override
  String get callEnded => 'कॉल समाप्त';

  @override
  String get callFailedTitle => 'कॉल पूरी नहीं हो सकी';

  @override
  String get callDeclined =>
      'कोई दुभाषिया आपका अनुरोध नहीं ले सका। कृपया फिर कोशिश करें।';

  @override
  String get callExpired =>
      'समय पर किसी दुभाषिये ने स्वीकार नहीं किया। कृपया फिर कोशिश करें।';

  @override
  String get cancelRequest => 'अनुरोध रद्द करें';

  @override
  String get muteMic => 'माइक्रोफ़ोन म्यूट करें';

  @override
  String get unmuteMic => 'माइक्रोफ़ोन अनम्यूट करें';

  @override
  String get cameraOffAction => 'कैमरा बंद करें';

  @override
  String get cameraOnAction => 'कैमरा चालू करें';

  @override
  String get endCall => 'कॉल समाप्त करें';

  @override
  String get chatTitle => 'चैट';

  @override
  String get chatHint => 'संदेश लिखें';

  @override
  String get sendMessage => 'भेजें';

  @override
  String get reportIssue => 'समस्या रिपोर्ट करें';

  @override
  String get issueAudio => 'ऑडियो समस्या';

  @override
  String get issueVideo => 'वीडियो समस्या';

  @override
  String get issueInterpreter => 'दुभाषिये का व्यवहार';

  @override
  String get issueConnection => 'कनेक्शन समस्या';

  @override
  String get issueOther => 'कुछ और';

  @override
  String get issueDescribe => 'हमें और बताएं (वैकल्पिक)';

  @override
  String get issueSent => 'धन्यवाद। हम इसे देखेंगे।';

  @override
  String get feedbackTitle => 'आपकी कॉल कैसी रही?';

  @override
  String feedbackStars(String n) {
    return '5 में से $n सितारे';
  }

  @override
  String get feedbackComment => 'टिप्पणियाँ (वैकल्पिक)';

  @override
  String get submitFeedback => 'प्रतिक्रिया भेजें';

  @override
  String get feedbackThanks => 'आपकी प्रतिक्रिया के लिए धन्यवाद।';

  @override
  String get skipFeedback => 'छोड़ें';

  @override
  String callDuration(String time) {
    return 'अवधि $time';
  }

  @override
  String interpreterConnectedTo(String name) {
    return '$name के साथ कॉल में';
  }

  @override
  String get waitingForVideo => 'दुभाषिये के वीडियो की प्रतीक्षा…';

  @override
  String get audioCallActive => 'ऑडियो कॉल चल रही है';

  @override
  String get devRoomTitle => 'टेस्ट रूम (केवल डीबग बिल्ड)';

  @override
  String get devRoomBody =>
      'आपके डेवलपमेंट टोकन वाले LiveKit रूम में जुड़ता है, ताकि आप बैकएंड के बिना वीडियो, ऑडियो और चैट टेस्ट कर सकें।';

  @override
  String get roomTitle => 'लाइव रूम में शामिल हों';

  @override
  String get roomBody =>
      'लाइव कॉल शुरू करने के लिए दूसरे व्यक्ति (या दुभाषिये) वाला ही रूम कोड दर्ज करें।';

  @override
  String get roomCodeLabel => 'रूम कोड';

  @override
  String get roomCodeInvalid => '3–40 अक्षर, अंक, - या _ का उपयोग करें';

  @override
  String get deskTitle => 'दुभाषिया डेस्क';

  @override
  String get deskNotInterpreter =>
      'यह खाता दुभाषिये के रूप में स्वीकृत नहीं है।';

  @override
  String get deskOnline => 'आप ऑनलाइन हैं';

  @override
  String get deskOffline => 'आप ऑफ़लाइन हैं';

  @override
  String get deskOnlineHint =>
      'अपनी भाषाओं से मेल खाने वाले अनुरोध पाने के लिए ऑनलाइन हों।';

  @override
  String get deskQueue => 'प्रतीक्षारत अनुरोध';

  @override
  String get deskGoOnline => 'प्रतीक्षारत अनुरोध देखने के लिए ऑनलाइन हों।';

  @override
  String get deskEmpty =>
      'अभी कोई प्रतीक्षा में नहीं है। यह सूची अपने आप अपडेट होती है।';

  @override
  String get deskSomeone => 'कोई';

  @override
  String deskWaiting(String seconds) {
    return '$seconds सेकंड से प्रतीक्षा में';
  }

  @override
  String get deskAccept => 'स्वीकार करें और जुड़ें';

  @override
  String get priceFree => 'निःशुल्क';

  @override
  String pricePerSession(String minutes, String price) {
    return '$price / $minutes मिनट';
  }

  @override
  String payAndConnect(String price) {
    return '$price चुकाएं और जुड़ें';
  }

  @override
  String get connectNow => 'अभी जुड़ें';

  @override
  String get payRefundNote =>
      'आप तभी भुगतान करते हैं जब दुभाषिया स्वीकार करे: समय पर कोई स्वीकार न करे या आप प्रतीक्षा में रद्द करें तो पैसे अपने आप वापस हो जाते हैं।';

  @override
  String sessionWith(String name) {
    return '$name के साथ सत्र';
  }

  @override
  String get becomeInterpreter => 'दुभाषिया बनें';

  @override
  String get becomeInterpreterBody =>
      'लोगों को संवाद में मदद करें और प्रति सत्र कमाएं। अपनी भाषाएं और दर तय करें, फिर जब खाली हों ऑनलाइन हों।';

  @override
  String get applicationPending =>
      'आपका दुभाषिया आवेदन स्वीकृति की प्रतीक्षा में है।';

  @override
  String get interpreterProfileTitle => 'दुभाषिया प्रोफ़ाइल';

  @override
  String get profileName => 'प्रदर्शित नाम';

  @override
  String get profileLanguages => 'जिन भाषाओं में आप दुभाषिया करते हैं';

  @override
  String profileRate(String minutes) {
    return 'प्रति $minutes-मिनट सत्र आपकी दर (₹)';
  }

  @override
  String get profileRateHint =>
      'निःशुल्क सत्र के लिए 0 या 1 से 5000 दर्ज करें। सशुल्क सत्रों से प्लेटफ़ॉर्म सेवा शुल्क रखता है।';

  @override
  String get profileBio => 'आपके बारे में (वैकल्पिक)';

  @override
  String get profileSave => 'प्रोफ़ाइल सहेजें';

  @override
  String get profileSaved => 'प्रोफ़ाइल सहेजी गई।';

  @override
  String get profileInvalidRate =>
      '0 या 1 से 5000 तक की पूर्ण संख्या दर्ज करें।';

  @override
  String get profilePickLanguage => 'कम से कम एक भाषा चुनें।';

  @override
  String get deskRate => 'आपकी दर';

  @override
  String deskEarnings(String amount) {
    return 'कुल कमाई: $amount';
  }

  @override
  String get deskEditProfile => 'प्रोफ़ाइल और दर बदलें';

  @override
  String deskYouEarn(String amount) {
    return 'आप कमाएंगे $amount';
  }

  @override
  String get deskDecline => 'अस्वीकार करें';

  @override
  String get callPaymentCancelled =>
      'भुगतान पूरा नहीं हुआ। आपसे कोई शुल्क नहीं लिया गया।';

  @override
  String get adminTitle => 'एडमिन: दुभाषिये';

  @override
  String get adminPending => 'लंबित';

  @override
  String get adminApproved => 'स्वीकृत';

  @override
  String get adminApprove => 'स्वीकृत करें';

  @override
  String get adminRevoke => 'स्वीकृति हटाएं';

  @override
  String get adminNonePending => 'कोई आवेदन प्रतीक्षा में नहीं।';

  @override
  String get adminNoneApproved => 'अभी कोई स्वीकृत दुभाषिया नहीं।';

  @override
  String get adminNotAllowed => 'यह पृष्ठ केवल प्रशासक खोल सकता है।';

  @override
  String get premiumHeader => 'पूरा साइनोवॉइस अनुभव अनलॉक करें';

  @override
  String get premiumSubheader =>
      'निःशुल्क योजना सचमुच उपयोगी रहती है। प्रीमियम सीमाएं हटाता है और गहरे टूल जोड़ता है।';

  @override
  String get freePlan => 'निःशुल्क';

  @override
  String get premiumPlan => 'प्रीमियम';

  @override
  String get featRecognition => 'साइन पहचान';

  @override
  String featRecognitionFree(String count) {
    return 'प्रतिदिन $count साइन तक';
  }

  @override
  String get featUnlimited => 'असीमित';

  @override
  String get featHistory => 'अनुवाद इतिहास';

  @override
  String featHistoryFree(String count) {
    return 'नवीनतम $count प्रविष्टियाँ';
  }

  @override
  String get featFullHistory => 'पूरा इतिहास';

  @override
  String get featAi => 'उन्नत एआई अनुवाद';

  @override
  String get featNotIncluded => 'शामिल नहीं';

  @override
  String get featIncludedOnline => 'शामिल (इंटरनेट आवश्यक)';

  @override
  String get featAnalytics => 'सीखने का विश्लेषण';

  @override
  String get featBasicProgress => 'बुनियादी प्रगति';

  @override
  String get featFullAnalytics => 'विस्तृत विश्लेषण';

  @override
  String get featCore => 'पाठ, शब्दकोश, अभ्यास, आवाज़ → साइन';

  @override
  String get featIncluded => 'शामिल';

  @override
  String get trialOneMonthFree => '1 महीना निःशुल्क';

  @override
  String trialThenPrice(String period, String price) {
    return 'फिर $price प्रति $period';
  }

  @override
  String get periodMonth => 'माह';

  @override
  String get periodYear => 'वर्ष';

  @override
  String get periodWeek => 'सप्ताह';

  @override
  String get periodDay => 'दिन';

  @override
  String get renewsAutomatically => 'अपने आप नवीनीकृत होता है';

  @override
  String get cancelAnytime => 'स्टोर की सदस्यता सेटिंग्स में कभी भी रद्द करें';

  @override
  String trialTerms(String period, String price) {
    return 'आपका पहला महीना निःशुल्क है। समाप्त होने पर, जब तक आप ट्रायल खत्म होने से पहले रद्द न करें, आपकी सदस्यता $price प्रति $period पर अपने आप नवीनीकृत होगी। Google Play में कभी भी रद्द करें: मेनू › भुगतान और सदस्यताएं › सदस्यताएं। शुल्क लगने से पहले आप Google Play में अंतिम कीमत देखेंगे और पुष्टि करेंगे।';
  }

  @override
  String subscribeTerms(String period, String price) {
    return 'आपकी सदस्यता रद्द करने तक $price प्रति $period पर अपने आप नवीनीकृत होती है। Google Play में कभी भी रद्द करें: मेनू › भुगतान और सदस्यताएं › सदस्यताएं। शुल्क लगने से पहले आप Google Play में अंतिम कीमत की पुष्टि करेंगे।';
  }

  @override
  String get priceShownAtCheckout =>
      'कीमत आपके पुष्टि करने से पहले Google Play दिखाएगा।';

  @override
  String get startFreeTrial => 'निःशुल्क ट्रायल शुरू करें';

  @override
  String get subscribeNow => 'सदस्यता लें';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get restorePurchases => 'खरीदारी पुनर्स्थापित करें';

  @override
  String get planMonthly => 'मासिक';

  @override
  String get planYearly => 'वार्षिक';

  @override
  String planPerPeriod(String period, String price) {
    return '$price / $period';
  }

  @override
  String get planFirstFree => 'पहला महीना निःशुल्क';

  @override
  String get trialOfferTitle => 'आपका पहला महीना निःशुल्क है';

  @override
  String get trialOfferBody => 'एक महीने तक हर प्रीमियम सुविधा आज़माएं।';

  @override
  String trialOfferPrice(String period, String price) {
    return 'ट्रायल के बाद $price प्रति $period';
  }

  @override
  String get trialNotAvailable =>
      'इस खाते के लिए निःशुल्क ट्रायल उपलब्ध नहीं है। आप प्रीमियम पृष्ठ से सदस्यता ले सकते हैं।';

  @override
  String get signInToSubscribe =>
      'निःशुल्क ट्रायल शुरू करने के लिए साइन इन करें';

  @override
  String get purchasePending =>
      'आपका भुगतान लंबित है। पूरा होने पर प्रीमियम अनलॉक होगा।';

  @override
  String get purchaseVerifying => 'आपकी खरीदारी सत्यापित की जा रही है…';

  @override
  String get purchaseSuccess => 'प्रीमियम सक्रिय है। धन्यवाद!';

  @override
  String get purchaseCancelled =>
      'खरीदारी रद्द की गई। आपसे कोई शुल्क नहीं लिया गया।';

  @override
  String get purchaseNeedsVerification =>
      'आपकी खरीदारी हो गई, लेकिन हम अभी उसे सत्यापित नहीं कर सके। कुछ भी नहीं खोया है — पुनः प्रयास दबाएं।';

  @override
  String get billingUnavailableMsg =>
      'इस डिवाइस पर Google Play खरीदारी अभी उपलब्ध नहीं है।';

  @override
  String get productsUnavailableMsg =>
      'सदस्यता योजनाएं लोड नहीं हो सकीं। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get restoreNone => 'इस खाते के लिए कोई सक्रिय सदस्यता नहीं मिली।';

  @override
  String get restoreOk => 'आपकी सदस्यता पुनर्स्थापित हो गई है।';

  @override
  String get statusFree => 'निःशुल्क योजना';

  @override
  String get statusTrial => 'निःशुल्क ट्रायल';

  @override
  String get statusPremium => 'प्रीमियम';

  @override
  String get statusExpired => 'समाप्त';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String trialDaysLeft(String days) {
    return 'आपके ट्रायल में $days दिन शेष';
  }

  @override
  String trialEnds(String date) {
    return 'ट्रायल $date को समाप्त होता है';
  }

  @override
  String renewsOn(String date) {
    return '$date को नवीनीकृत होगा';
  }

  @override
  String accessEndsOn(String date) {
    return 'पहुँच $date को समाप्त होती है';
  }

  @override
  String get expiredBody =>
      'आपकी प्रीमियम पहुँच समाप्त हो गई है। कभी भी फिर से सदस्यता लें।';

  @override
  String get freeBody => 'आप निःशुल्क योजना पर हैं।';

  @override
  String get autoRenewOn => 'ऑटो-रिन्यू चालू है';

  @override
  String get autoRenewOff => 'ऑटो-रिन्यू बंद है';

  @override
  String get manageSubscription => 'सदस्यता प्रबंधित करें';

  @override
  String get manageInStore => 'Google Play में प्रबंधित करें';

  @override
  String get refreshStatus => 'स्थिति ताज़ा करें';

  @override
  String get statusRefreshed => 'स्थिति अपडेट हुई';

  @override
  String lastVerified(String date) {
    return 'अंतिम सत्यापन $date';
  }

  @override
  String get notVerifiedYet => 'सर्वर से अभी सत्यापित नहीं';

  @override
  String planName(String name) {
    return 'योजना: $name';
  }

  @override
  String get premiumBenefitsTitle => 'प्रीमियम लाभ';

  @override
  String get benefitUnlimited => 'असीमित साइन पहचान';

  @override
  String benefitUnlimitedBody(String count) {
    return 'जितने चाहें उतने साइन पहचानें। निःशुल्क खाते प्रतिदिन $count साइन तक पहचान सकते हैं।';
  }

  @override
  String benefitHistoryBody(String count) {
    return 'अपना पूरा अनुवाद इतिहास इस डिवाइस पर रखें। निःशुल्क योजना नवीनतम $count प्रविष्टियाँ दिखाती है।';
  }

  @override
  String get benefitAiBody =>
      'ऑनलाइन एआई अनुवाद सेवा से अधिक सहज वाक्य। इंटरनेट आवश्यक है; अन्यथा ऑन-डिवाइस अनुवाद उपयोग होता है।';

  @override
  String get benefitAnalyticsBody =>
      'सटीकता, विषय अनुसार पूर्णता और पिछले सप्ताह की गतिविधि देखें।';

  @override
  String get alwaysFreeTitle => 'हमेशा निःशुल्क';

  @override
  String get alwaysFreeBody =>
      'ऑन-डिवाइस साइन पहचान (दैनिक सीमा के साथ), आवाज़ → साइन, साइन शब्दकोश, सभी पाठ और अभ्यास।';

  @override
  String get seeAllBenefits => 'सभी लाभ देखें';

  @override
  String get payWith => 'इससे भुगतान करें';

  @override
  String get payGooglePlay => 'Google Play';

  @override
  String get payRazorpay => 'UPI, कार्ड और वॉलेट';

  @override
  String get payRazorpayNote =>
      'Razorpay द्वारा सुरक्षित चेकआउट। Google Pay, PhonePe, Paytm और अन्य UPI ऐप ऑटो-पे का समर्थन करते हैं; आप अपने UPI ऐप में मैंडेट स्वीकृत करते हैं।';

  @override
  String get priceAtCheckout => 'कीमत चेकआउट पर दिखाई जाएगी';

  @override
  String get razorpayTerms =>
      'ऑटो-पे रद्द करने तक आपकी सदस्यता नवीनीकृत करता है। आप Razorpay चेकआउट में भुगतान स्वीकृत करते हैं और अंतिम कीमत देखते हैं। सदस्यता प्रबंधित करें से कभी भी रद्द करें।';

  @override
  String get cancelAutoRenew => 'ऑटो-रिन्यू रद्द करें';

  @override
  String get cancelAutoRenewBody =>
      'आपने जिस अवधि का भुगतान किया है उसके अंत तक प्रीमियम रहेगा। आगे कोई भुगतान नहीं लिया जाएगा।';

  @override
  String get cancelAutoRenewConfirm => 'ऑटो-रिन्यू रद्द करें';

  @override
  String get keepSubscription => 'सदस्यता रखें';

  @override
  String get autoRenewCancelled =>
      'ऑटो-रिन्यू रद्द हुआ। भुगतान की अवधि के अंत तक प्रीमियम रहेगा।';

  @override
  String get premiumHeroTitle => 'सीमाओं के बिना साइन करें';

  @override
  String get premiumHeroBody =>
      'असीमित पहचान, पूरा इतिहास, विस्तृत प्रगति और बेहतर वाक्य।';

  @override
  String get testPaymentButton => 'टेस्ट भुगतान ₹1 (Razorpay)';

  @override
  String get testPaymentOk => 'टेस्ट भुगतान सत्यापित हुआ।';

  @override
  String get testPaymentCancelled => 'भुगतान रद्द किया गया।';

  @override
  String get testPaymentFailed => 'भुगतान विफल रहा या सत्यापित नहीं हो सका।';

  @override
  String get razorpayUnavailableMsg =>
      'इस बिल्ड में ऑनलाइन भुगतान अभी सेट नहीं है। Google Play आज़माएं या सहायता से संपर्क करें।';

  @override
  String get razorpayPlansUnavailableMsg =>
      'भुगतान सर्वर से योजनाएं लोड नहीं हो सकीं। कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get tryOtherPayment =>
      'Play योजनाएं उपलब्ध नहीं? UPI, कार्ड या वॉलेट से भुगतान करें।';

  @override
  String get planSixMonth => '6 महीने';

  @override
  String periodMonths(String count) {
    return '$count महीने';
  }

  @override
  String periodYears(String count) {
    return '$count वर्ष';
  }

  @override
  String planSave(String percent) {
    return '$percent% बचाएं';
  }

  @override
  String get notifLearnTitle => 'अभ्यास का समय';

  @override
  String get notifLearnBody =>
      'दिन में कुछ साइन उन्हें ताज़ा रखते हैं। आज सीखने के लिए साइनोवॉइस खोलें।';

  @override
  String get notifStreakTitle => 'अपनी लगातार गतिविधि जारी रखें';

  @override
  String get notifStreakBody =>
      'थोड़ा अभ्यास आपकी लगातार गतिविधि बनाए रखता है।';

  @override
  String get notifTrialTitle => 'आपका निःशुल्क ट्रायल समाप्त होने वाला है';

  @override
  String notifTrialBody(String date, String days) {
    return 'आपका निःशुल्क ट्रायल $days दिन में, $date को समाप्त होगा। जारी नहीं रखना चाहते तो Google Play में रद्द करें।';
  }

  @override
  String get notifRenewalTitle => 'प्रीमियम जल्द नवीनीकृत होगा';

  @override
  String notifRenewalBody(String date) {
    return 'आपकी प्रीमियम सदस्यता $date को नवीनीकृत होगी। आप इसे कभी भी Google Play में प्रबंधित कर सकते हैं।';
  }

  @override
  String get notificationsTitle => 'सूचनाएं';

  @override
  String get notificationsEmpty => 'आप पूरी तरह अपडेट हैं।';

  @override
  String get notificationsEmptyBody =>
      'अनुस्मारक, सदस्यता अपडेट और दुभाषिया संदेश यहाँ दिखेंगे।';

  @override
  String get markAllRead => 'सभी को पढ़ा हुआ चिह्नित करें';

  @override
  String get notificationNew => 'नया';

  @override
  String unreadCount(String count) {
    return '$count अपठित सूचनाएं';
  }

  @override
  String get notifSettingsTitle => 'सूचना सेटिंग्स';

  @override
  String get notifPermissionOff =>
      'इस डिवाइस पर साइनोवॉइस के लिए सूचनाएं बंद हैं।';

  @override
  String get notifPermissionAsk => 'सूचनाओं की अनुमति दें';

  @override
  String get notifLearning => 'सीखने के अनुस्मारक';

  @override
  String get notifStreakSetting => 'अभ्यास की लगातार गतिविधि';

  @override
  String get notifTrialSetting => 'निःशुल्क ट्रायल अनुस्मारक';

  @override
  String get notifRenewalSetting => 'नवीनीकरण की जानकारी';

  @override
  String get notifInterpreterSetting => 'दुभाषिया अनुरोध अपडेट';

  @override
  String get notifSystemSetting => 'सिस्टम सूचनाएं';

  @override
  String get reminderTime => 'अनुस्मारक का समय';

  @override
  String get guestName => 'अतिथि';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get usageTitle => 'उपयोग';

  @override
  String usageSigns(String count) {
    return 'आज पहचाने गए साइन: $count';
  }

  @override
  String usageSignsOfLimit(String count, String limit) {
    return 'आज पहचाने गए साइन: $limit में से $count';
  }

  @override
  String usageHistory(String count) {
    return 'सहेजे गए अनुवाद: $count';
  }

  @override
  String usageLearned(String count) {
    return 'सीखे गए साइन: $count';
  }

  @override
  String get sectionAccount => 'खाता';

  @override
  String get sectionPreferences => 'प्राथमिकताएं';

  @override
  String get sectionSupport => 'सहायता';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get themeSystem => 'डिवाइस के अनुसार';

  @override
  String get themeLight => 'हल्की';

  @override
  String get themeDark => 'गहरी';

  @override
  String get settingsAccessibility => 'पहुँच-योग्यता';

  @override
  String get settingsVoice => 'आवाज़';

  @override
  String get settingsTranslation => 'अनुवाद';

  @override
  String get settingsPrivacy => 'गोपनीयता और डेटा';

  @override
  String get settingsSubscription => 'प्रीमियम लें';

  @override
  String get settingsAbout => 'साइनोवॉइस के बारे में';

  @override
  String get settingsHelp => 'सहायता और समर्थन';

  @override
  String get settingsSecurity => 'सुरक्षा';

  @override
  String get accTextSize => 'टेक्स्ट का आकार';

  @override
  String get accTextSizePreview => 'नमस्ते! टेक्स्ट ऐसा दिखेगा।';

  @override
  String get accHighContrast => 'उच्च कंट्रास्ट';

  @override
  String get accHighContrastDesc => 'अधिक स्पष्ट किनारे और टेक्स्ट रंग।';

  @override
  String get accReduceMotion => 'गति कम करें';

  @override
  String get accReduceMotionDesc =>
      'स्कैनिंग स्वीप, पल्स और पेज ट्रांज़िशन बंद करता है।';

  @override
  String get accHaptics => 'हैप्टिक फ़ीडबैक';

  @override
  String get accHapticsDesc => 'साइन पहचाने जाने पर छोटा कंपन।';

  @override
  String get accVoiceFeedback => 'बोला गया फ़ीडबैक';

  @override
  String get accVoiceFeedbackDesc => 'अभ्यास के परिणाम बोलकर बताएं।';

  @override
  String get transMode => 'पहचान मोड';

  @override
  String get transOnDevice => 'इसी डिवाइस पर';

  @override
  String get transOnDeviceDesc => 'निजी और ऑफ़लाइन काम करता है।';

  @override
  String get transOnline => 'ऑनलाइन (सर्वर)';

  @override
  String get transOnlineDesc =>
      'हाथ के लैंडमार्क अंक भेजता है, वीडियो कभी नहीं। इंटरनेट और कॉन्फ़िगर किया सर्वर चाहिए।';

  @override
  String get transOnlineUnavailable =>
      'इस बिल्ड में ऑनलाइन पहचान सेट अप नहीं है।';

  @override
  String get transConfidence => 'विश्वसनीयता सीमा';

  @override
  String get transConfidenceDesc => 'अधिक का मतलब कम लेकिन अधिक भरोसेमंद साइन।';

  @override
  String get transAutoSpeak => 'साइन अपने आप बोलें';

  @override
  String get transMirror => 'हाथ का इनपुट मिरर करें';

  @override
  String get transMirrorDesc =>
      'प्रशिक्षण डेटा से मेल खाता है। केवल तब बंद करें जब बायाँ-दायाँ उलटा लगे।';

  @override
  String transModelNote(String count) {
    return 'ऑन-डिवाइस मॉडल अभी $count साइन पहचानता है और गलतियाँ कर सकता है।';
  }

  @override
  String get privacyAnalytics => 'अनाम उपयोग और क्रैश डेटा साझा करें';

  @override
  String get privacyAnalyticsDesc =>
      'समस्याएं ठीक करने में मदद करता है। इसमें वीडियो, साइन या अनुवाद कभी शामिल नहीं होते।';

  @override
  String get privacySaveHistory => 'इस डिवाइस पर अनुवाद इतिहास सहेजें';

  @override
  String get privacyClearHistory => 'अनुवाद इतिहास साफ़ करें';

  @override
  String get privacyClearProgress => 'सीखने की प्रगति रीसेट करें';

  @override
  String get privacyClearProgressBody =>
      'यह इस डिवाइस से सीखे गए साइन, सहेजे गए साइन, XP, लगातार गतिविधि और बैज हटा देगा।';

  @override
  String get privacyProgressCleared => 'सीखने की प्रगति रीसेट हुई';

  @override
  String get privacyDataTitle => 'कौन सा डेटा संसाधित होता है';

  @override
  String get privacyDataCamera =>
      'कैमरा: हाथ की स्थिति खोजने के लिए आपके डिवाइस पर विश्लेषित। वीडियो कभी रिकॉर्ड या अपलोड नहीं होता। ऑनलाइन मोड में केवल हाथ के लैंडमार्क अंक भेजे जाते हैं।';

  @override
  String get privacyDataMic =>
      'माइक्रोफ़ोन: केवल तब जब आप माइक दबाएं या दुभाषिया कॉल में जुड़ें। बोली-से-टेक्स्ट आपके डिवाइस की स्पीच सेवा उपयोग करता है।';

  @override
  String get privacyDataAccount =>
      'खाता: आपका नाम, ईमेल या फ़ोन, और प्रोफ़ाइल फ़ोटो हमारे प्रमाणीकरण और डेटाबेस प्रदाता (Firebase) के पास रखे जाते हैं।';

  @override
  String get privacyDataHistory =>
      'इतिहास और सीखने की प्रगति: केवल इसी डिवाइस पर संग्रहीत।';

  @override
  String get privacyDataPurchases =>
      'सदस्यताएं: भुगतान Google Play संभालता है। हमें आपका प्लान सत्यापित करने के लिए खरीद टोकन मिलता है, कार्ड विवरण नहीं।';

  @override
  String get privacyDataCalls =>
      'दुभाषिया कॉल: ऑडियो और वीडियो हमारे कॉल प्रदाता के माध्यम से आपके दुभाषिये तक स्ट्रीम होते हैं। हम कॉल का समय, अवधि और आपकी रेटिंग रखते हैं।';

  @override
  String get privacyDataAnalytics =>
      'उपयोग और क्रैश डेटा: अनाम इवेंट (जैसे \"अभ्यास शुरू\") और क्रैश रिपोर्ट, केवल यदि आप ऊपर अनुमति दें।';

  @override
  String get privacyRequestDeletion =>
      'मेरे सर्वर डेटा को हटाने का अनुरोध करें';

  @override
  String get privacyDeletionRequested =>
      'हटाने का अनुरोध किया गया। आपका सर्वर-साइड डेटा मिटाया जाएगा।';

  @override
  String get privacyDeleteAccount => 'खाता हटाएं';

  @override
  String securitySignedInAs(String who) {
    return '$who के रूप में साइन इन';
  }

  @override
  String get securityChangePassword => 'पासवर्ड बदलें';

  @override
  String get securityPasswordSent =>
      'हमने आपके ईमेल पर पासवर्ड रीसेट लिंक भेजा है।';

  @override
  String get securityGuest =>
      'अतिथि मोड डेटा केवल इसी डिवाइस पर रखता है। अपना प्लान सुरक्षित और सिंक करने के लिए खाता बनाएं।';

  @override
  String get createAccountAction => 'खाता बनाएं';

  @override
  String get logoutTitle => 'साइन आउट करें?';

  @override
  String get logoutBody => 'आप कभी भी फिर से साइन इन कर सकते हैं।';

  @override
  String get logoutClearData => 'इस डिवाइस पर इतिहास और प्रगति भी साफ़ करें';

  @override
  String get deleteTitle => 'अपना खाता हटाएं';

  @override
  String get deleteBody =>
      'यह आपका खाता और हमारे पास आपका डेटा स्थायी रूप से हटा देगा, और इस डिवाइस का डेटा साफ़ करेगा। इसे पूर्ववत नहीं किया जा सकता। खाता हटाने से Google Play सदस्यता रद्द नहीं होती; पहले उसे Google Play में रद्द करें।';

  @override
  String get deleteGuestBody =>
      'यह इस डिवाइस पर साइनोवॉइस द्वारा संग्रहीत सब कुछ साफ़ कर देगा।';

  @override
  String get deleteConfirmCheck => 'मैं समझता/समझती हूँ कि यह स्थायी है';

  @override
  String get deleteAction => 'स्थायी रूप से हटाएं';

  @override
  String get deleteRecentLogin =>
      'आपकी सुरक्षा के लिए, फिर से साइन इन करें, फिर अपना खाता हटाएं।';

  @override
  String get deleteAndSignOut => 'साइन आउट करें और फिर साइन इन करें';

  @override
  String get helpTitle => 'सहायता और समर्थन';

  @override
  String get faq1q => 'मेरा साइन क्यों नहीं पहचाना गया?';

  @override
  String faq1a(String count) {
    return 'अच्छी रोशनी में रहें, पूरा हाथ कैमरे में रखें और स्थिर गति से साइन करें। ऑन-डिवाइस मॉडल अभी $count साइन पहचानता है।';
  }

  @override
  String get faq2q => 'क्या साइनोवॉइस मेरा वीडियो रिकॉर्ड करता है?';

  @override
  String get faq2a =>
      'नहीं। वीडियो हाथ की स्थिति खोजने के लिए आपके डिवाइस पर विश्लेषित होता है और कभी रिकॉर्ड या अपलोड नहीं होता।';

  @override
  String get faq3q => 'निःशुल्क ट्रायल कैसे काम करता है?';

  @override
  String get faq3a =>
      'नए खाते एक महीने का निःशुल्क ट्रायल शुरू कर सकते हैं। जब तक आप समाप्त होने से पहले Google Play में रद्द न करें, यह दिखाई गई कीमत पर अपने आप नवीनीकृत होता है।';

  @override
  String get faq4q => 'मैं अपनी सदस्यता कैसे रद्द करूँ?';

  @override
  String get faq4a =>
      'Google Play खोलें › भुगतान और सदस्यताएं › सदस्यताएं › SignoVoice › सदस्यता रद्द करें।';

  @override
  String get faq5q => 'क्या मैं साइनोवॉइस ऑफ़लाइन उपयोग कर सकता/सकती हूँ?';

  @override
  String get faq5a =>
      'हाँ, ऑन-डिवाइस साइन पहचान, शब्दकोश और पाठों के लिए। लाइव दुभाषिये, ऑनलाइन पहचान और एआई अनुवाद के लिए इंटरनेट चाहिए।';

  @override
  String get faq6q => 'कुछ साइन के वीडियो क्यों नहीं हैं?';

  @override
  String get faq6a =>
      'शब्दकोश में उन साइन से अधिक हैं जिनके वीडियो हमारे पास हैं। वीडियो समय के साथ जोड़े जाते हैं।';

  @override
  String get helpContact => 'सहायता से संपर्क करें';

  @override
  String get helpEmailSubject => 'साइनोवॉइस सहायता';

  @override
  String aboutVersion(String build, String version) {
    return 'संस्करण $version ($build)';
  }

  @override
  String get aboutMission =>
      'एआई-संचालित साइन-भाषा तकनीक से संवाद की बाधाएं तोड़ना।';

  @override
  String aboutModelNote(String count) {
    return 'साइन पहचान एक सहायक है, प्रमाणित दुभाषिया नहीं। यह अभी $count साइन जानता है और गलतियाँ कर सकता है। महत्वपूर्ण बातचीत के लिए मानव दुभाषिये का उपयोग करें।';
  }

  @override
  String get aboutLicenses => 'ओपन-सोर्स लाइसेंस';

  @override
  String get legalTitlePrivacy => 'गोपनीयता नीति';

  @override
  String get legalTitleTerms => 'सेवा की शर्तें';

  @override
  String get legalEnglishOnly => 'कानूनी पाठ अंग्रेज़ी में उपलब्ध है।';

  @override
  String get openInBrowser => 'ऑनलाइन संस्करण खोलें';

  @override
  String get settingsNotifications => 'सूचनाएं';
}
