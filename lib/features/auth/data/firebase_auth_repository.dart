import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository([fb.FirebaseAuth? auth]) : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;
  Future<void>? _googleInit;

  @override
  bool get supportsAccounts => true;

  AppUser _map(fb.User u, {bool isNew = false}) => AppUser(
        uid: u.uid,
        email: u.email,
        displayName: u.displayName,
        photoUrl: u.photoURL,
        phone: u.phoneNumber,
        emailVerified: u.emailVerified,
        isNewUser: isNew,
      );

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.userChanges().map((u) => u == null ? null : _map(u));

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    return u == null ? null : _map(u);
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } catch (e) {
      throw toFailure(e);
    }
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) => _guard(() async {
        final c = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
        return _map(c.user!);
      });

  @override
  Future<AppUser> registerWithEmail(
          {required String email, required String password, required String name}) =>
      _guard(() async {
        final c = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
        await c.user!.updateDisplayName(name.trim());
        await c.user!.reload();
        return _map(_auth.currentUser!, isNew: true);
      });

  @override
  Future<AppUser> signInWithGoogle() => _guard(() async {
        _googleInit ??= GoogleSignIn.instance.initialize(
          serverClientId: AppConfig.googleServerClientId.isEmpty ? null : AppConfig.googleServerClientId,
        );
        await _googleInit;
        if (!GoogleSignIn.instance.supportsAuthenticate()) {
          throw const Failure(FailureType.notConfigured, debugDetail: 'google authenticate unsupported');
        }
        final GoogleSignInAccount account;
        try {
          account = await GoogleSignIn.instance.authenticate();
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled) {
            throw const Failure(FailureType.cancelled, code: 'google-cancelled');
          }
          // Typical causes: SHA-1/SHA-256 not added to the Firebase Android app, Google provider not enabled, or an
          // outdated google-services.json (re-download it after changing either). See docs/FIREBASE_SETUP.md.
          throw Failure(FailureType.unknown, debugDetail: 'google ${e.code.name}: ${e.description ?? ''}');
        }
        final idToken = account.authentication.idToken;
        if (idToken == null) throw const Failure(FailureType.unknown, debugDetail: 'no google idToken');
        final c = await _auth.signInWithCredential(fb.GoogleAuthProvider.credential(idToken: idToken));
        return _map(c.user!, isNew: c.additionalUserInfo?.isNewUser ?? false);
      });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<PhoneVerification> startPhoneVerification(String e164Phone, {int? resendToken}) {
    final completer = Completer<PhoneVerification>();
    _auth
        .verifyPhoneNumber(
          phoneNumber: e164Phone,
          forceResendingToken: resendToken,
          verificationCompleted: (cred) async {
            try {
              await _auth.signInWithCredential(cred);
              if (!completer.isCompleted) {
                completer.complete(const PhoneVerification(autoSignedIn: true));
              }
            } catch (e) {
              if (!completer.isCompleted) completer.completeError(toFailure(e));
            }
          },
          verificationFailed: (e) {
            if (!completer.isCompleted) completer.completeError(toFailure(e));
          },
          codeSent: (id, token) {
            if (!completer.isCompleted) {
              completer.complete(PhoneVerification(verificationId: id, resendToken: token));
            }
          },
          codeAutoRetrievalTimeout: (_) {},
        )
        .catchError((Object e) {
      if (!completer.isCompleted) completer.completeError(toFailure(e));
    });
    return completer.future;
  }

  @override
  Future<AppUser> confirmOtp({required String verificationId, required String code}) => _guard(() async {
        final cred = fb.PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code.trim());
        final c = await _auth.signInWithCredential(cred);
        return _map(c.user!, isNew: c.additionalUserInfo?.isNewUser ?? false);
      });

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) => _guard(() async {
        final u = _auth.currentUser;
        if (u == null) throw const Failure(FailureType.unauthorized);
        if (displayName != null) await u.updateDisplayName(displayName);
        if (photoUrl != null) await u.updatePhotoURL(photoUrl);
        await u.reload();
      });

  @override
  Future<void> signOut() => _guard(() async {
        try {
          if (_googleInit != null) await GoogleSignIn.instance.signOut();
        } catch (_) {}
        await _auth.signOut();
      });

  @override
  Future<void> deleteAccount() => _guard(() async {
        final u = _auth.currentUser;
        if (u == null) throw const Failure(FailureType.unauthorized);
        await u.delete();
      });

  @override
  Future<String?> idToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (_) {
      return null;
    }
  }
}
