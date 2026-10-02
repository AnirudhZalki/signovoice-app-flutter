import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure_mapper.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/misc_widgets.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/interpreter_models.dart';
import 'call_controller.dart';
import 'interpreter_providers.dart';
import 'room_card.dart';

String interpreterStatusLabel(AppLocalizations l, InterpreterStatus s) => switch (s) {
      InterpreterStatus.available => l.statusAvailable,
      InterpreterStatus.busy => l.statusBusy,
      InterpreterStatus.offline => l.statusOffline,
    };

(StatusTone, IconData) interpreterStatusStyle(InterpreterStatus s) => switch (s) {
      InterpreterStatus.available => (StatusTone.success, Icons.check_circle_outline),
      InterpreterStatus.busy => (StatusTone.warning, Icons.schedule_rounded),
      InterpreterStatus.offline => (StatusTone.neutral, Icons.do_not_disturb_on_outlined),
    };

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  String? _language;

  Future<void> _openRequestSheet({String? interpreterId}) async {
    final result = await showModalBottomSheet<_RequestOptions>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RequestSheet(initialLanguage: _language ?? 'en'),
    );
    if (result == null || !mounted) return;
    ref.read(callControllerProvider.notifier).reset();
    // Fire and navigate: the call screen shows every state (waiting, failure, ...).
    ref.read(callControllerProvider.notifier).request(
          mode: result.mode,
          language: result.language,
          interpreterId: interpreterId,
          note: result.note,
        );
    context.push(Routes.interpreterCall);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final api = ref.watch(apiClientProvider);
    final call = ref.watch(callControllerProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.liveTitle)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        Text(l.liveIntro, style: text.bodyLarge),
        const SizedBox(height: 16),
        if (call.inCall || call.phase == CallPhase.waiting || call.phase == CallPhase.connecting)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppCard(
              onTap: () => context.push(Routes.interpreterCall),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Row(children: [
                const Icon(Icons.phone_in_talk_rounded),
                const SizedBox(width: 12),
                Expanded(child: Text(call.phase == CallPhase.waiting ? l.callWaiting : l.callConnected, style: text.titleMedium)),
                const Icon(Icons.chevron_right_rounded),
              ]),
            ),
          ),
        if (AppConfig.hasTokenServer) const RoomCard(),
        if (AppConfig.hasDevRoom)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppCard(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.bug_report_outlined), const SizedBox(width: 8), Expanded(child: Text(l.devRoomTitle, style: text.titleMedium))]),
                const SizedBox(height: 6),
                Text(l.devRoomBody),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.videocam_rounded),
                    label: Text(l.requestVideoCall),
                    onPressed: () {
                      ref.read(callControllerProvider.notifier)
                        ..reset()
                        ..joinDevRoom(CallMode.video);
                      context.push(Routes.interpreterCall);
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.call_rounded),
                    label: Text(l.requestAudioCall),
                    onPressed: () {
                      ref.read(callControllerProvider.notifier)
                        ..reset()
                        ..joinDevRoom(CallMode.audio);
                      context.push(Routes.interpreterCall);
                    },
                  ),
                ]),
              ]),
            ),
          ),
        if (!auth.isSignedIn)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.lock_outline_rounded), const SizedBox(width: 8), Expanded(child: Text(l.signInForInterpreter, style: text.titleMedium))]),
              const SizedBox(height: 6),
              Text(l.signInForInterpreterBody),
              const SizedBox(height: 12),
              PrimaryButton(label: l.signIn, onPressed: () => ref.read(authControllerProvider.notifier).leaveGuestMode()),
            ]),
          )
        else if (!api.isConfigured)
          AppCard(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Row(children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 12),
              Expanded(child: Text(l.interpreterNotConfigured)),
            ]),
          )
        else ...[
          PrimaryButton(label: l.requestInterpreter, icon: Icons.video_call_rounded, onPressed: () => _openRequestSheet()),
          const SizedBox(height: 20),
          Semantics(header: true, child: Text(l.findInterpreter, style: text.titleLarge)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(label: Text(l.allCategories), selected: _language == null, onSelected: (_) => setState(() => _language = null)),
            ChoiceChip(label: Text(l.langEnglish), selected: _language == 'en', onSelected: (_) => setState(() => _language = 'en')),
            ChoiceChip(label: Text(l.langHindi), selected: _language == 'hi', onSelected: (_) => setState(() => _language = 'hi')),
            ChoiceChip(label: Text(l.langKannada), selected: _language == 'kn', onSelected: (_) => setState(() => _language = 'kn')),
          ]),
          const SizedBox(height: 12),
          _InterpreterList(language: _language, onRequest: (i) => _openRequestSheet(interpreterId: i.id)),
        ],
      ]),
    );
  }
}

