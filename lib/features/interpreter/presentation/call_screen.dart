import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure.dart';
import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/misc_widgets.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../domain/interpreter_models.dart';
import 'call_controller.dart';
import 'interpreter_providers.dart';

String formatDuration(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  return h > 0 ? '$h:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}' : '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
}

class CallScreen extends ConsumerWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(callControllerProvider);
    final ctrl = ref.read(callControllerProvider.notifier);

    ref.listen(callControllerProvider.select((v) => v.phase), (prev, next) {
      if (next == CallPhase.ended && (ref.read(callControllerProvider).callId == 'dev' || ref.read(callControllerProvider).interpreterSide)) {
        ref.read(callControllerProvider.notifier).reset(); // test room: nothing to rate
        context.pop();
      } else if (next == CallPhase.ended && ref.read(callControllerProvider).callId != null) {
        context.pushReplacement(Routes.interpreterFeedback, extra: ref.read(callControllerProvider).callId);
      }
    });

    return PopScope(
      canPop: !s.inCall, // leaving an active call must be explicit (End call)
      child: Scaffold(
        backgroundColor: s.inCall ? Colors.black : null,
        appBar: s.inCall ? null : AppBar(title: Text(l.liveTitle)),
        body: SafeArea(child: _body(context, ref, s, ctrl)),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, CallState s, CallController ctrl) {
    final l = context.l10n;
    switch (s.phase) {
      case CallPhase.idle:
      case CallPhase.requesting:
        return _Centered(icon: null, title: l.callRequesting, action: null);
      case CallPhase.waiting:
        return _Centered(
          icon: null,
          title: l.callWaiting,
          subtitle: s.queuePosition == null ? null : l.callQueue('${s.queuePosition}'),
          action: SecondaryButton(
            label: l.cancelRequest,
            icon: Icons.close_rounded,
            expanded: false,
            onPressed: () async {
              await ctrl.cancelRequest();
              if (context.mounted) context.pop();
            },
          ),
        );
      case CallPhase.connecting:
        return _Centered(icon: null, title: l.callConnecting, action: null);
      case CallPhase.connected:
      case CallPhase.reconnecting:
        return _InCall(state: s, controller: ctrl);
      case CallPhase.ended:
        return _Centered(icon: Icons.call_end_rounded, title: l.callEnded, action: null, busy: false);
      case CallPhase.failed:
        return _Failed(state: s, controller: ctrl);
    }
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.icon, required this.title, this.subtitle, required this.action, this.busy = true});
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool busy;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Semantics(
            liveRegion: true,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (busy) const CircularProgressIndicator() else Icon(icon, size: 56),
              const SizedBox(height: 20),
              Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!, textAlign: TextAlign.center)],
              if (action != null) ...[const SizedBox(height: 24), action!],
            ]),
          ),
        ),
      );
}

class _Failed extends ConsumerWidget {
  const _Failed({required this.state, required this.controller});
  final CallState state;
  final CallController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final f = state.failure ?? const Failure(FailureType.unknown);
    final reasonText = switch (state.failureReason) {
      RequestStatus.declined => l.callDeclined,
      RequestStatus.expired => l.callExpired,
      _ => null,
    };
    if (reasonText != null) {
      return _Centered(
        icon: Icons.person_off_outlined,
        title: l.callFailedTitle,
        subtitle: reasonText,
        busy: false,
        action: PrimaryButton(label: l.retry, expanded: false, onPressed: () {
          controller.reset();
          context.pop();
        }),
      );
    }
    if (f.type == FailureType.permissionPermanentlyDenied) {
      return PermissionCard(
        icon: Icons.mic_off_outlined,
        title: l.micPermTitle,
        explanation: l.failurePermissionPermanent,
        permanentlyDenied: true,
        onGrant: () {},
        onOpenSettings: ref.read(permissionServiceProvider).openSettings,
      );
    }
    return ErrorState(
      failure: f,
      onRetry: () {
        controller.reset();
        context.pop();
      },
    );
  }
}

class _InCall extends ConsumerStatefulWidget {
  const _InCall({required this.state, required this.controller});
  final CallState state;
  final CallController controller;

  @override
  ConsumerState<_InCall> createState() => _InCallState();
}

