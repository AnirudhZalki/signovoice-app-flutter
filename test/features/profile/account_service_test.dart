import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/constants/app_constants.dart';
import 'package:signovoice/core/errors/failure.dart';
import 'package:signovoice/core/providers.dart';
import 'package:signovoice/core/services/storage.dart';
import 'package:signovoice/features/auth/domain/app_user.dart';
import 'package:signovoice/features/auth/domain/auth_repository.dart';
import 'package:signovoice/features/auth/presentation/auth_controller.dart';
import 'package:signovoice/features/history/domain/history_entry.dart';
import 'package:signovoice/features/history/presentation/history_controller.dart';
import 'package:signovoice/features/learning/presentation/learning_controller.dart';
import 'package:signovoice/features/notifications/domain/notification_models.dart';
import 'package:signovoice/features/notifications/domain/notification_service.dart';
import 'package:signovoice/features/notifications/presentation/notification_providers.dart';
import 'package:signovoice/features/profile/data/account_service.dart';
import 'package:signovoice/features/profile/domain/user_preferences.dart';
import 'package:signovoice/features/profile/domain/user_profile.dart';
import 'package:signovoice/features/profile/domain/user_repository.dart';
import 'package:signovoice/features/profile/presentation/preferences_controller.dart';
import 'package:signovoice/features/profile/presentation/profile_controller.dart';

// ---- test-only fakes ----
class _AuthRepo implements AuthRepository {
  _AuthRepo({this.deleteError});
  final Object? deleteError;
  final _c = StreamController<AppUser?>.broadcast();
  AppUser? _u = const AppUser(uid: 'u1', email: 'a@b.co');
  bool deleted = false;
  bool signedOut = false;
  @override
  bool get supportsAccounts => true;
  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _u;
    yield* _c.stream;
  }

  @override
  AppUser? get currentUser => _u;
  @override
  Future<AppUser> signInWithEmail(String email, String password) async => throw UnimplementedError();
  @override
  Future<AppUser> registerWithEmail({required String email, required String password, required String name}) async => throw UnimplementedError();
  @override
  Future<AppUser> signInWithGoogle() async => throw UnimplementedError();
  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<PhoneVerification> startPhoneVerification(String e164Phone, {int? resendToken}) async => throw UnimplementedError();
  @override
  Future<AppUser> confirmOtp({required String verificationId, required String code}) async => throw UnimplementedError();
  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {}
  @override
  Future<void> signOut() async {
    signedOut = true;
    _u = null;
    _c.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    if (deleteError != null) throw deleteError!;
    deleted = true;
  }

  @override
  Future<String?> idToken() async => 't';
}

class _UserRepo implements UserRepository {
  _UserRepo({this.requestError});
  final Object? requestError;
  final requests = <({String uid, bool deleteAccount})>[];
  @override
  Future<UserProfile?> load(String uid) async => UserProfile(uid: uid, displayName: 'Asha');
  @override
  Future<void> save(UserProfile profile) async {}
  @override
  Future<String> uploadAvatar(String uid, String localPath) async => '';
  @override
  Future<void> clearLocal(String uid) async {}
  @override
  Future<void> requestDataDeletion(String uid, {required bool deleteAccount}) async {
    if (requestError != null) throw requestError!;
    requests.add((uid: uid, deleteAccount: deleteAccount));
  }
}

class _Notif implements NotificationService {
  bool cancelled = false;
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> apply(List<PlannedNotification> plan) async {}
  @override
  Future<void> cancelAll() async => cancelled = true;
  @override
  Future<void> showNow({required int id, required NotificationKind kind, required String title, required String body}) async {}
}

class _Harness {
  _Harness({bool signedIn = true, Object? deleteError, Object? requestError}) {
    authRepo = _AuthRepo(deleteError: deleteError);
    if (!signedIn) authRepo._u = null;
    userRepo = _UserRepo(requestError: requestError);
    kv = InMemoryKeyValueStore();
    collections = InMemoryCollectionStore();
    secure = InMemorySecureStore();
    notif = _Notif();
    c = ProviderContainer(overrides: [
      keyValueStoreProvider.overrideWithValue(kv),
      collectionStoreProvider.overrideWithValue(collections),
      secureStoreProvider.overrideWithValue(secure),
      authRepositoryProvider.overrideWithValue(authRepo),
      userRepositoryProvider.overrideWithValue(userRepo),
      notificationServiceProvider.overrideWithValue(notif),
    ]);
    if (!signedIn) kv.setBool(PrefKeys.guestMode, true);
    kv.setBool(PrefKeys.onboardingDone, true);
    c.listen(authControllerProvider, (_, _) {});
  }
  late final _AuthRepo authRepo;
  late final _UserRepo userRepo;
  late final InMemoryKeyValueStore kv;
  late final InMemoryCollectionStore collections;
  late final InMemorySecureStore secure;
  late final _Notif notif;
  late final ProviderContainer c;

