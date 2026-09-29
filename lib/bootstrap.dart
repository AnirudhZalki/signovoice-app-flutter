import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';
import 'core/services/app_log.dart';
import 'core/services/storage.dart';

/// Starts the app. Firebase is optional at runtime: without
/// `google-services.json` the app runs in guest mode with account, sync and
/// purchase features clearly reported as unavailable (never faked).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    AppLog.d('bootstrap', 'Firebase not configured: ${e.runtimeType}');
  }

  if (firebaseReady && !kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } else {
    FlutterError.onError = (details) {
      if (kDebugMode) FlutterError.dumpErrorToConsole(details);
    };
  }

  runApp(ProviderScope(
    overrides: [
      keyValueStoreProvider.overrideWithValue(SharedPrefsStore(prefs)),
      firebaseAvailableProvider.overrideWithValue(firebaseReady),
    ],
    child: const SignoVoiceApp(),
  ));
}
