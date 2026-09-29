import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../preferences_controller.dart';
import 'settings_widgets.dart';

class AccessibilityScreen extends ConsumerWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final prefs = ref.watch(preferencesProvider);
    final n = ref.read(preferencesProvider.notifier);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsAccessibility)),
      body: ListView(children: [
        SettingsHeader(l.accTextSize),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.text_decrease_rounded),
              Expanded(
                child: Slider(
                  value: prefs.textScale,
                  min: 0.85,
                  max: 1.6,
                  divisions: 15,
                  label: '${(prefs.textScale * 100).round()}%',
                  semanticFormatterCallback: (v) => '${(v * 100).round()}%',
                  onChanged: (v) => n.update((p) => p.copyWith(textScale: v)),
                ),
              ),
              const Icon(Icons.text_increase_rounded),
            ]),
            // The app-wide scaler is applied above this screen; preview shows the effect immediately.
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(l.accTextSizePreview, style: text.bodyLarge))),
          ]),
        ),
        const SizedBox(height: 8),
        SwitchListTile(title: Text(l.accHighContrast), subtitle: Text(l.accHighContrastDesc), value: prefs.highContrast, onChanged: (v) => n.update((p) => p.copyWith(highContrast: v))),
        SwitchListTile(title: Text(l.accReduceMotion), subtitle: Text(l.accReduceMotionDesc), value: prefs.reduceMotion, onChanged: (v) => n.update((p) => p.copyWith(reduceMotion: v))),
        SwitchListTile(title: Text(l.accHaptics), subtitle: Text(l.accHapticsDesc), value: prefs.haptics, onChanged: (v) => n.update((p) => p.copyWith(haptics: v))),
        SwitchListTile(title: Text(l.accVoiceFeedback), subtitle: Text(l.accVoiceFeedbackDesc), value: prefs.voiceFeedback, onChanged: (v) => n.update((p) => p.copyWith(voiceFeedback: v))),
      ]),
    );
  }
}
