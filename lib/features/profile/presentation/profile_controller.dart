import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/user_repository_impl.dart';
import '../domain/user_profile.dart';
import '../domain/user_repository.dart';
import 'preferences_controller.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepositoryImpl(
      secure: ref.watch(secureStoreProvider),
      firebaseAvailable: ref.watch(firebaseAvailableProvider),
    ));

/// The signed-in (or guest) person's profile. `null` = profile setup pending.
class ProfileController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    if (user == null) return null;
    return ref.read(userRepositoryProvider).load(user.uid);
  }

  AppUser get _user => ref.read(authControllerProvider).user ?? AppUser.guest;

  /// Saves the profile and applies the chosen language/mode/accessibility.
  Future<void> save(UserProfile p, {bool applyPreferences = true}) async {
    await ref.read(userRepositoryProvider).save(p);
    state = AsyncData(p);
    if (applyPreferences) {
      await ref.read(preferencesProvider.notifier).update((prefs) => prefs.copyWith(
            localeCode: p.preferredLanguage,
            preferredMode: p.preferredMode,
            accessibilityNeeds: p.accessibilityNeeds,
          ));
    }
  }

  /// Creates a minimal profile when the person skips setup.
  Future<void> skipSetup() {
    final u = _user;
    return save(UserProfile(uid: u.uid, displayName: u.displayName ?? '', photoUrl: u.photoUrl, createdAt: DateTime.now()),
        applyPreferences: false);
  }
}

final profileProvider = AsyncNotifierProvider<ProfileController, UserProfile?>(ProfileController.new);
