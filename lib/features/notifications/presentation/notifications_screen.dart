import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../domain/notification_models.dart';
import 'notification_providers.dart';

IconData notificationIcon(NotificationKind k) => switch (k) {
      NotificationKind.learningReminder => Icons.school_outlined,
      NotificationKind.practiceStreak => Icons.local_fire_department_outlined,
      NotificationKind.trialEnding => Icons.hourglass_bottom_rounded,
      NotificationKind.renewal => Icons.autorenew_rounded,
      NotificationKind.interpreter => Icons.video_call_outlined,
      NotificationKind.system => Icons.info_outline_rounded,
    };

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(inboxProvider);
    final list = async.value ?? const <AppNotification>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notificationsTitle),
        actions: [
          if (list.any((n) => !n.read)) IconButton(tooltip: l.markAllRead, icon: const Icon(Icons.done_all_rounded), onPressed: ref.read(inboxProvider.notifier).markAllRead),
          if (list.isNotEmpty) IconButton(tooltip: l.clear, icon: const Icon(Icons.delete_sweep_outlined), onPressed: ref.read(inboxProvider.notifier).clear),
          IconButton(tooltip: l.settingsNotifications, icon: const Icon(Icons.settings_outlined), onPressed: () => context.push(Routes.settingsNotifications)),
        ],
      ),
      body: AsyncValueView<List<AppNotification>>(
        value: async,
        onRetry: () => ref.invalidate(inboxProvider),
        data: (items) => items.isEmpty
            ? EmptyState(icon: Icons.notifications_none_rounded, title: l.notificationsEmpty, message: l.notificationsEmptyBody)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final n = items[i];
                  final when = DateFormat.yMMMd(locale).add_jm().format(n.timestamp);
                  return AppCard(
                    onTap: () => ref.read(inboxProvider.notifier).markRead(n.id),
                    semanticLabel: '${n.read ? '' : '${l.notificationNew}. '}${n.title}. ${n.body}. $when',
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(notificationIcon(n.kind)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(n.title, style: Theme.of(context).textTheme.titleMedium)),
                            if (!n.read) Text(l.notificationNew, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 2),
                          Text(n.body),
                          const SizedBox(height: 4),
                          Text(when, style: Theme.of(context).textTheme.labelSmall),
                        ]),
                      ),
                    ]),
                  );
                },
              ),
      ),
    );
  }
}
