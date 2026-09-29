/// Route paths. Keep in one place so deep links and tests stay in sync.
class Routes {
  const Routes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const phone = '/phone';
  static const otp = '/otp';
  static const profileSetup = '/profile-setup';
  static const trialOffer = '/trial-offer';

  // Shell tabs
  static const home = '/home';
  static const translate = '/translate';
  static const learn = '/learn';
  static const live = '/live';
  static const profile = '/profile';

  // Translate
  static const signToText = '/translate/sign-to-text';
  static const signToVoice = '/translate/sign-to-voice';
  static const voiceToSign = '/translate/voice-to-sign';

  // Learn / practice / dictionary
  static String learnCategory(String id) => '/learn/category/$id';
  static const learnCategoryPattern = '/learn/category/:id';
  static String practice(String signId) => '/practice/$signId';
  static const practicePattern = '/practice/:id';
  static const practiceHub = '/practice';
  static const dictionary = '/dictionary';
  static String dictionaryEntry(String id) => '/dictionary/$id';
  static const dictionaryEntryPattern = '/dictionary/:id';
  static const progress = '/progress';

  // History
  static const history = '/history';

  // Interpreter
  static const interpreterFind = '/interpreter/find';
  static const interpreterCall = '/interpreter/call';
  static const interpreterFeedback = '/interpreter/feedback';

  // Subscription
  static const premium = '/premium';
  static const premiumBenefits = '/premium/benefits';
  static const manageSubscription = '/premium/manage';

  // Misc
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const settingsAccessibility = '/settings/accessibility';
  static const settingsVoice = '/settings/voice';
  static const settingsTranslation = '/settings/translation';
  static const settingsNotifications = '/settings/notifications';
  static const settingsPrivacy = '/settings/privacy';
  static const settingsLanguage = '/settings/language';
  static const help = '/help';
  static const about = '/about';
  static const legalPrivacy = '/legal/privacy';
  static const legalTerms = '/legal/terms';
  static const deleteAccount = '/settings/delete-account';
}
