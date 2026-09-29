import 'package:equatable/equatable.dart';

enum NotificationKind { learningReminder, practiceStreak, trialEnding, renewal, interpreter, system }

/// An entry in the in-app notification inbox.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.timestamp,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool read;

  AppNotification copyWith({bool? read}) =>
      AppNotification(id: id, kind: kind, title: title, body: body, timestamp: timestamp, read: read ?? this.read);

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        kind: NotificationKind.values.firstWhere((k) => k.name == j['kind'], orElse: () => NotificationKind.system),
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        read: j['read'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, kind, title, body, timestamp, read];
}

/// A local notification the app wants scheduled.
class PlannedNotification extends Equatable {
  const PlannedNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.when,
    this.repeatsDaily = false,
  });

  final int id;
  final NotificationKind kind;
  final String title;
  final String body;

  /// First (or only) fire time, local.
  final DateTime when;
  final bool repeatsDaily;

  @override
  List<Object?> get props => [id, kind, title, body, when, repeatsDaily];
}
