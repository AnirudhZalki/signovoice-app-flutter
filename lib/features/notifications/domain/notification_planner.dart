import '../../../l10n/app_localizations.dart';
import '../../profile/domain/user_preferences.dart';
import '../../subscription/domain/subscription.dart';
import '../../subscription/domain/trial_policy.dart';
import 'notification_models.dart';

/// Decides which local notifications should exist right now. Pure and
/// deterministic: given prefs + subscription + time it returns the full set,
/// which the service then schedules (replacing whatever was scheduled before).
class NotificationPlanner {
  const NotificationPlanner._();

  static const idLearning = 1;
  static const idStreak = 2;
  static const idTrial3d = 10;
  static const idTrial1d = 11;
  static const idRenewal = 20;

  static DateTime _nextAt(DateTime now, int hour, {int minute = 0}) {
    var t = DateTime(now.year, now.month, now.day, hour, minute);
    if (!t.isAfter(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  static List<PlannedNotification> plan({
    required NotificationPrefs prefs,
    required int reminderHour,
    required Subscription subscription,
    required DateTime now,
    required AppLocalizations l,
    required String Function(DateTime) formatDate,
  }) {
    final out = <PlannedNotification>[];

    if (prefs.learningReminders) {
      out.add(PlannedNotification(
        id: idLearning,
        kind: NotificationKind.learningReminder,
        title: l.notifLearnTitle,
        body: l.notifLearnBody,
        when: _nextAt(now, reminderHour),
        repeatsDaily: true,
      ));
    }
    if (prefs.practiceStreak) {
      // A different hour from the learning reminder so they never stack.
      final h = (reminderHour + 3) % 24;
      out.add(PlannedNotification(
        id: idStreak,
        kind: NotificationKind.practiceStreak,
        title: l.notifStreakTitle,
        body: l.notifStreakBody,
        when: _nextAt(now, h),
        repeatsDaily: true,
      ));
    }

    final status = TrialPolicy.effectiveStatus(subscription, now);
    final end = TrialPolicy.accessEndDate(subscription, now);

    if (prefs.trialReminders && status == SubscriptionStatus.trial && end != null) {
      for (final (id, days) in [(idTrial3d, 3), (idTrial1d, 1)]) {
        final at = DateTime(end.year, end.month, end.day, 10).subtract(Duration(days: days));
        if (at.isAfter(now)) {
          out.add(PlannedNotification(
            id: id,
            kind: NotificationKind.trialEnding,
            title: l.notifTrialTitle,
            body: l.notifTrialBody('$days', formatDate(end)),
            when: at,
          ));
        }
      }
    }

    if (prefs.renewalInfo && status == SubscriptionStatus.premium && subscription.autoRenewing && end != null) {
      final at = DateTime(end.year, end.month, end.day, 10).subtract(const Duration(days: 3));
      if (at.isAfter(now)) {
        out.add(PlannedNotification(
          id: idRenewal,
          kind: NotificationKind.renewal,
          title: l.notifRenewalTitle,
          body: l.notifRenewalBody(formatDate(end)),
          when: at,
        ));
      }
    }
    return out;
  }
}
