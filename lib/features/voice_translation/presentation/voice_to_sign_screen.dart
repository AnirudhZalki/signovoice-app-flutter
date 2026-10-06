import 'dart:async';

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
import '../../../shared/widgets/panel_sheet.dart';
import '../../../shared/widgets/record_buttons.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../../dictionary/domain/text_to_sign.dart';
import '../../dictionary/presentation/widgets/sign_media_view.dart';
import '../../profile/presentation/preferences_controller.dart';
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
  int _index = 0;
  bool _auto = true;
  Timer? _timer;

  /// Plays the signs one after another, like an interpreter would sign the sentence.
  void _restartAutoplay(int count) {
    _timer?.cancel();
    if (!_auto || count < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!mounted) return t.cancel();
      if (_index >= count - 1) return t.cancel();
      setState(() => _index++);
    });
  }

  void _go(int i, int count) {
    setState(() => _index = i.clamp(0, count - 1));
    _restartAutoplay(count);
  }

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
    _timer?.cancel();
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
    // New text => start from the first sign again.
    ref.listen(voiceToSignProvider.select((v) => v.tokens.length), (_, n) {
      setState(() => _index = 0);
      _restartAutoplay(n);
    });
    if (ref.read(preferencesProvider).reduceMotion && _auto) _auto = false; // reduced motion: manual stepping only

    final micDenied = _mic == PermissionState.permanentlyDenied;
    final unavailable = s.failure?.code == speechUnavailableCode;

    final size = MediaQuery.sizeOf(context);
    final index = s.tokens.isEmpty ? 0 : _index.clamp(0, s.tokens.length - 1);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l.vsTitle),
        actions: [IconButton(tooltip: l.historyTitle, icon: const Icon(Icons.history_rounded), onPressed: () => context.push(Routes.history))],
      ),
      // Full-screen stage that shows each sign big; the controls float in a draggable panel.
      body: Stack(fit: StackFit.expand, children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: size.height * 0.30,
          child: _SignStage(
            tokens: s.tokens,
            index: index,
            auto: _auto,
            onPrev: index > 0 ? () => _go(index - 1, s.tokens.length) : null,
            onNext: index < s.tokens.length - 1 ? () => _go(index + 1, s.tokens.length) : null,
            onToggleAuto: () {
              setState(() => _auto = !_auto);
              _restartAutoplay(s.tokens.length);
            },
          ),
        ),
        PanelSheet(
          initial: 0.42,
          min: 0.18,
          max: 0.85,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.speechLanguage, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in languages.entries)
                ChoiceChip(label: Text(e.value), selected: s.languageCode == e.key, onSelected: (_) => ctrl.setLanguage(e.key)),
            ]),
            const SizedBox(height: 12),
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
            if (s.heardNothing && !s.listening) Padding(padding: const EdgeInsets.only(top: 12), child: Text(l.speechNothingHeard)),
            const SizedBox(height: 12),
            Text(l.heardLabel, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _text,
              minLines: 2,
              maxLines: 4,
              onChanged: ctrl.setText,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(hintText: l.typeHere, suffixIcon: s.transcript.isEmpty ? null : IconButton(tooltip: l.clear, icon: const Icon(Icons.close_rounded), onPressed: ctrl.clear)),
            ),
            if (s.tokens.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Semantics(header: true, child: Text(l.signsForText, style: Theme.of(context).textTheme.titleMedium))),
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
              // Jump to any word of the sentence.
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (var i = 0; i < s.tokens.length; i++)
                  ChoiceChip(
                    avatar: s.tokens[i].hasSign ? null : const Icon(Icons.help_outline_rounded, size: 16),
                    label: Text(s.tokens[i].entry?.word ?? s.tokens[i].surface),
                    selected: i == index,
                    onSelected: (_) => _go(i, s.tokens.length),
                  ),
              ]),
            ],
          ]),
        ),
      ]),
    );
  }
}

/// Full-screen "stage": the current sign plays big, with previous / next and autoplay.
class _SignStage extends StatelessWidget {
  const _SignStage({required this.tokens, required this.index, required this.auto, required this.onPrev, required this.onNext, required this.onToggleAuto});
  final List<SignToken> tokens;
  final int index;
  final bool auto;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onToggleAuto;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [scheme.primaryContainer, scheme.surface]),
      ),
      child: tokens.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32, top, 32, 16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.record_voice_over_rounded, size: 72, color: scheme.primary),
                  const SizedBox(height: 16),
                  Text(l.vsHint, style: text.titleMedium, textAlign: TextAlign.center),
                ]),
              ),
            )
          : Padding(
              padding: EdgeInsets.fromLTRB(16, top + 4, 16, 8),
              child: Column(children: [
                Semantics(
                  liveRegion: true,
                  child: Text(tokens[index].entry?.word ?? tokens[index].surface, style: text.headlineMedium, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: tokens[index].entry == null
                          ? Column(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.help_outline_rounded, size: 64, color: scheme.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text(l.noSignYetForWord, style: text.titleMedium, textAlign: TextAlign.center),
                            ])
                          : Column(mainAxisSize: MainAxisSize.min, children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 560, maxHeight: MediaQuery.sizeOf(context).height * 0.5),
                                child: SignMediaView(entry: tokens[index].entry!),
                              ),
                              const SizedBox(height: 8),
                              Text(tokens[index].entry!.meaning, style: text.bodyMedium, textAlign: TextAlign.center),
                            ]),
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton.filledTonal(tooltip: l.back, onPressed: onPrev, icon: const Icon(Icons.skip_previous_rounded)),
                  const SizedBox(width: 12),
                  Text('${index + 1} / ${tokens.length}', style: text.titleMedium),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(tooltip: l.next, onPressed: onNext, icon: const Icon(Icons.skip_next_rounded)),
                  const SizedBox(width: 16),
                  IconButton(tooltip: auto ? l.pause : l.resume, onPressed: onToggleAuto, icon: Icon(auto ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded, size: 32)),
                ]),
              ]),
            ),
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
