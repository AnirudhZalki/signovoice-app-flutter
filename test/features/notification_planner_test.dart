import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/features/notifications/domain/notification_models.dart';
import 'package:signovoice/features/notifications/domain/notification_planner.dart';
import 'package:signovoice/features/profile/domain/user_preferences.dart';
import 'package:signovoice/features/subscription/domain/subscription.dart';
import 'package:signovoice/l10n/app_localizations.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2026, 6, 10, 9, 30);
  String fmt(DateTime d) => '${d.day}/${d.month}';
  List<PlannedNotification> plan(NotificationPrefs p, Subscription s, {int hour = 18}) =>
      NotificationPlanner.plan(prefs: p, reminderHour: hour, subscription: s, now: now, l: l, formatDate: fmt);

  test('default prefs schedule a daily learning reminder and streak nudge at different hours', () {
    final r = plan(const NotificationPrefs(), Subscription.free);
    expect(r.map((e) => e.id), containsAll([NotificationPlanner.idLearning, NotificationPlanner.idStreak]));
    final learn = r.firstWhere((e) => e.id == NotificationPlanner.idLearning);
    final streak = r.firstWhere((e) => e.id == NotificationPlanner.idStreak);
    expect(learn.repeatsDaily, isTrue);
    expect(learn.when, DateTime(2026, 6, 10, 18));
    expect(streak.when.hour, 21);
    expect(learn.when.hour, isNot(streak.when.hour));
  });

  test('a reminder time already passed today starts tomorrow', () {
    final r = plan(const NotificationPrefs(), Subscription.free, hour: 8);
    expect(r.firstWhere((e) => e.id == NotificationPlanner.idLearning).when, DateTime(2026, 6, 11, 8));
  });

  test('turning categories off removes them', () {
    final r = plan(
      const NotificationPrefs(learningReminders: false, practiceStreak: false, trialReminders: false, renewalInfo: false),
      Subscription.free,
    );
    expect(r, isEmpty);
  });

  test('trial ending reminders at 3 and 1 day before the end, only in the future', () {
    final trial = Subscription(status: SubscriptionStatus.trial, trialStartDate: DateTime(2026, 6, 1), trialEndDate: DateTime(2026, 7, 1));
    final r = plan(const NotificationPrefs(learningReminders: false, practiceStreak: false), trial);
    expect(r.where((e) => e.kind == NotificationKind.trialEnding).length, 2);
    expect(r.firstWhere((e) => e.id == NotificationPlanner.idTrial3d).when, DateTime(2026, 6, 28, 10));
    expect(r.firstWhere((e) => e.id == NotificationPlanner.idTrial3d).body, contains('3'));

    final ending = Subscription(status: SubscriptionStatus.trial, trialStartDate: DateTime(2026, 5, 12), trialEndDate: DateTime(2026, 6, 11, 12));
    final soon = plan(const NotificationPrefs(learningReminders: false, practiceStreak: false), ending);
    // 3-day-before slot (Jun 8) is in the past; 1-day-before (Jun 10 10:00) is too (now is 09:30 -> future). Only future ones stay.
    expect(soon.every((e) => e.when.isAfter(now)), isTrue);
  });

  test('no trial reminders for free, expired or when the setting is off', () {
    final off = plan(const NotificationPrefs(trialReminders: false, learningReminders: false, practiceStreak: false),
        Subscription(status: SubscriptionStatus.trial, trialEndDate: DateTime(2026, 7, 1)));
    expect(off, isEmpty);
    final expired = plan(const NotificationPrefs(learningReminders: false, practiceStreak: false),
        Subscription(status: SubscriptionStatus.trial, trialStartDate: DateTime(2026, 4, 1), trialEndDate: DateTime(2026, 5, 1)));
    expect(expired, isEmpty);
  });

  test('renewal info only for auto-renewing premium, 3 days before', () {
    final prem = Subscription(status: SubscriptionStatus.premium, subscriptionEndDate: DateTime(2026, 7, 10, 12), autoRenewing: true);
    final r = plan(const NotificationPrefs(learningReminders: false, practiceStreak: false), prem);
    expect(r.single.kind, NotificationKind.renewal);
    expect(r.single.when, DateTime(2026, 7, 7, 10));
    final notRenewing = plan(const NotificationPrefs(learningReminders: false, practiceStreak: false), prem.copyWith(autoRenewing: false));
    expect(notRenewing, isEmpty);
  });

  test('localised text (Hindi) is used when requested', () {
    final hi = lookupAppLocalizations(const Locale('hi'));
    final r = NotificationPlanner.plan(
        prefs: const NotificationPrefs(practiceStreak: false), reminderHour: 18, subscription: Subscription.free, now: now, l: hi, formatDate: fmt);
    expect(r.single.title, hi.notifLearnTitle);
    expect(r.single.title, isNot(l.notifLearnTitle));
  });

  test('inbox notification json round trip', () {
    final n = AppNotification(id: '1', kind: NotificationKind.interpreter, title: 't', body: 'b', timestamp: DateTime(2026, 1, 1));
    expect(AppNotification.fromJson(n.toJson()), n);
    expect(n.copyWith(read: true).read, isTrue);
  });
}
