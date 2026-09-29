import 'package:flutter/foundation.dart';

/// Debug-only logging. Never pass personal data, tokens or recognised text.
class AppLog {
  const AppLog._();
  static void d(String tag, String message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }
}
