import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/features/subscription/domain/entitlement.dart';
import 'package:signovoice/features/subscription/domain/subscription.dart';
import 'package:signovoice/features/subscription/domain/trial_policy.dart';

void main() {
  final t0 = DateTime(2026, 3, 10, 12);

  group('trial calculations', () {
    test('adds one calendar month', () => expect(TrialPolicy.trialEndFrom(t0), DateTime(2026, 4, 10, 12)));
    test('clamps month end (Jan 31 -> Feb 28)', () {
      expect(TrialPolicy.addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
      expect(TrialPolicy.addMonths(DateTime(2028, 1, 31), 1), DateTime(2028, 2, 29));
    });
    test('rolls over the year', () => expect(TrialPolicy.addMonths(DateTime(2026, 12, 15), 1), DateTime(2027, 1, 15)));
  });

  group('new user', () {
    test('is free, trial-eligible, no premium', () {
      const s = Subscription.free;
      expect(TrialPolicy.isTrialEligible(s), isTrue);
      expect(TrialPolicy.hasPremiumAccess(s, t0), isFalse);
      expect(Entitlement.at(s, t0).dailySignLimit, 100);
    });
  });

  group('trial user', () {
    final s = Subscription(
      status: SubscriptionStatus.trial,
      trialStartDate: t0,
      trialEndDate: TrialPolicy.trialEndFrom(t0),
      autoRenewing: true,
      productId: 'signovoice_premium_monthly',
    );
    test('has access and counts days', () {
      final now = t0.add(const Duration(days: 10));
      expect(TrialPolicy.effectiveStatus(s, now), SubscriptionStatus.trial);
      expect(TrialPolicy.hasPremiumAccess(s, now), isTrue);
      expect(TrialPolicy.trialDaysLeft(s, now), 21);
      expect(Entitlement.at(s, now).dailySignLimit, -1);
      expect(TrialPolicy.isTrialEligible(s), isFalse);
    });
    test('reminder window is the last 3 days', () {
      expect(TrialPolicy.shouldRemindTrialEnding(s, t0.add(const Duration(days: 10))), isFalse);
      expect(TrialPolicy.shouldRemindTrialEnding(s, t0.add(const Duration(days: 28))), isTrue);
    });
    test('trial that ended without a paid period expires (stale status cannot unlock)', () {
      final now = t0.add(const Duration(days: 40));
      expect(TrialPolicy.effectiveStatus(s, now), SubscriptionStatus.expired);
      expect(TrialPolicy.hasPremiumAccess(s, now), isFalse);
    });
    test('trial converting to paid renewal becomes premium', () {
      final converted = s.copyWith(subscriptionStartDate: s.trialEndDate, subscriptionEndDate: DateTime(2026, 5, 10, 12));
      final now = DateTime(2026, 4, 20);
      expect(TrialPolicy.effectiveStatus(converted, now), SubscriptionStatus.premium);
    });
  });

  group('premium user', () {
    final s = Subscription(
      status: SubscriptionStatus.premium,
      subscriptionStartDate: t0,
      subscriptionEndDate: DateTime(2026, 4, 10, 12),
      autoRenewing: true,
    );
    test('active until end date', () {
      expect(TrialPolicy.hasPremiumAccess(s, DateTime(2026, 4, 1)), isTrue);
      expect(TrialPolicy.accessEndDate(s, DateTime(2026, 4, 1)), DateTime(2026, 4, 10, 12));
    });
    test('expires after end date', () {
      expect(TrialPolicy.effectiveStatus(s, DateTime(2026, 4, 11)), SubscriptionStatus.expired);
      expect(TrialPolicy.hasPremiumAccess(s, DateTime(2026, 4, 11)), isFalse);
    });
  });

  group('cancelled subscription', () {
    final s = Subscription(status: SubscriptionStatus.cancelled, subscriptionEndDate: DateTime(2026, 4, 10, 12));
    test('keeps access until period end, then expires', () {
      expect(TrialPolicy.hasPremiumAccess(s, DateTime(2026, 4, 1)), isTrue);
      expect(TrialPolicy.effectiveStatus(s, DateTime(2026, 4, 1)), SubscriptionStatus.cancelled);
      expect(TrialPolicy.hasPremiumAccess(s, DateTime(2026, 4, 12)), isFalse);
    });
  });

  test('expired user is not trial-eligible again after having trialled', () {
    final s = Subscription(status: SubscriptionStatus.expired, trialStartDate: t0);
    expect(TrialPolicy.isTrialEligible(s), isFalse);
    expect(Entitlement.at(s, t0).isPremium, isFalse);
  });

  test('json round trip preserves every field', () {
    final s = Subscription(
      status: SubscriptionStatus.trial,
      trialStartDate: t0,
      trialEndDate: DateTime(2026, 4, 10, 12),
      productId: 'signovoice_premium_yearly',
      platform: StorePlatform.android,
      autoRenewing: true,
      purchaseToken: 'tok',
      verifiedAt: t0,
    );
    expect(Subscription.fromJson(s.toJson()), s);
  });

  test('unknown status string degrades to free', () {
    expect(Subscription.fromJson({'status': 'weird'}).status, SubscriptionStatus.free);
  });
}
