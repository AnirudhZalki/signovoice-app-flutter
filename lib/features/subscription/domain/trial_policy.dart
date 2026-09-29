import '../../../core/constants/app_constants.dart';
import 'subscription.dart';

/// Pure rules turning a verified [Subscription] record into what the person
/// can do *right now*. Everything takes `now` explicitly (testable, and no
/// reliance on a boolean that could be tampered with).
class TrialPolicy {
  const TrialPolicy._();

  /// The store decides the real trial length; this mirrors it for display and
  /// for computing expiry when only a start date is known.
  static DateTime trialEndFrom(DateTime start) => addMonths(start, 1);

  static DateTime addMonths(DateTime d, int months) {
    final y = d.year + (d.month - 1 + months) ~/ 12;
    final m = (d.month - 1 + months) % 12 + 1;
    final lastDay = DateTime(y, m + 1, 0).day;
    return DateTime(y, m, d.day > lastDay ? lastDay : d.day, d.hour, d.minute, d.second);
  }

  /// One free trial per account. Eligibility is confirmed again by the store
  /// (Google Play only offers the trial to users who never used it).
  static bool isTrialEligible(Subscription s) =>
      !s.hasEverTrialed && (s.status == SubscriptionStatus.free);

  /// Re-derives the status from dates, so a stale stored status (e.g. "trial")
  /// can never outlive its end date.
  static SubscriptionStatus effectiveStatus(Subscription s, DateTime now) {
    bool active(DateTime? end) => end != null && now.isBefore(end);
    switch (s.status) {
      case SubscriptionStatus.free:
        return SubscriptionStatus.free;
      case SubscriptionStatus.trial:
        if (active(s.trialEndDate)) return SubscriptionStatus.trial;
        // trial ended: paid period may have started (auto-renewed)
        if (active(s.subscriptionEndDate)) return s.autoRenewing ? SubscriptionStatus.premium : SubscriptionStatus.cancelled;
        return SubscriptionStatus.expired;
      case SubscriptionStatus.premium:
        return active(s.subscriptionEndDate) ? SubscriptionStatus.premium : SubscriptionStatus.expired;
      case SubscriptionStatus.cancelled:
        // Cancelled = will not renew, but paid access lasts until the end date.
        final end = s.subscriptionEndDate ?? s.trialEndDate;
        return active(end) ? SubscriptionStatus.cancelled : SubscriptionStatus.expired;
      case SubscriptionStatus.expired:
        return SubscriptionStatus.expired;
    }
  }

  static bool hasPremiumAccess(Subscription s, DateTime now) {
    final st = effectiveStatus(s, now);
    return st == SubscriptionStatus.trial || st == SubscriptionStatus.premium || st == SubscriptionStatus.cancelled;
  }

  /// Whole days left in the trial (rounded up); 0 if not in a trial.
  static int trialDaysLeft(Subscription s, DateTime now) {
    if (effectiveStatus(s, now) != SubscriptionStatus.trial || s.trialEndDate == null) return 0;
    return (s.trialEndDate!.difference(now).inHours / 24).ceil().clamp(0, 9999);
  }

  /// When access ends / the plan renews, if known.
  static DateTime? accessEndDate(Subscription s, DateTime now) {
    return switch (effectiveStatus(s, now)) {
      SubscriptionStatus.trial => s.trialEndDate,
      SubscriptionStatus.premium || SubscriptionStatus.cancelled => s.subscriptionEndDate ?? s.trialEndDate,
      _ => null,
    };
  }

  static bool shouldRemindTrialEnding(Subscription s, DateTime now, {int daysBefore = 3}) {
    final left = trialDaysLeft(s, now);
    return left > 0 && left <= daysBefore;
  }

  /// Used only as a documented default until the store reports the real value.
  static Duration get nominalTrialLength => AppConstants.trialLength;
}
