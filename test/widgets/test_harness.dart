import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/app.dart';
import 'package:signovoice/core/constants/app_constants.dart';
import 'package:signovoice/core/providers.dart';
import 'package:signovoice/core/services/analytics_service.dart';
import 'package:signovoice/core/services/permission_service.dart';
import 'package:signovoice/core/services/storage.dart';
import 'package:signovoice/core/services/tts_service.dart';
import 'package:signovoice/features/subscription/domain/billing_service.dart';
import 'package:signovoice/features/subscription/domain/subscription.dart';
import 'package:signovoice/features/subscription/presentation/purchase_flow_controller.dart';
import 'package:signovoice/features/dictionary/domain/sign_dictionary.dart';
import 'package:signovoice/features/dictionary/presentation/dictionary_providers.dart';
import 'package:signovoice/features/notifications/domain/notification_models.dart';
import 'package:signovoice/features/notifications/domain/notification_service.dart';
import 'package:signovoice/features/notifications/presentation/notification_providers.dart';
import 'package:signovoice/features/profile/domain/user_preferences.dart';
import 'dart:convert';

/// Test-only TTS (the real one needs the platform engine).
class FakeTts implements TtsService {
  @override
  Stream<TtsState> get stateStream => const Stream.empty();
  @override
  Future<void> speak(String text, {String? language, double? rate, TtsVoice? voice}) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<List<TtsVoice>> voices() async => const [TtsVoice(name: 'en-in-x-test', locale: 'en-IN')];
  @override
  Future<bool> isLanguageAvailable(String language) async => true;
  @override
  Future<void> dispose() async {}
}

/// Test-only billing: reports the store as unavailable (no Play services in tests).
class FakeBilling implements BillingService {
  @override
  StorePlatform get platform => StorePlatform.android;
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<List<StoreProduct>> loadProducts(Set<String> ids) async => const [];
  @override
  Future<bool> buy(StoreProduct product, {String? accountId}) async => false;
  @override
  Future<void> restore({String? accountId}) async {}
  @override
  Stream<StorePurchase> get purchases => const Stream.empty();
  @override
  Future<void> complete(StorePurchase purchase) async {}
  @override
  Future<void> dispose() async {}
}

/// Test-only permission service (the real one needs platform channels).
class FakePermissionService implements PermissionService {
  @override
  Future<PermissionState> status(AppPermission p) async => PermissionState.granted;
  @override
  Future<PermissionState> request(AppPermission p) async => PermissionState.granted;
  @override
  Future<void> openSettings() async {}
}

/// Test-only no-op notification service (the real one needs the Android plugin).
class FakeNotificationService implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> apply(List<PlannedNotification> plan) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> showNow({required int id, required NotificationKind kind, required String title, required String body}) async {}
}

class Harness {
  Harness({bool onboarded = true, bool guest = true, bool profileDone = true, UserPreferences? prefs}) {
    kv = InMemoryKeyValueStore();
    if (onboarded) kv.setBool(PrefKeys.onboardingDone, true);
    if (guest) kv.setBool(PrefKeys.guestMode, true);
    if (prefs != null) kv.setString(PrefKeys.preferences, jsonEncode(prefs.toJson()));
    if (profileDone) {
      secure.write('profile_guest', jsonEncode({'uid': 'guest', 'displayName': 'Asha', 'preferredLanguage': 'en', 'preferredMode': 'signToText', 'accessibilityNeeds': <String>[]}));
    }
  }
  late final InMemoryKeyValueStore kv;
  final secure = InMemorySecureStore();
  final collections = InMemoryCollectionStore();

  List<Override> get overrides => [
        keyValueStoreProvider.overrideWithValue(kv),
        secureStoreProvider.overrideWithValue(secure),
        collectionStoreProvider.overrideWithValue(collections),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        analyticsServiceProvider.overrideWithValue(NoopAnalyticsService()),
        notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        permissionServiceProvider.overrideWithValue(FakePermissionService()),
        ttsServiceProvider.overrideWithValue(FakeTts()),
        billingServiceProvider.overrideWithValue(FakeBilling()),
        // Read the bundled dictionary straight from disk: rootBundle caches a Future created inside
        // a finished fake-async zone, which would hang in later tests of the same process.
        dictionaryProvider.overrideWith((ref) => SignDictionary.fromJson(
            jsonDecode(File('assets/data/sign_dictionary.json').readAsStringSync()) as Map<String, dynamic>)),
      ];

  Future<void> pump(WidgetTester tester, {Size size = const Size(412, 892)}) async {
    tester.view.physicalSize = size * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const SignoVoiceApp()));
    await settle(tester);
  }
}

/// Pumps until animations/async work settle, without hanging on endless animations.
Future<void> settle(WidgetTester tester, {int frames = 30}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}


/// Waits (with real async gaps, so asset/JSON loading can complete) until [finder] matches.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 8)}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data ?? '').where((t) => t.isNotEmpty).take(40).toList();
      throw TestFailure('Timed out waiting for $finder. Visible texts: $texts');
    }
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Scrolls the nearest scrollable until [finder] is built and visible.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await pumpUntilFound(tester, find.byType(Scrollable));
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 100));
}