  Future<void> seed() async {
    await c.read(historyProvider.notifier).record(HistoryEntry(
        id: '1', inputType: HistoryInputType.signToText, glosses: const ['HELLO'], text: 'Hello', timestamp: DateTime(2026), languageCode: 'en', durationMs: 1));
    await c.read(learningProvider.notifier).markLearned('hello');
    await c.read(preferencesProvider.notifier).update((p) => p.copyWith(highContrast: true, localeCode: 'hi'));
    await secure.write('entitlement_u1', '{"status":"premium"}');
    await secure.write('profile_u1', '{"uid":"u1","displayName":"Asha"}');
    await Future<void>.delayed(const Duration(milliseconds: 20)); // let the auth stream deliver
  }
}

void main() {
  test('wipeLocalData clears history, progress, settings and caches but keeps onboarding', () async {
    final h = _Harness();
    addTearDown(h.c.dispose);
    await h.seed();
    expect((await h.c.read(historyProvider.future)).length, 1);
    expect(h.c.read(learningProvider).learned, {'hello'});

    await h.c.read(accountServiceProvider).wipeLocalData();

    expect(await h.c.read(historyProvider.future), isEmpty);
    expect(h.c.read(learningProvider).learned, isEmpty);
    expect(h.c.read(preferencesProvider), const UserPreferences());
    expect(await h.secure.read('entitlement_u1'), isNull);
    expect(await h.secure.read('profile_u1'), isNull);
    expect(h.kv.getBool(PrefKeys.onboardingDone), isTrue);
    expect(h.notif.cancelled, isTrue);
  });

  test('deleteAccount (signed in): server erasure request, auth deletion, then local wipe and sign-out', () async {
    final h = _Harness();
    addTearDown(h.c.dispose);
    await h.seed();
    await h.c.read(accountServiceProvider).deleteAccount();

    expect(h.userRepo.requests.single.deleteAccount, isTrue);
    expect(h.userRepo.requests.single.uid, 'u1');
    expect(h.authRepo.deleted, isTrue);
    expect(h.authRepo.signedOut, isTrue);
    expect(await h.c.read(historyProvider.future), isEmpty);
    expect(h.c.read(authControllerProvider).status, AuthStatus.unauthenticated);
  });

  test('requires-recent-login: nothing local is destroyed and the failure is reported', () async {
    final h = _Harness(deleteError: const Failure(FailureType.requiresRecentLogin));
    addTearDown(h.c.dispose);
    await h.seed();
    await expectLater(
      h.c.read(accountServiceProvider).deleteAccount(),
      throwsA(isA<Failure>().having((f) => f.type, 'type', FailureType.requiresRecentLogin)),
    );
    expect((await h.c.read(historyProvider.future)).length, 1);
    expect(await h.secure.read('profile_u1'), isNotNull);
    expect(h.c.read(authControllerProvider).status, AuthStatus.authenticated);
  });

  test('offline: erasure request fails first, so the auth account is NOT deleted', () async {
    final h = _Harness(requestError: const Failure(FailureType.offline));
    addTearDown(h.c.dispose);
    await h.seed();
    await expectLater(h.c.read(accountServiceProvider).deleteAccount(), throwsA(isA<Failure>()));
    expect(h.authRepo.deleted, isFalse);
    expect((await h.c.read(historyProvider.future)).length, 1);
  });

  test('deleteAccount as guest only clears the device and leaves guest mode', () async {
    final h = _Harness(signedIn: false);
    addTearDown(h.c.dispose);
    await h.seed();
    await h.c.read(accountServiceProvider).deleteAccount();
    expect(h.userRepo.requests, isEmpty);
    expect(h.authRepo.deleted, isFalse);
    expect(await h.c.read(historyProvider.future), isEmpty);
    expect(h.kv.getBool(PrefKeys.guestMode), isNull);
    expect(h.c.read(authControllerProvider).status, AuthStatus.unauthenticated);
  });

  test('signOut can also clear device data (shared devices)', () async {
    final h = _Harness();
    addTearDown(h.c.dispose);
    await h.seed();
    await h.c.read(accountServiceProvider).signOut(clearLocalData: true);
    expect(h.authRepo.signedOut, isTrue);
    expect(await h.c.read(historyProvider.future), isEmpty);

    final h2 = _Harness();
    addTearDown(h2.c.dispose);
    await h2.seed();
    await h2.c.read(accountServiceProvider).signOut();
    expect((await h2.c.read(historyProvider.future)).length, 1);
  });

  test('server data deletion request without account deletion', () async {
    final h = _Harness();
    addTearDown(h.c.dispose);
    await h.seed();
    await h.c.read(accountServiceProvider).requestServerDataDeletion();
    expect(h.userRepo.requests.single.deleteAccount, isFalse);
    expect(h.authRepo.deleted, isFalse);
  });
}
