import 'dart:async';

import '../../../core/errors/failure.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Used when Firebase isn't configured in this build. Accounts are simply
/// unavailable (every account call reports `notConfigured`); the app still
/// works in guest mode. This is not a fake sign-in.
class UnconfiguredAuthRepository implements AuthRepository {
  @override
  bool get supportsAccounts => false;

  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(null);

  @override
  AppUser? get currentUser => null;

  Never _unavailable() => throw const Failure(FailureType.notConfigured, debugDetail: 'firebase not configured');

  @override
  Future<AppUser> signInWithEmail(String email, String password) async => _unavailable();
  @override
  Future<AppUser> registerWithEmail({required String email, required String password, required String name}) async =>
      _unavailable();
  @override
  Future<AppUser> signInWithGoogle() async => _unavailable();
  @override
  Future<void> sendPasswordReset(String email) async => _unavailable();
  @override
  Future<PhoneVerification> startPhoneVerification(String e164Phone, {int? resendToken}) async => _unavailable();
  @override
  Future<AppUser> confirmOtp({required String verificationId, required String code}) async => _unavailable();
  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<String?> idToken() async => null;
}
