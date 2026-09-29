/// Build-time configuration. Values are injected with `--dart-define` or
/// `--dart-define-from-file=config/dev.json` and are never committed.
/// See docs/EXTERNAL_SETUP.md. Nothing here is a secret: server-side secrets
/// (Play API credentials, LiveKit API secret, AI keys) live on the backend.
class AppConfig {
  const AppConfig._();

  /// Base URL of the SignoVoice backend (HTTPS only), e.g. https://api.example.com
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// LiveKit WebSocket URL (wss://...). Tokens are minted by the backend.
  static const String livekitUrl = String.fromEnvironment('LIVEKIT_URL');

  /// Optional remote recognition endpoint (receives landmarks, never images).
  static const String remoteRecognitionUrl =
      String.fromEnvironment('REMOTE_RECOGNITION_URL');

  /// Google Sign-In web/server client id (from the Firebase console).
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const String monthlyProductId = String.fromEnvironment(
    'IAP_MONTHLY_ID',
    defaultValue: 'signovoice_premium_monthly',
  );
  static const String yearlyProductId = String.fromEnvironment(
    'IAP_YEARLY_ID',
    defaultValue: 'signovoice_premium_yearly',
  );

  static const String supportEmail = String.fromEnvironment('SUPPORT_EMAIL');
  static const String privacyPolicyUrl =
      String.fromEnvironment('PRIVACY_POLICY_URL');
  static const String termsUrl = String.fromEnvironment('TERMS_URL');

  static bool get hasBackend => apiBaseUrl.startsWith('https://');
  static bool get hasLiveKit => livekitUrl.startsWith('wss://');
  static bool get hasRemoteRecognition =>
      remoteRecognitionUrl.startsWith('https://');

  static Set<String> get subscriptionProductIds =>
      {monthlyProductId, yearlyProductId};
}
