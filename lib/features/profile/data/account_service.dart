import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../history/presentation/history_controller.dart';
import '../../learning/presentation/learning_controller.dart';
import '../../notifications/presentation/notification_providers.dart';
import '../../subscription/presentation/subscription_providers.dart';
import '../presentation/preferences_controller.dart';
import '../presentation/profile_controller.dart';

/// Privacy-critical operations: clearing data, signing out, erasing the account.
class AccountService {
  AccountService(this._ref);
  final Ref _ref;

  Future<void> clearHistory() => _ref.read(historyProvider.notifier).clear();
  Future<void> resetLearning() => _ref.read(learningProvider.notifier).reset();
  Future<void> clearNotifications() => _ref.read(inboxProvider.notifier).clear();

  /// Removes everything SignoVoice stored on this device (history, progress,
  /// settings, cached profile/entitlement, inbox, scheduled reminders).
  /// The "onboarding seen" flag is kept so people aren't walked through it again.
  Future<void> wipeLocalData() async {
    final kv = _ref.read(keyValueStoreProvider);
    final onboarded = kv.getBool(PrefKeys.onboardingDone) ?? false;

    await _ref.read(collectionStoreProvider).deleteAll();
    await _ref.read(secureStoreProvider).deleteAll();
    await kv.clear();
    if (onboarded) await kv.setBool(PrefKeys.onboardingDone, true);
    try {
      await _ref.read(notificationServiceProvider).cancelAll();
    } catch (_) {}

    // Rebuild in-memory state from the now-empty stores.
    _ref
      ..invalidate(historyProvider)
      ..invalidate(learningProvider)
      ..invalidate(practiceSessionsProvider)
      ..invalidate(preferencesProvider)
      ..invalidate(inboxProvider)
      ..invalidate(profileProvider)
      ..invalidate(subscriptionProvider);
  }

  /// Asks the backend to erase server-side data without deleting the account.
  Future<void> requestServerDataDeletion() async {
    final auth = _ref.read(authControllerProvider);
    if (!auth.isSignedIn) return;
    await _ref.read(userRepositoryProvider).requestDataDeletion(auth.uid, deleteAccount: false);
  }

  /// Signs out. Optionally also wipes device data (shared-device privacy).
  Future<void> signOut({bool clearLocalData = false}) async {
    await _ref.read(authControllerProvider.notifier).signOut();
    if (clearLocalData) await wipeLocalData();
  }

  /// Deletes the account and all data.
  ///
  /// Order matters: (1) record the server-side erasure request, (2) delete the
  /// auth account, (3) only then wipe the device. If (1) or (2) fails (offline,
  /// "recent login required"), nothing local is destroyed and the person can retry.
  Future<void> deleteAccount() async {
    final auth = _ref.read(authControllerProvider);
    try {
      if (auth.isSignedIn) {
        await _ref.read(userRepositoryProvider).requestDataDeletion(auth.uid, deleteAccount: true);
        await _ref.read(authRepositoryProvider).deleteAccount();
      }
    } catch (e) {
      throw toFailure(e);
    }
    await wipeLocalData();
    if (auth.isSignedIn) {
      await _ref.read(authControllerProvider.notifier).signOut();
    } else {
      await _ref.read(authControllerProvider.notifier).leaveGuestMode();
    }
  }
}

final accountServiceProvider = Provider<AccountService>((ref) => AccountService(ref));

/// Convenience used by UI to know whether an error means "sign in again".
bool needsRecentLogin(Object e) => toFailure(e).type == FailureType.requiresRecentLogin;
