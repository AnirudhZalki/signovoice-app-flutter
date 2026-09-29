import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure.dart';
import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/record_buttons.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../../dictionary/domain/text_to_sign.dart';
import '../../dictionary/presentation/widgets/sign_media_view.dart';
import '../domain/speech_service.dart';
import 'voice_to_sign_controller.dart';

class VoiceToSignScreen extends ConsumerStatefulWidget {
  const VoiceToSignScreen({super.key});

  @override
  ConsumerState<VoiceToSignScreen> createState() => _VoiceToSignScreenState();
}

class _VoiceToSignScreenState extends ConsumerState<VoiceToSignScreen> {
  final _text = TextEditingController();
  PermissionState? _mic;

  @override
  void initState() {
    super.initState();
    ref.read(permissionServiceProvider).status(AppPermission.microphone).then((s) {
      if (mounted) setState(() => _mic = s);
    }).catchError((Object _) {
      // Unknown permission state: the mic button will request it on tap.
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _onMic() async {
    final ctrl = ref.read(voiceToSignProvider.notifier);
    if (_mic != PermissionState.granted && !ref.read(voiceToSignProvider).listening) {
      final r = await ref.read(permissionServiceProvider).request(AppPermission.microphone);
      if (!mounted) return;
      setState(() => _mic = r);
      if (r != PermissionState.granted) return;
    }
    await ctrl.toggleListening();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = ref.watch(voiceToSignProvider);
    final ctrl = ref.read(voiceToSignProvider.notifier);
    final languages = {'en': l.langEnglish, 'hi': l.langHindi, 'kn': l.langKannada};

    ref.listen(voiceToSignProvider.select((v) => v.transcript), (_, t) {
      if (_text.text != t) {
        _text.value = TextEditingValue(text: t, selection: TextSelection.collapsed(offset: t.length));
      }
    });

    final micDenied = _mic == PermissionState.permanentlyDenied;
    final unavailable = s.failure?.code == speechUnavailableCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.vsTitle),
        actions: [IconButton(tooltip: l.historyTitle, icon: const Icon(Icons.history_rounded), onPressed: () => context.push(Routes.history))],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(l.vsHint, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        Text(l.speechLanguage, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in languages.entries)
            ChoiceChip(label: Text(e.value), selected: s.languageCode == e.key, onSelected: (_) => ctrl.setLanguage(e.key)),
        ]),
        const SizedBox(height: 16),
        if (micDenied)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.mic_off_outlined), const SizedBox(width: 8), Expanded(child: Text(l.micPermTitle, style: Theme.of(context).textTheme.titleMedium))]),
              const SizedBox(height: 6),
              Text(l.micPermBody),
              const SizedBox(height: 12),
              SecondaryButton(label: l.openSettings, icon: Icons.settings_rounded, onPressed: ref.read(permissionServiceProvider).openSettings),
            ]),
          )
        else
          Column(children: [
            Center(
              child: VoiceButton(
                listening: s.listening,
                onPressed: unavailable ? null : _onMic,
                startLabel: l.tapToSpeak,
                stopLabel: l.tapToStop,
              ),
            ),
            Semantics(
              liveRegion: true,
              child: Text(s.listening ? l.listeningLabel : l.tapToSpeak, style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center),
            ),
          ]),
        if (s.failure != null) ...[
          const SizedBox(height: 12),
          _FailureNote(failure: s.failure!, unavailable: unavailable),
        ],
        if (s.heardNothing && !s.listening)
          Padding(padding: const EdgeInsets.only(top: 12), child: Text(l.speechNothingHeard)),
        const SizedBox(height: 16),
        Text(l.heardLabel, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        TextField(
          controller: _text,
          minLines: 2,
          maxLines: 5,
          onChanged: ctrl.setText,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: l.typeHere, suffixIcon: s.transcript.isEmpty ? null : IconButton(tooltip: l.clear, icon: const Icon(Icons.close_rounded), onPressed: ctrl.clear)),
        ),
        const SizedBox(height: 16),
        if (s.tokens.isNotEmpty) ...[
          Row(children: [
            Expanded(child: Semantics(header: true, child: Text(l.signsForText, style: Theme.of(context).textTheme.titleLarge))),
            TextButton.icon(
              onPressed: s.saved
                  ? null
                  : () async {
                      final ok = await ctrl.saveToHistory();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? l.savedToHistory : l.historyOffHint)));
                    },
              icon: Icon(s.saved ? Icons.check_rounded : Icons.bookmark_add_outlined),
              label: Text(s.saved ? l.savedToHistory : l.saveToHistory),
            ),
          ]),
          if (s.missing > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StatusBadge(label: l.missingSignsNote('${s.missing}'), tone: StatusTone.warning),
            ),
          for (final t in s.tokens) ...[_TokenCard(token: t), const SizedBox(height: 12)],
        ],
      ]),
    );
  }
}

class _FailureNote extends StatelessWidget {
  const _FailureNote({required this.failure, required this.unavailable});
  final Failure failure;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final msg = unavailable
        ? l.speechUnavailable
        : switch (failure.type) {
            FailureType.offline => l.failureOffline,
            FailureType.permissionDenied => l.failurePermissionDenied,
            _ => l.failureUnknown,
          };
    return Semantics(
      liveRegion: true,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.error_outline, color: scheme.error),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: TextStyle(color: scheme.error))),
      ]),
    );
  }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({required this.token});
  final SignToken token;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final e = token.entry;
    return AppCard(
      semanticLabel: e == null ? '${token.surface}. ${l.noSignYetForWord}' : e.word,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(e?.word ?? token.surface, style: Theme.of(context).textTheme.titleLarge)),
          if (e == null) StatusBadge(label: l.noSignYetForWord, tone: StatusTone.warning, icon: Icons.help_outline_rounded),
        ]),
        if (e != null) ...[
          const SizedBox(height: 4),
          Text(e.meaning, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          SignMediaView(entry: e, compact: !e.hasMedia),
        ],
      ]),
    );
  }
}
