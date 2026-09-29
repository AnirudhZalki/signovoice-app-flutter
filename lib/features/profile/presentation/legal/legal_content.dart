/// In-app legal text (English). This is the product's plain-language policy;
/// it must be reviewed by counsel and published at PRIVACY_POLICY_URL /
/// TERMS_URL for Play Console before release (see docs/EXTERNAL_SETUP.md).
class LegalSection {
  const LegalSection(this.heading, this.body);
  final String heading;
  final String body;
}

class LegalContent {
  const LegalContent._();

  static const lastUpdated = '29 September 2026';

  static const privacyPolicy = <LegalSection>[
    LegalSection('Who we are', 'SignoVoice ("we", "us") is an accessibility app that helps people who use sign language and people who do not know sign language communicate. You can reach us from Help & support in the app.'),
    LegalSection('Data we process', '''• Camera: used only while a translation or practice screen is open. Video frames are analysed on your device to find hand positions (21 points per hand). Video is never recorded, stored or uploaded. If you choose the optional online recognition mode, only those hand-position numbers are sent to our server, not images.
• Microphone: used only when you tap the microphone button or join an interpreter call. Speech-to-text is performed by your device's speech service, which may send audio to its provider depending on your device and language.
• Account: if you create an account, we store your name, email address or phone number, sign-in method and optional profile photo using Google Firebase (Authentication, Firestore, Storage).
• Preferences: language, accessibility and notification settings are stored on your device and, for profile fields, in your account.
• History and learning progress: stored only on your device unless you tell us otherwise. You can clear them at any time.
• Subscriptions: payments are processed by Google Play. We receive a purchase token and product identifier so our server can verify your plan. We never see your card details.
• Interpreter sessions: audio, video and chat are transmitted in real time through our call provider (LiveKit) to your interpreter. The app does not record calls. We keep call metadata (time, duration, interpreter, your rating and any issue you report).
• Notifications: a device token (Firebase Cloud Messaging) if you allow push notifications.
• Usage and crash data: anonymous events (for example "practice started") and crash reports through Firebase Analytics and Crashlytics, only if you leave this enabled in Privacy settings. These never contain video, recognised signs or translated text.'''),
    LegalSection('How we use data', 'To provide sign recognition, translation, learning, interpreter connections and subscriptions; to verify purchases; to keep the app secure and reliable; to send reminders you have enabled; and to respond to support requests.'),
    LegalSection('Sharing', 'We share data only with service providers that operate parts of SignoVoice on our behalf (Google Firebase, Google Play, our call provider and hosting provider) and, during a call, with the interpreter you are connected to. We do not sell personal data and we do not show advertising.'),
    LegalSection('Retention', 'Data on your device stays until you delete it or uninstall the app. Account data is kept until you delete your account. Call metadata and support records are kept only as long as needed to run the service, resolve disputes and meet legal obligations.'),
    LegalSection('Your choices and rights', 'You can turn off analytics, stop saving history, clear history and progress, ask us to erase your server-side data, or delete your account in Settings › Privacy & data. Deleting your account removes your account and associated data and clears data on your device. It does not cancel a Google Play subscription; cancel that in Google Play. You may also contact us to access or correct your data.'),
    LegalSection('Children', 'SignoVoice is not directed to children under 13. If you are under the age of consent in your country, use the app with a parent or guardian.'),
    LegalSection('Security', 'Connections use HTTPS. Sensitive items such as sign-in state and subscription cache are kept in your device\'s encrypted storage. No secret keys are stored in the app.'),
    LegalSection('International transfers', 'Our providers may process data in countries other than your own, under their own safeguards.'),
    LegalSection('Changes', 'If we change this policy in a meaningful way we will tell you in the app before it takes effect.'),
  ];

  static const terms = <LegalSection>[
    LegalSection('Acceptance', 'By creating an account or using SignoVoice you agree to these Terms and to our Privacy Policy. If you do not agree, do not use the app.'),
    LegalSection('What SignoVoice is — and is not', 'SignoVoice offers AI-assisted sign recognition, voice-to-sign lookup, learning tools and connections to human interpreters. AI recognition is an aid: it knows a limited set of signs, can make mistakes and is not a certified interpreter. Do not rely on it alone for medical, legal, emergency or other high-stakes communication; use a qualified human interpreter.'),
    LegalSection('Accounts', 'Keep your sign-in details secure. You are responsible for activity on your account. You may use the app without an account in guest mode with fewer features.'),
    LegalSection('Acceptable use', 'Do not misuse the app, attempt to disrupt or reverse-engineer the service, harass interpreters or other users, or use the service unlawfully.'),
    LegalSection('Interpreters', 'Interpreters are independent professionals. Availability is not guaranteed. Calls are for communication assistance only.'),
    LegalSection('Subscriptions and free trial', 'Premium is an auto-renewing subscription sold through Google Play. New accounts may be eligible for a one-month free trial; eligibility is decided by Google Play. When the trial ends the subscription renews automatically at the price shown in Google Play unless you cancel before the trial ends. You can cancel at any time in Google Play › Payments & subscriptions › Subscriptions. Refunds follow Google Play\'s policies. Premium access is granted only after our server verifies your purchase.'),
    LegalSection('Intellectual property', 'SignoVoice and its content are owned by us or our licensors. You receive a personal, non-transferable licence to use the app. Sign videos and learning content may not be copied or redistributed.'),
    LegalSection('Availability and warranty', 'The service is provided "as is" without warranties. We may change or discontinue features. Some features need an internet connection.'),
    LegalSection('Liability', 'To the extent permitted by law, we are not liable for indirect or consequential losses, or for losses arising from reliance on AI recognition or interpreter services.'),
    LegalSection('Ending your account', 'You can delete your account at any time in Settings › Privacy & data. We may suspend accounts that breach these Terms.'),
    LegalSection('Governing law', 'These Terms are governed by the laws of India, and the courts of India have jurisdiction, unless mandatory local law says otherwise.'),
  ];
}
