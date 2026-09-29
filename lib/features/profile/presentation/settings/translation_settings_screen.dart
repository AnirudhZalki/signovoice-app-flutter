import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/user_preferences.dart';
import '../preferences_controller.dart';
import 'settings_widgets.dart';

class TranslationSettingsScreen extends ConsumerWidget {
  const TranslationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final prefs = ref.watch(preferencesProvider);
    final n = ref.read(preferencesProvider.notifier);
    final online = AppConfig.hasRemoteRecognition;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTranslation)),
      body: ListView(children: [
        SettingsHeader(l.transMode),
        RadioGroup<RecognitionMode>(
          groupValue: prefs.recognitionMode,
          onChanged: (m) {
            if (m != null && (m == RecognitionMode.onDevice || online)) n.update((p) => p.copyWith(recognitionMode: m));
          },
          child: Column(children: [
            RadioListTile<RecognitionMode>(value: RecognitionMode.onDevice, title: Text(l.transOnDevice), subtitle: Text(l.transOnDeviceDesc)),
            RadioListTile<RecognitionMode>(
              value: RecognitionMode.remote,
              enabled: online,
              title: Text(l.transOnline),
              subtitle: Text(online ? l.transOnlineDesc : l.transOnlineUnavailable),
            ),
          ]),
        ),
        SettingsHeader(l.transConfidence),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Slider(
              value: prefs.confidenceThreshold,
              min: 0.3,
              max: 0.95,
              divisions: 13,
              label: '${(prefs.confidenceThreshold * 100).round()}%',
              semanticFormatterCallback: (v) => '${(v * 100).round()}%',
              onChanged: (v) => n.update((p) => p.copyWith(confidenceThreshold: v)),
            ),
            Text(l.transConfidenceDesc, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        SwitchListTile(title: Text(l.transAutoSpeak), value: prefs.autoSpeak, onChanged: (v) => n.update((p) => p.copyWith(autoSpeak: v))),
        SwitchListTile(title: Text(l.transMirror), subtitle: Text(l.transMirrorDesc), value: prefs.mirrorCamera, onChanged: (v) => n.update((p) => p.copyWith(mirrorCamera: v))),
        Padding(padding: const EdgeInsets.all(16), child: Text(l.transModelNote('9'), style: Theme.of(context).textTheme.bodySmall)),
      ]),
    );
  }
}
