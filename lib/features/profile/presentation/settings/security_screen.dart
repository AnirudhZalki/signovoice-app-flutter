import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/failure_message.dart';
import '../../../auth/presentation/auth_controller.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  String? _message;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final email = auth.user?.email;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsSecurity)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (auth.isGuest) ...[
          Text(l.securityGuest),
          const SizedBox(height: 16),
          PrimaryButton(label: l.createAccountAction, onPressed: () => ref.read(authControllerProvider.notifier).leaveGuestMode()),
        ] else ...[
          Text(l.securitySignedInAs(email ?? auth.user?.phone ?? l.appName), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          if (email != null)
            SecondaryButton(
              label: l.securityChangePassword,
              icon: Icons.password_rounded,
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() {
                        _busy = true;
                        _message = null;
                      });
                      try {
                        await ref.read(authRepositoryProvider).sendPasswordReset(email);
                        if (mounted) setState(() => _message = l.securityPasswordSent);
                      } catch (e) {
                        if (mounted) setState(() => _message = failureMessage(l, toFailure(e)));
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
            ),
          if (_message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Semantics(liveRegion: true, child: Text(_message!))),
        ],
      ]),
    );
  }
}
