import 'app_user.dart';

/// All authentication goes through this interface so the UI never touches
/// Firebase directly. Methods throw [Failure] (never raw exceptions).
abstract class AuthRepository {
  /// True when real accounts are available (Firebase configured).
  bool get supportsAccounts;

  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;

  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> registerWithEmail({required String email, required String password, required String name});
  Future<AppUser> signInWithGoogle();
  Future<void> sendPasswordReset(String email);

  Future<PhoneVerification> startPhoneVerification(String e164Phone, {int? resendToken});
  Future<AppUser> confirmOtp({required String verificationId, required String code});

  Future<void> updateProfile({String? displayName, String? photoUrl});
  Future<void> signOut();

  /// Permanently deletes the auth account. May throw
  /// `FailureType.requiresRecentLogin`.
  Future<void> deleteAccount();

  /// Fresh ID token for backend calls, or null.
  Future<String?> idToken();
}
