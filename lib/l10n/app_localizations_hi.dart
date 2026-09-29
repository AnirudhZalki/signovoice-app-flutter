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
}
