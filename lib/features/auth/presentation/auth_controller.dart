import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers.dart';
import '../../../core/services/analytics_service.dart';
import '../data/firebase_auth_repository.dart';
import '../data/unconfigured_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(firebaseAvailableProvider) ? FirebaseAuthRepository() : UnconfiguredAuthRepository();
});

enum AuthStatus { unknown, unauthenticated, guest, authenticated }

class AuthState {
  const AuthState(this.status, [this.user]);
  final AuthStatus status;
  final AppUser? user;

  bool get isSignedIn => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;
  String get uid => user?.uid ?? 'guest';
}

class AuthController extends Notifier<AuthState> {
  StreamSubscription<AppUser?>? _sub;

  @override
  AuthState build() {
    final repo = ref.watch(authRepositoryProvider);
    final kv = ref.watch(keyValueStoreProvider);
    ref.onDispose(() => _sub?.cancel());

    _sub = repo.authStateChanges().listen((u) {
      if (u != null) {
        state = AuthState(AuthStatus.authenticated, u);
      } else if (kv.getBool(PrefKeys.guestMode) ?? false) {
        state = const AuthState(AuthStatus.guest, AppUser.guest);
      } else {
        state = const AuthState(AuthStatus.unauthenticated);
      }
    }, onError: (Object _) {
      state = const AuthState(AuthStatus.unauthenticated);
    });
    return const AuthState(AuthStatus.unknown);
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _afterSignIn(AppUser u) async {
    await ref.read(keyValueStoreProvider).remove(PrefKeys.guestMode);
    state = AuthState(AuthStatus.authenticated, u);
  }

  Future<void> signInWithEmail(String email, String password) async =>
      _afterSignIn(await _repo.signInWithEmail(email, password));

  Future<void> register(String email, String password, String name) async {
    final u = await _repo.registerWithEmail(email: email, password: password, name: name);
    await _afterSignIn(u);
  }

  Future<void> signInWithGoogle() async => _afterSignIn(await _repo.signInWithGoogle());

  Future<void> confirmOtp(String verificationId, String code) async =>
      _afterSignIn(await _repo.confirmOtp(verificationId: verificationId, code: code));

  Future<void> continueAsGuest() async {
    await ref.read(keyValueStoreProvider).setBool(PrefKeys.guestMode, true);
    state = const AuthState(AuthStatus.guest, AppUser.guest);
  }

  Future<void> signOut() async {
    await _repo.signOut();
    await ref.read(keyValueStoreProvider).remove(PrefKeys.guestMode);
    state = const AuthState(AuthStatus.unauthenticated);
  }

  /// Leaves guest mode so the person can create or sign in to an account.
  Future<void> leaveGuestMode() async {
    await ref.read(keyValueStoreProvider).remove(PrefKeys.guestMode);
    state = const AuthState(AuthStatus.unauthenticated);
  }

  void logAppOpen() => ref.read(analyticsServiceProvider).log(AnalyticsEvents.appOpen);
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Convenience for non-widget code: is a real (non-guest) account active?
final authControllerStateIsSignedIn = Provider<bool>((ref) => ref.watch(authControllerProvider).isSignedIn);
