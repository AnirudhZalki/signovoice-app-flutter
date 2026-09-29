import 'notification_models.dart';

abstract class NotificationService {
  Future<void> init();

  /// Asks the OS for permission (Android 13+ runtime prompt). Call only after
  /// the person turns a notification setting on.
  Future<bool> requestPermission();
  Future<bool> hasPermission();

  /// Replaces every scheduled reminder with [plan].
  Future<void> apply(List<PlannedNotification> plan);
  Future<void> cancelAll();

  /// Shows one notification immediately (e.g. an interpreter update while foregrounded).
  Future<void> showNow({required int id, required NotificationKind kind, required String title, required String body});
}
