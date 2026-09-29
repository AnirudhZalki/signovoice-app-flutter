import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../learning/presentation/learning_controller.dart';
import '../../profile/presentation/preferences_controller.dart';
import '../../subscription/domain/subscription.dart';
import '../../subscription/presentation/subscription_providers.dart';
import '../data/inbox_repository.dart';
import '../data/local_notification_service.dart';
import '../domain/notification_models.dart';
import '../domain/notification_planner.dart';
import '../domain/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => LocalNotificationService());

final inboxRepositoryProvider = Provider<InboxRepository>((ref) => InboxRepository(ref.watch(collectionStoreProvider)));

class InboxController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() => ref.read(inboxRepositoryProvider).all();

  InboxRepository get _repo => ref.read(inboxRepositoryProvider);

  Future<void> add(AppNotification n) async {
    await _repo.add(n);
    state = AsyncData(await _repo.all());
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    state = AsyncData(await _repo.all());
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    state = AsyncData(await _repo.all());
  }

  Future<void> clear() async {
    await _repo.clear();
    state = const AsyncData([]);
  }
}

final inboxProvider = AsyncNotifierProvider<InboxController, List<AppNotification>>(InboxController.new);
final unreadCountProvider = Provider<int>((ref) => (ref.watch(inboxProvider).value ?? const []).where((n) => !n.read).length);

AppLocalizations _l10nFor(String? code) => lookupAppLocalizations(Locale(const {'en', 'hi', 'kn'}.contains(code) ? code! : 'en'));

/// Re-plans local reminders whenever settings, subscription or streak change.
/// Nothing is scheduled unless the OS permission was granted.
final notificationSyncProvider = FutureProvider<void>((ref) async {
  final prefs = ref.watch(preferencesProvider);
  final sub = ref.watch(subscriptionProvider).value;
  ref.watch(learningProvider.select((p) => p.lastActiveDay)); // re-plan after activity
  final service = ref.read(notificationServiceProvider);
  final now = ref.read(clockProvider)();
  final l = _l10nFor(prefs.localeCode);

  try {
    if (!await service.hasPermission()) {
      await service.cancelAll();
      return;
    }
    final plan = NotificationPlanner.plan(
      prefs: prefs.notifications,
      reminderHour: prefs.reminderHour,
      subscription: sub ?? Subscription.free,
      now: now,
      l: l,
      formatDate: (d) => '${d.day}/${d.month}/${d.year}',
    );
    await service.apply(plan);
  } catch (_) {
    // Reminders are best-effort; never surface scheduling problems as crashes.
  }
});

/// Registers this device for push (FCM) and stores incoming messages in the inbox.
final pushSyncProvider = FutureProvider<void>((ref) async {
  if (!ref.watch(firebaseAvailableProvider)) return;
  final auth = ref.watch(authControllerProvider);
  if (!auth.isSignedIn) return;
  if (!ref.watch(preferencesProvider.select((p) => p.notifications.system || p.notifications.interpreterUpdates))) return;
  try {
    final fm = FirebaseMessaging.instance;
    final token = await fm.getToken();
    if (token != null) await ref.read(pushTokenSinkProvider)(auth.uid, token);
    final sub = FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n == null) return;
      ref.read(inboxProvider.notifier).add(AppNotification(
            id: m.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
            kind: m.data['kind'] == 'interpreter' ? NotificationKind.interpreter : NotificationKind.system,
            title: n.title ?? '',
            body: n.body ?? '',
            timestamp: DateTime.now(),
          ));
    });
    ref.onDispose(sub.cancel);
  } catch (_) {/* push is optional */}
});

/// Where device tokens are stored (Firestore `users/{uid}/devices/{token}`); overridable for tests.
final pushTokenSinkProvider = Provider<Future<void> Function(String uid, String token)>((ref) => (uid, token) async {
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('devices').doc(token).set(
        {'platform': 'android', 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    });
