import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/brand.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/cards.dart';
import '../auth_controller.dart';
import '../auth_helpers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      final f = toFailure(e);
      if (mounted && f.type != FailureType.cancelled) {
        setState(() => _error = authFailureMessage(context.l10n, f));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final supportsAccounts = ref.watch(authRepositoryProvider).supportsAccounts;
    final auth = ref.read(authControllerProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BrandMark()),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(l.loginTitle,
                        style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 8),
                  Text(l.loginSubtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  if (!supportsAccounts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AppCard(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        child: Row(children: [
                          const Icon(Icons.info_outline),
                          const SizedBox(width: 12),
                          Expanded(child: Text(l.backendMissingBanner)),
                        ]),
                      ),
                    ),
                  if (supportsAccounts) ...[
                    Form(
                      key: _form,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(labelText: l.email, prefixIcon: const Icon(Icons.email_outlined)),
                            validator: (v) => validationText(l, Validators.email(v)),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: l.password,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscure ? l.showPassword : l.hidePassword,
                                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v ?? '').isEmpty ? l.validationRequired : null,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(onPressed: () => context.push(Routes.forgotPassword), child: Text(l.forgotPassword)),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Semantics(
                          liveRegion: true,
                          child: Row(children: [
                            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(_error!,
                                    style: TextStyle(color: Theme.of(context).colorScheme.error))),
                          ]),
                        ),
                      ),
                    PrimaryButton(
                      label: l.signIn,
                      loading: _busy,
                      onPressed: () {
                        if (_form.currentState!.validate()) {
                          _run(() => auth.signInWithEmail(_email.text, _password.text));
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(l.orDivider)),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 16),
                    SecondaryButton(
                        label: l.continueWithGoogle,
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: _busy ? null : () => _run(auth.signInWithGoogle)),
                    const SizedBox(height: 12),
                    SecondaryButton(
                        label: l.continueWithPhone,
                        icon: Icons.phone_android_rounded,
                        onPressed: _busy ? null : () => context.push(Routes.phone)),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => context.push(Routes.register), child: Text(l.noAccount)),
                    const Divider(height: 32),
                  ],
                  Text(l.guestNote, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  supportsAccounts
                      ? SecondaryButton(
                          label: l.continueAsGuest, icon: Icons.person_outline_rounded, onPressed: () => auth.continueAsGuest())
                      : PrimaryButton(
                          label: l.continueAsGuest, icon: Icons.person_outline_rounded, onPressed: () => auth.continueAsGuest()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
