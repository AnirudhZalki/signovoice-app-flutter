import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/subscription_repository_impl.dart';
import '../domain/entitlement.dart';
import '../domain/subscription.dart';
import '../domain/subscription_repository.dart';
import '../domain/trial_policy.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) => SubscriptionRepositoryImpl(
      api: ref.watch(apiClientProvider),
      secure: ref.watch(secureStoreProvider),
    ));

/// Verified subscription record for the current account.
///
/// Loads the cache immediately (offline-friendly), then refreshes from the
/// backend. Guests and signed-out users are always free.
class SubscriptionController extends AsyncNotifier<Subscription> {
  @override
  Future<Subscription> build() async {
    final auth = ref.watch(authControllerProvider);
    if (!auth.isSignedIn) return Subscription.free;
    final repo = ref.read(subscriptionRepositoryProvider);
    final cached = await repo.cached(auth.uid);
    // Refresh in the background; failures keep the cached value.
    unawaited(_refreshQuietly());
    return cached;
  }

  Future<void> _refreshQuietly() async {
    try {
      await refresh();
    } catch (_) {/* offline / backend not configured: keep cache */}
  }

  /// Fetches the verified entitlement. Throws [Failure] so callers can show
  /// retry / offline UI.
  Future<Subscription> refresh() async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isSignedIn) return Subscription.free;
    final repo = ref.read(subscriptionRepositoryProvider);
    try {
      final s = await repo.fetch(auth.uid);
      await repo.writeCache(auth.uid, s);
      _emitTransitions(state.value, s);
      state = AsyncData(s);
      return s;
    } catch (e) {
      throw toFailure(e);
    }
  }

  /// Applies a backend-verified entitlement (after purchase verification or restore).
  Future<void> applyVerified(Subscription s) async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isSignedIn) return;
    await ref.read(subscriptionRepositoryProvider).writeCache(auth.uid, s);
    _emitTransitions(state.value, s);
    state = AsyncData(s);
  }

  /// Logs analytics for status changes (no personal or purchase data).
  void _emitTransitions(Subscription? before, Subscription after) {
    final now = ref.read(clockProvider)();
    final was = before == null ? SubscriptionStatus.free : TrialPolicy.effectiveStatus(before, now);
    final is_ = TrialPolicy.effectiveStatus(after, now);
    if (was == is_) return;
    final a = ref.read(analyticsServiceProvider);
    switch (is_) {
      case SubscriptionStatus.trial:
        a.log(AnalyticsEvents.trialStarted);
      case SubscriptionStatus.premium:
        a.log(AnalyticsEvents.subscriptionStarted);
      case SubscriptionStatus.cancelled:
        a.log(AnalyticsEvents.subscriptionCancelled);
      case SubscriptionStatus.expired:
        a.log(AnalyticsEvents.subscriptionExpired);
      case SubscriptionStatus.free:
        break;
    }
  }

  Future<void> clearLocal() async {
    final auth = ref.read(authControllerProvider);
    await ref.read(subscriptionRepositoryProvider).clearCache(auth.uid);
    state = const AsyncData(Subscription.free);
  }
}

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionController, Subscription>(SubscriptionController.new);

/// Emits every minute so time-based entitlement (trial end) re-evaluates while the app is open.
final minuteTickProvider = StreamProvider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  return Stream<DateTime>.periodic(const Duration(minutes: 1), (_) => clock());
});

/// What the person may do right now, derived from the verified record + time.
final entitlementProvider = Provider<Entitlement>((ref) {
  final clock = ref.watch(clockProvider);
  ref.watch(minuteTickProvider);
  final sub = ref.watch(subscriptionProvider).value ?? Subscription.free;
  return Entitlement.at(sub, clock());
});

/// Convenience for gating.
final isPremiumProvider = Provider<bool>((ref) => ref.watch(entitlementProvider).isPremium);

/// True when the failure means "no backend": the UI explains rather than retries.
bool isNotConfigured(Object e) => toFailure(e).type == FailureType.notConfigured;