class _InterpreterList extends ConsumerWidget {
  const _InterpreterList({required this.language, required this.onRequest});
  final String? language;
  final void Function(Interpreter) onRequest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final async = ref.watch(interpretersProvider(language));
    return async.when(
      loading: () => const Padding(padding: EdgeInsets.all(32), child: LoadingState()),
      error: (e, _) => SizedBox(height: 260, child: ErrorState(failure: toFailure(e), onRetry: () => ref.invalidate(interpretersProvider(language)))),
      data: (list) {
        if (list.isEmpty) {
          return Padding(padding: const EdgeInsets.all(16), child: EmptyState(icon: Icons.people_outline_rounded, title: l.noInterpretersNow));
        }
        final sorted = [...list]..sort((a, b) => a.status.index.compareTo(b.status.index));
        return Column(children: [
          for (final i in sorted) ...[
            _InterpreterCard(interpreter: i, onRequest: () => onRequest(i)),
            const SizedBox(height: 10),
          ],
        ]);
      },
    );
  }
}

class _InterpreterCard extends StatelessWidget {
  const _InterpreterCard({required this.interpreter, required this.onRequest});
  final Interpreter interpreter;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (tone, icon) = interpreterStatusStyle(interpreter.status);
    final rating = interpreter.rating;
    return AppCard(
      semanticLabel: '${interpreter.name}. ${interpreterStatusLabel(l, interpreter.status)}',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ProfileAvatar(name: interpreter.name, photoUrl: interpreter.photoUrl, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(interpreter.name, style: Theme.of(context).textTheme.titleMedium),
              Text(
                rating == null ? l.noRatingsYet : l.ratingValue(rating.toStringAsFixed(1), '${interpreter.ratingCount}'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ]),
          ),
          Flexible(child: StatusBadge(label: interpreterStatusLabel(l, interpreter.status), tone: tone, icon: icon)),
        ]),
        if (interpreter.languages.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, children: [for (final lang in interpreter.languages) Chip(label: Text(lang.toUpperCase()), visualDensity: VisualDensity.compact)]),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton.tonal(onPressed: interpreter.isAvailable ? onRequest : null, child: Text(l.requestInterpreter)),
        ),
      ]),
    );
  }
}

class _RequestOptions {
  const _RequestOptions(this.mode, this.language, this.note);
  final CallMode mode;
  final String language;
  final String? note;
}

class _RequestSheet extends StatefulWidget {
  const _RequestSheet({required this.initialLanguage});
  final String initialLanguage;

  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  CallMode _mode = CallMode.video;
  late String _lang = widget.initialLanguage;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Text(l.requestInterpreter, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SegmentedButton<CallMode>(
            segments: [
              ButtonSegment(value: CallMode.video, icon: const Icon(Icons.videocam_rounded), label: Text(l.requestVideoCall)),
              ButtonSegment(value: CallMode.audio, icon: const Icon(Icons.call_rounded), label: Text(l.requestAudioCall)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(label: Text(l.langEnglish), selected: _lang == 'en', onSelected: (_) => setState(() => _lang = 'en')),
            ChoiceChip(label: Text(l.langHindi), selected: _lang == 'hi', onSelected: (_) => setState(() => _lang = 'hi')),
            ChoiceChip(label: Text(l.langKannada), selected: _lang == 'kn', onSelected: (_) => setState(() => _lang = 'kn')),
          ]),
          const SizedBox(height: 16),
          TextField(controller: _note, maxLines: 2, maxLength: 240, decoration: InputDecoration(labelText: l.noteOptional)),
          const SizedBox(height: 8),
          PrimaryButton(
            label: l.requestInterpreter,
            icon: _mode == CallMode.video ? Icons.videocam_rounded : Icons.call_rounded,
            onPressed: () => Navigator.pop(context, _RequestOptions(_mode, _lang, _note.text)),
          ),
        ]),
      ),
    );
  }
}
