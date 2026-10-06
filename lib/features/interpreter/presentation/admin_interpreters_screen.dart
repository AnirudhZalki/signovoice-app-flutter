import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure_mapper.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/failure_message.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../domain/interpreter_models.dart';
import 'interpreter_providers.dart';
import 'money.dart';

final _adminListProvider = FutureProvider.autoDispose.family<List<AdminInterpreter>, String>(
  (ref, filter) => ref.watch(interpreterRepositoryProvider).adminInterpreters(filter: filter),
);

/// Admin only (the server enforces it): review interpreter applications, approve or revoke.
class AdminInterpretersScreen extends ConsumerStatefulWidget {
  const AdminInterpretersScreen({super.key});

  @override
  ConsumerState<AdminInterpretersScreen> createState() => _AdminInterpretersScreenState();
}

class _AdminInterpretersScreenState extends ConsumerState<AdminInterpretersScreen> {
  String? _busyUid;
  String? _error;

  Future<void> _set(AdminInterpreter i, bool approved) async {
    setState(() {
      _busyUid = i.uid;
      _error = null;
    });
    try {
      await ref.read(interpreterRepositoryProvider).adminSetApproved(i.uid, approved: approved);
      ref.invalidate(_adminListProvider);
      ref.invalidate(interpretersProvider);
    } catch (e) {
      if (mounted) setState(() => _error = failureMessageWithReason(context.l10n, toFailure(e)));
    } finally {
      if (mounted) setState(() => _busyUid = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isAdmin = ref.watch(isAdminProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.adminTitle),
          bottom: TabBar(tabs: [Tab(text: l.adminPending), Tab(text: l.adminApproved)]),
        ),
        body: isAdmin.when(
          loading: () => const LoadingState(),
          error: (_, _) => Center(child: Text(l.adminNotAllowed)),
          data: (ok) => !ok
              ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l.adminNotAllowed, textAlign: TextAlign.center)))
              : Column(children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Semantics(liveRegion: true, child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                    ),
                  Expanded(child: TabBarView(children: [_list('pending'), _list('approved')])),
                ]),
        ),
      ),
    );
  }

  Widget _list(String filter) {
    final l = context.l10n;
    final async = ref.watch(_adminListProvider(filter));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_adminListProvider(filter)),
      child: async.when(
        loading: () => const LoadingState(),
        error: (e, _) => ListView(children: [Padding(padding: const EdgeInsets.all(16), child: Text(failureMessageWithReason(l, toFailure(e))))]),
        data: (items) => items.isEmpty
            ? ListView(children: [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(filter == 'pending' ? l.adminNonePending : l.adminNoneApproved)))])
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, k) => _tile(items[k]),
              ),
      ),
    );
  }

  Widget _tile(AdminInterpreter i) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final busy = _busyUid == i.uid;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(i.name.isEmpty ? i.uid : i.name, style: text.titleMedium),
        if (i.email.isNotEmpty) Text(i.email, style: text.bodySmall),
        const SizedBox(height: 6),
        Wrap(spacing: 6, children: [
          for (final lang in i.languages) Chip(label: Text(lang.toUpperCase()), visualDensity: VisualDensity.compact),
        ]),
        Text('${l.deskRate}: ${i.ratePaise > 0 ? formatPaise(l, i.ratePaise) : l.priceFree}', style: text.bodyMedium),
        if (i.bio.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(i.bio)),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: i.approved
              ? OutlinedButton(onPressed: busy ? null : () => _set(i, false), child: Text(l.adminRevoke))
              : FilledButton(onPressed: busy ? null : () => _set(i, true), child: Text(l.adminApprove)),
        ),
      ]),
    );
  }
}
