import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/notification_models.dart';
import '../domain/notification_service.dart';

/// Local reminders through flutter_local_notifications. Uses inexact alarms so
/// no "exact alarm" permission is needed.
class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin]) : _p = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _p;
  bool _ready = false;

  static const _channels = {
    NotificationKind.learningReminder: ('learning', 'Learning reminders'),
    NotificationKind.practiceStreak: ('streak', 'Practice streak'),
    NotificationKind.trialEnding: ('subscription', 'Subscription'),
    NotificationKind.renewal: ('subscription', 'Subscription'),
    NotificationKind.interpreter: ('interpreter', 'Interpreter updates'),
    NotificationKind.system: ('system', 'System'),
  };

  NotificationDetails _details(NotificationKind k) {
    final c = _channels[k]!;
    return NotificationDetails(
      android: AndroidNotificationDetails(c.$1, c.$2, importance: Importance.defaultImportance, priority: Priority.defaultPriority),
    );
  }

  @override
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _p.initialize(settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
    _ready = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> hasPermission() async => (await _android?.areNotificationsEnabled()) ?? false;

  @override
  Future<bool> requestPermission() async {
    await init();
    return (await _android?.requestNotificationsPermission()) ?? false;
  }

  @override
  Future<void> apply(List<PlannedNotification> plan) async {
    await init();
    await _p.cancelAllPendingNotifications();
    for (final n in plan) {
      // Absolute instant in UTC: re-planned on every launch/setting change, so DST drift self-corrects.
      final at = tz.TZDateTime.from(n.when, tz.UTC);
      await _p.zonedSchedule(
        id: n.id,
        title: n.title,
        body: n.body,
        scheduledDate: at,
        notificationDetails: _details(n.kind),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: n.repeatsDaily ? DateTimeComponents.time : null,
        payload: n.kind.name,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await init();
    await _p.cancelAll();
  }

  @override
  Future<void> showNow({required int id, required NotificationKind kind, required String title, required String body}) async {
    await init();
    await _p.show(id: id, title: title, body: body, notificationDetails: _details(kind), payload: kind.name);
  }
}
