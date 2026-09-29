import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/providers.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../notifications/presentation/notification_providers.dart';
import '../../domain/user_preferences.dart';
import '../preferences_controller.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _State();
}

class _State extends ConsumerState<NotificationSettingsScreen> {
  bool? _granted;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = await ref.read(notificationServiceProvider).hasPermission();
    if (mounted) setState(() => _granted = ok);
  }

  Future<void> _ask() async {
    final ok = await ref.read(notificationServiceProvider).requestPermission();
    if (!ok) {
      // Denied: send to system settings where it can be switched on.
      final st = await ref.read(permissionServiceProvider).status(AppPermission.notifications);
      if (st == PermissionState.permanentlyDenied) await ref.read(permissionServiceProvider).openSettings();
    }
    await _check();
    ref.invalidate(notificationSyncProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final prefs = ref.watch(preferencesProvider);
    final np = prefs.notifications;
    final n = ref.read(preferencesProvider.notifier);
    Future<void> set(NotificationPrefs Function(NotificationPrefs) f) async {
      await n.update((p) => p.copyWith(notifications: f(p.notifications)));
      // Turning something on is the moment to ask for the OS permission.
      if (_granted != true) await _ask();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.notifSettingsTitle)),
      body: ListView(children: [
        if (_granted == false)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.notifications_off_outlined), const SizedBox(width: 8), Expanded(child: Text(l.notifPermissionOff))]),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: _ask, child: Text(l.notifPermissionAsk)),
                ]),
              ),
            ),
          ),
        SwitchListTile(title: Text(l.notifLearning), value: np.learningReminders, onChanged: (v) => set((x) => x.copyWith(learningReminders: v))),
        SwitchListTile(title: Text(l.notifStreakSetting), value: np.practiceStreak, onChanged: (v) => set((x) => x.copyWith(practiceStreak: v))),
        SwitchListTile(title: Text(l.notifTrialSetting), value: np.trialReminders, onChanged: (v) => set((x) => x.copyWith(trialReminders: v))),
        SwitchListTile(title: Text(l.notifRenewalSetting), value: np.renewalInfo, onChanged: (v) => set((x) => x.copyWith(renewalInfo: v))),
        SwitchListTile(title: Text(l.notifInterpreterSetting), value: np.interpreterUpdates, onChanged: (v) => set((x) => x.copyWith(interpreterUpdates: v))),
        SwitchListTile(title: Text(l.notifSystemSetting), value: np.system, onChanged: (v) => set((x) => x.copyWith(system: v))),
        ListTile(
          leading: const Icon(Icons.schedule_rounded),
          title: Text(l.reminderTime),
          subtitle: Text(TimeOfDay(hour: prefs.reminderHour, minute: 0).format(context)),
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: prefs.reminderHour, minute: 0));
            if (t != null) await n.update((p) => p.copyWith(reminderHour: t.hour));
          },
        ),
      ]),
    );
  }
}
