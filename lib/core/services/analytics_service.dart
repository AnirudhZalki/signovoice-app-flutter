import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Event names. Parameters must never carry personal data (no names, emails,
/// recognised sentences, or camera content).
class AnalyticsEvents {
  const AnalyticsEvents._();
  static const appOpen = 'app_open';
  static const signTranslationStarted = 'sign_translation_started';
  static const signTranslationCompleted = 'sign_translation_completed';
  static const voiceTranslationStarted = 'voice_translation_started';
  static const learningStarted = 'learning_started';
  static const practiceStarted = 'practice_started';
  static const practiceCompleted = 'practice_completed';
  static const interpreterRequest = 'interpreter_request';
  static const trialStarted = 'trial_started';
  static const subscriptionStarted = 'subscription_started';
  static const subscriptionCancelled = 'subscription_cancelled';
  static const subscriptionExpired = 'subscription_expired';
}

abstract class AnalyticsService {
  Future<void> log(String name, [Map<String, Object> params = const {}]);
  Future<void> setEnabled(bool enabled);
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService([FirebaseAnalytics? a]) : _a = a ?? FirebaseAnalytics.instance;
  final FirebaseAnalytics _a;
  bool _enabled = true;

  @override
  Future<void> log(String name, [Map<String, Object> params = const {}]) async {
    if (!_enabled) return;
    try {
      await _a.logEvent(name: name, parameters: params.isEmpty ? null : params);
    } catch (_) {/* analytics must never break the app */}
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    try {
      await _a.setAnalyticsCollectionEnabled(enabled);
    } catch (_) {}
    try {
      // Crash reports follow the same privacy switch.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    } catch (_) {}
  }
}

/// Used when Firebase is not configured, and in tests.
class NoopAnalyticsService implements AnalyticsService {
  final List<String> events = [];
  @override
  Future<void> log(String name, [Map<String, Object> params = const {}]) async {
    events.add(name);
    if (kDebugMode) debugPrint('[analytics] $name');
  }

  @override
  Future<void> setEnabled(bool enabled) async {}
}
