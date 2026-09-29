import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../profile/presentation/preferences_controller.dart';
import '../sign_translation_controller.dart';

Future<void> showVoiceSettingsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const VoiceSettingsSheet(),
    );

/// Speed / language / voice selection for text-to-speech.
class VoiceSettingsSheet extends ConsumerStatefulWidget {
  const VoiceSettingsSheet({super.key});

  @override
  ConsumerState<VoiceSettingsSheet> createState() => _VoiceSettingsSheetState();
}

class _VoiceSettingsSheetState extends ConsumerState<VoiceSettingsSheet> {
  List<TtsVoice>? _voices;

  @override
  void initState() {
    super.initState();
    ref.read(ttsServiceProvider).voices().then((v) {
      if (mounted) setState(() => _voices = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    final tts = ref.read(ttsServiceProvider);
    final languages = {'en': l.langEnglish, 'hi': l.langHindi, 'kn': l.langKannada};
    final code = prefs.ttsLanguage.split('-').first;
    final voices = (_voices ?? const <TtsVoice>[]).where((v) => v.locale.toLowerCase().startsWith(code)).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.voiceSettings, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(l.voiceLanguage, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in languages.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: code == e.key,
                  onSelected: (_) => notifier.update((p) => p.copyWith(ttsLanguage: ttsLocaleFor(e.key), clearVoice: true)),
                ),
            ]),
            const SizedBox(height: 16),
            Text(l.voiceSpeed, style: Theme.of(context).textTheme.titleSmall),
            Slider(
              value: prefs.ttsRate,
              min: 0.2,
              max: 1.0,
              divisions: 8,
              label: prefs.ttsRate.toStringAsFixed(1),
              semanticFormatterCallback: (v) => '${(v * 100).round()}%',
              onChanged: (v) => notifier.update((p) => p.copyWith(ttsRate: v)),
            ),
            const SizedBox(height: 8),
            Text(l.voiceSelect, style: Theme.of(context).textTheme.titleSmall),
            if (_voices != null && voices.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.voiceNoneForLanguage)),
                ]),
              )
            else
              RadioGroup<String?>(
                groupValue: prefs.ttsVoiceName,
                onChanged: (name) {
                  if (name == null) {
                    notifier.update((p) => p.copyWith(clearVoice: true));
                  } else {
                    final v = voices.firstWhere((v) => v.name == name);
                    notifier.update((p) => p.copyWith(ttsVoiceName: v.name, ttsVoiceLocale: v.locale));
                  }
                },
                child: Column(children: [
                  RadioListTile<String?>(value: null, title: Text(l.voiceDefault)),
                  for (final v in voices.take(12)) RadioListTile<String?>(value: v.name, title: Text(v.name), subtitle: Text(v.locale)),
                ]),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.volume_up_rounded),
              label: Text(l.play),
              onPressed: () => tts.speak(
                languages[code] ?? '',
                language: prefs.ttsLanguage,
                rate: prefs.ttsRate,
                voice: prefs.ttsVoiceName == null
                    ? null
                    : TtsVoice(name: prefs.ttsVoiceName!, locale: prefs.ttsVoiceLocale ?? prefs.ttsLanguage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
