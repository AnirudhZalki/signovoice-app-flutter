import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/failure_message.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../data/account_service.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _confirmed = false;
  bool _busy = false;
  Failure? _failure;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await ref.read(accountServiceProvider).deleteAccount();
      // Auth state change redirects to the login screen.
    } catch (e) {
      if (mounted) setState(() => _failure = toFailure(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final auth = ref.watch(authControllerProvider);
    final recent = _failure?.type == FailureType.requiresRecentLogin;
    return Scaffold(
      appBar: AppBar(title: Text(l.deleteTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Icon(Icons.warning_amber_rounded, size: 56, color: scheme.error),
        const SizedBox(height: 12),
        Text(auth.isSignedIn ? l.deleteBody : l.deleteGuestBody, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _confirmed,
          onChanged: _busy ? null : (v) => setState(() => _confirmed = v ?? false),
          title: Text(l.deleteConfirmCheck),
        ),
        if (_failure != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Semantics(
              liveRegion: true,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.error_outline, color: scheme.error),
                const SizedBox(width: 8),
                Expanded(child: Text(recent ? l.deleteRecentLogin : failureMessage(l, _failure!), style: TextStyle(color: scheme.error))),
              ]),
            ),
          ),
        if (recent)
          SecondaryButton(label: l.deleteAndSignOut, onPressed: () => ref.read(accountServiceProvider).signOut())
        else
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
            onPressed: _confirmed && !_busy ? _delete : null,
            child: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)) : Text(l.deleteAction),
          ),
        const SizedBox(height: 8),
        TextButton(onPressed: _busy ? null : () => context.pop(), child: Text(l.cancel)),
      ]),
    );
  }
}