class _InCallState extends ConsumerState<_InCall> {
  Future<void> _openChat() async {
    widget.controller.setChatOpen(true);
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const _ChatSheet());
    widget.controller.setChatOpen(false);
  }

  Future<void> _openReport() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ReportIssueSheet(callId: widget.state.callId),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.state;
    final c = widget.controller;
    final service = c.service;
    final reconnecting = s.phase == CallPhase.reconnecting;
    final remote = service?.remoteView();
    final local = s.mode == CallMode.video && s.camOn ? service?.localView() : null;

    return Stack(fit: StackFit.expand, children: [
      if (remote != null)
        Semantics(label: s.interpreterName ?? l.modeInterpreter, child: remote)
      else
        Container(
          color: const Color(0xFF0B1020),
          alignment: Alignment.center,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ProfileAvatar(name: s.interpreterName, size: 96),
            const SizedBox(height: 16),
            Text(s.mode == CallMode.audio ? l.audioCallActive : l.waitingForVideo, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ]),
        ),
      Positioned(
        top: 12,
        left: 12,
        right: 12,
        child: Row(children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.all(2),
              child: StatusBadge(
                label: reconnecting ? l.callReconnecting : l.callConnected,
                tone: reconnecting ? StatusTone.warning : StatusTone.success,
                icon: reconnecting ? Icons.sync_problem_rounded : Icons.wifi_rounded,
              ),
            ),
          ),
          const Spacer(),
          Semantics(
            label: l.callDuration(formatDuration(s.elapsed)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(999)),
              child: Text(formatDuration(s.elapsed), style: const TextStyle(color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
            ),
          ),
        ]),
      ),
      if (s.interpreterName != null)
        Positioned(
          top: 56,
          left: 16,
          child: Text(l.interpreterConnectedTo(s.interpreterName!), style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4)])),
        ),
      if (local != null)
        Positioned(
          right: 16,
          bottom: 130,
          width: 104,
          height: 148,
          child: ClipRRect(borderRadius: BorderRadius.circular(16), child: local),
        ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 20,
        child: Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 10, children: [
          _CallButton(icon: s.micOn ? Icons.mic_rounded : Icons.mic_off_rounded, label: s.micOn ? l.muteMic : l.unmuteMic, active: !s.micOn, onPressed: c.toggleMic),
          if (s.mode == CallMode.video) ...[
            _CallButton(icon: s.camOn ? Icons.videocam_rounded : Icons.videocam_off_rounded, label: s.camOn ? l.cameraOffAction : l.cameraOnAction, active: !s.camOn, onPressed: c.toggleCamera),
            _CallButton(icon: Icons.flip_camera_android_rounded, label: l.flipCamera, onPressed: c.switchCamera),
          ],
          _CallButton(icon: Icons.chat_bubble_outline_rounded, label: l.chatTitle, badge: s.unread, onPressed: _openChat),
          _CallButton(icon: Icons.flag_outlined, label: l.reportIssue, onPressed: _openReport),
          _CallButton(icon: Icons.call_end_rounded, label: l.endCall, danger: true, onPressed: c.end),
        ]),
      ),
    ]);
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.icon, required this.label, required this.onPressed, this.active = false, this.danger = false, this.badge = 0});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;
  final bool danger;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final bg = danger ? const Color(0xFFD92D20) : (active ? Colors.white : Colors.white24);
    final fg = danger ? Colors.white : (active ? Colors.black : Colors.white);
    return Semantics(
      button: true,
      label: badge > 0 ? '$label, $badge' : label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Stack(clipBehavior: Clip.none, children: [
          IconButton.filled(
            onPressed: onPressed,
            icon: Icon(icon, size: 28),
            style: IconButton.styleFrom(backgroundColor: bg, foregroundColor: fg, minimumSize: const Size(60, 60)),
          ),
          if (badge > 0)
            Positioned(
              right: -2,
              top: -2,
              child: CircleAvatar(radius: 10, backgroundColor: Colors.redAccent, child: Text('$badge', style: const TextStyle(fontSize: 11, color: Colors.white))),
            ),
        ]),
      ),
    );
  }
}

class _ChatSheet extends ConsumerStatefulWidget {
  const _ChatSheet();

  @override
  ConsumerState<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends ConsumerState<_ChatSheet> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final msgs = ref.watch(callControllerProvider.select((s) => s.messages));
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(children: [
          Text(l.chatTitle, style: Theme.of(context).textTheme.titleLarge),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final m = msgs[msgs.length - 1 - i];
                return Align(
                  alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
                    decoration: BoxDecoration(
                      color: m.fromMe ? scheme.primaryContainer : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _c,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(hintText: l.chatHint),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(tooltip: l.sendMessage, icon: const Icon(Icons.send_rounded), onPressed: _send),
            ]),
          ),
        ]),
      ),
    );
  }

  void _send() {
    final t = _c.text;
    if (t.trim().isEmpty) return;
    ref.read(callControllerProvider.notifier).sendChat(t);
    _c.clear();
  }
}

/// Report a problem with a call (audio / video / interpreter / connection / other).
class ReportIssueSheet extends ConsumerStatefulWidget {
  const ReportIssueSheet({super.key, required this.callId});
  final String? callId;

  @override
  ConsumerState<ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends ConsumerState<ReportIssueSheet> {
  IssueCategory _cat = IssueCategory.other;
  final _details = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  Failure? _failure;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final id = widget.callId;
    if (id == null) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await ref.read(interpreterRepositoryProvider).reportIssue(callId: id, category: _cat, details: _details.text);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _failure = e is Failure ? e : const Failure(FailureType.unknown));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final labels = {
      IssueCategory.audio: l.issueAudio,
      IssueCategory.video: l.issueVideo,
      IssueCategory.interpreter: l.issueInterpreter,
      IssueCategory.connection: l.issueConnection,
      IssueCategory.other: l.issueOther,
    };
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Text(l.reportIssue, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (_sent)
            Semantics(liveRegion: true, child: Row(children: [const Icon(Icons.check_circle_outline), const SizedBox(width: 8), Expanded(child: Text(l.issueSent))]))
          else ...[
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in labels.entries) ChoiceChip(label: Text(e.value), selected: _cat == e.key, onSelected: (_) => setState(() => _cat = e.key)),
            ]),
            const SizedBox(height: 12),
            TextField(controller: _details, maxLines: 3, maxLength: 500, decoration: InputDecoration(labelText: l.issueDescribe)),
            if (_failure != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(l.failureUnknown, style: TextStyle(color: Theme.of(context).colorScheme.error))),
            PrimaryButton(label: l.reportIssue, loading: _busy, onPressed: widget.callId == null ? null : _submit),
          ],
        ]),
      ),
    );
  }
}
