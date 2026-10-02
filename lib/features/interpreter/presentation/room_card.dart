import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import '../domain/interpreter_models.dart';
import 'call_controller.dart';

/// Join a live interpretation room with a shared room code (token comes from the LiveKit token server).
class RoomCard extends ConsumerStatefulWidget {
  const RoomCard({super.key});

  @override
  ConsumerState<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends ConsumerState<RoomCard> {
  static final _valid = RegExp(r'^[A-Za-z0-9_-]{3,40}$');
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _join(CallMode mode) {
    final room = _code.text.trim();
    if (!_valid.hasMatch(room)) {
      setState(() => _error = context.l10n.roomCodeInvalid);
      return;
    }
    setState(() => _error = null);
    ref.read(callControllerProvider.notifier)
      ..reset()
      ..joinRoom(mode, room);
    context.push(Routes.interpreterCall);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.meeting_room_outlined),
            const SizedBox(width: 8),
            Expanded(child: Semantics(header: true, child: Text(l.roomTitle, style: text.titleMedium))),
          ]),
          const SizedBox(height: 6),
          Text(l.roomBody),
          const SizedBox(height: 12),
          TextField(
            controller: _code,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(labelText: l.roomCodeLabel, errorText: _error, prefixIcon: const Icon(Icons.tag_rounded)),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(icon: const Icon(Icons.videocam_rounded), label: Text(l.requestVideoCall), onPressed: () => _join(CallMode.video)),
            OutlinedButton.icon(icon: const Icon(Icons.call_rounded), label: Text(l.requestAudioCall), onPressed: () => _join(CallMode.audio)),
          ]),
        ]),
      ),
    );
  }
}
