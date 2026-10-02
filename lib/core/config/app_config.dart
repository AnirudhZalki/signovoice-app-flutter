import 'package:flutter/foundation.dart' show kDebugMode;

/// Build-time configuration. Values are injected with `--dart-define` or
/// `--dart-define-from-file=config/dev.json` and are never committed.
/// See docs/EXTERNAL_SETUP.md. Nothing here is a secret: server-side secrets
/// (Play API credentials, LiveKit API secret, AI keys) live on the backend.
class AppConfig {
  const AppConfig._();

  /// Base URL of the SignoVoice backend (HTTPS only), e.g. https://api.example.com
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// LiveKit WebSocket URL (wss://...). Tokens are minted by the backend.
  static const String livekitUrl =
      String.fromEnvironment('LIVEKIT_URL', defaultValue: 'wss://signovoice-kki1ealv.livekit.cloud');

  /// Standalone LiveKit token server (e.g. the Render service). The app asks it for a token for a room
  /// code and joins directly. See docs/LIVEKIT_SETUP.md for the request/response shape it accepts.
  static const String livekitTokenUrl = String.fromEnvironment(
    'LIVEKIT_TOKEN_URL',
    defaultValue: 'https://signovoice-livekkit-server.onrender.com/token',
  );

  /// DEBUG BUILDS ONLY: a short-lived LiveKit token (from the LiveKit Cloud dashboard) that lets a
  /// developer join a test room without the backend. Ignored in release builds. Never commit it.
  static const String livekitDevToken = String.fromEnvironment('LIVEKIT_DEV_TOKEN');

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

  /// Enables the Razorpay (UPI AutoPay / cards) payment method next to Google Play Billing.
  /// IMPORTANT: for apps distributed through Google Play, digital subscriptions must use Play Billing
  /// (unless you are enrolled in an alternative-billing programme). Enable this for direct-APK /
  /// website distribution builds. See docs/PAYMENTS_SETUP.md.
  static const bool enableRazorpay = bool.fromEnvironment('ENABLE_RAZORPAY');

  /// Default method when Razorpay is enabled: `googlePlay` or `razorpay`.
  static const String defaultPaymentMethod = String.fromEnvironment('PAYMENT_METHOD', defaultValue: 'googlePlay');

  static const String supportEmail = String.fromEnvironment('SUPPORT_EMAIL');
  static const String privacyPolicyUrl =
      String.fromEnvironment('PRIVACY_POLICY_URL');
  static const String termsUrl = String.fromEnvironment('TERMS_URL');

  static bool get hasBackend => apiBaseUrl.startsWith('https://');
  static bool get hasLiveKit => livekitUrl.startsWith('wss://');
  static bool get hasTokenServer => hasLiveKit && livekitTokenUrl.startsWith('https://');
  static bool get hasDevRoom => kDebugMode && hasLiveKit && livekitDevToken.isNotEmpty;
  static bool get hasRemoteRecognition =>
      remoteRecognitionUrl.startsWith('https://');

  static Set<String> get subscriptionProductIds =>
      {monthlyProductId, yearlyProductId};
}
