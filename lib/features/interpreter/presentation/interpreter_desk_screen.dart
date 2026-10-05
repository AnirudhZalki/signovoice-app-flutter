import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure_mapper.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/failure_message.dart';
import '../domain/interpreter_models.dart';
import 'call_controller.dart';
import 'money.dart';
import 'interpreter_providers.dart';

/// For approved interpreters: go online, see waiting requests, accept one and join its room.
class InterpreterDeskScreen extends ConsumerStatefulWidget {
  const InterpreterDeskScreen({super.key});

  @override
  ConsumerState<InterpreterDeskScreen> createState() => _InterpreterDeskScreenState();
}

class _InterpreterDeskScreenState extends ConsumerState<InterpreterDeskScreen> {
  bool? _online;
  bool _busy = false;
  String? _error;

  Future<void> _setOnline(bool v) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(interpreterRepositoryProvider).setAvailability(available: v);
      if (mounted) setState(() => _online = v);
    } catch (e) {
      if (mounted) setState(() => _error = failureMessageWithReason(context.l10n, toFailure(e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline(IncomingRequest r) async {
    try {
      await ref.read(interpreterRepositoryProvider).decline(r.requestId);
    } catch (e) {
      if (mounted) setState(() => _error = failureMessageWithReason(context.l10n, toFailure(e)));
    }
    ref.invalidate(interpreterQueueProvider);
  }

  Future<void> _accept(IncomingRequest r) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await ref.read(interpreterRepositoryProvider).accept(r.requestId);
      if (!mounted) return;
      ref.read(callControllerProvider.notifier)
        ..reset()
        ..joinAsInterpreter(session, r.mode);
      context.push(Routes.interpreterCall);
    } catch (e) {
      if (mounted) setState(() => _error = failureMessageWithReason(context.l10n, toFailure(e)));
      ref.invalidate(interpreterQueueProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final me = ref.watch(interpreterMeProvider);
    final queue = ref.watch(interpreterQueueProvider);
    final online = _online ?? (me.value?.status == InterpreterStatus.available || me.value?.status == InterpreterStatus.busy);

    return Scaffold(
      appBar: AppBar(title: Text(l.deskTitle)),
      body: me.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l.deskNotInterpreter)),
        data: (m) {
          if (!m.approved) return Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l.deskNotInterpreter, textAlign: TextAlign.center)));
          return ListView(padding: const EdgeInsets.all(16), children: [
            AppCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(online ? l.deskOnline : l.deskOffline, style: text.titleMedium),
                subtitle: Text(l.deskOnlineHint),
                value: online,
                onChanged: _busy ? null : _setOnline,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              onTap: () => context.push(Routes.interpreterProfile),
              child: Row(children: [
                const Icon(Icons.payments_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${l.deskRate}: ${m.ratePaise > 0 ? formatPaise(l, m.ratePaise) : l.priceFree}', style: text.titleMedium),
                    Text(l.deskEarnings(formatPaiseRaw(m.earningsPaise)), style: text.bodySmall),
                    Text(l.deskEditProfile, style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded),
              ]),
            ),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Semantics(liveRegion: true, child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)))),
            const SizedBox(height: 16),
            Semantics(header: true, child: Text(l.deskQueue, style: text.titleMedium)),
            const SizedBox(height: 8),
            if (!online)
              Text(l.deskGoOnline)
            else
              queue.when(
                loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text(failureMessageWithReason(l, toFailure(e))),
                data: (items) => items.isEmpty
                    ? Text(l.deskEmpty)
                    : Column(children: [
                        for (final r in items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Icon(r.mode == CallMode.video ? Icons.videocam_rounded : Icons.call_rounded),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(r.name.isEmpty ? l.deskSomeone : r.name, style: text.titleMedium)),
                                  Text(r.language.toUpperCase()),
                                ]),
                                if (r.note != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(r.note!)),
                                const SizedBox(height: 4),
                                Text(l.deskWaiting('${r.waitingSeconds}'), style: text.bodySmall),
                                if (r.amountPaise > 0) Text(l.deskYouEarn(formatPaiseRaw(r.earnPaise)), style: text.titleSmall),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Expanded(child: FilledButton(onPressed: _busy ? null : () => _accept(r), child: Text(l.deskAccept))),
                                  if (r.directed) ...[
                                    const SizedBox(width: 8),
                                    OutlinedButton(onPressed: _busy ? null : () => _decline(r), child: Text(l.deskDecline)),
                                  ],
                                ]),
                              ]),
                            ),
                          ),
                      ]),
              ),
          ]);
        },
      ),
    );
  }
}
