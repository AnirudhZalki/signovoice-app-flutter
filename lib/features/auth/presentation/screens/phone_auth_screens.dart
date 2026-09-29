import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../domain/app_user.dart';
import '../auth_controller.dart';
import '../auth_helpers.dart';

/// Arguments passed from [PhoneAuthScreen] to [OtpScreen] via GoRouter `extra`.
class OtpArgs {
  const OtpArgs({required this.phone, required this.verification});
  final String phone;
  final PhoneVerification verification;
}

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final phone = Validators.normalizePhone(_phone.text);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final v = await ref.read(authRepositoryProvider).startPhoneVerification(phone);
      if (!mounted) return;
      if (v.autoSignedIn) return; // auth stream will redirect
      context.push(Routes.otp, extra: OtpArgs(phone: phone, verification: v));
    } catch (e) {
      if (mounted) setState(() => _error = authFailureMessage(context.l10n, toFailure(e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.phoneTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.phoneBody, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: InputDecoration(
                    labelText: l.phoneNumber,
                    hintText: '+91 98765 43210',
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => validationText(l, Validators.phone(v)),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                  ]),
                ],
                const SizedBox(height: 20),
                PrimaryButton(label: l.sendCode, loading: _busy, onPressed: _send),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.args});
  final OtpArgs args;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _cooldown = 45;
  final _code = TextEditingController();
  final _form = GlobalKey<FormState>();
  late PhoneVerification _verification = widget.args.verification;
  Timer? _timer;
  int _seconds = _cooldown;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
      }
      if (mounted) setState(() => _seconds = (_seconds - 1).clamp(0, _cooldown));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).confirmOtp(_verification.verificationId!, _code.text);
      if (mounted) {
        // Session stage redirect takes over; unwind the phone flow.
        while (context.canPop()) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = authFailureMessage(context.l10n, toFailure(e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _error = null);
    try {
      final v = await ref
          .read(authRepositoryProvider)
          .startPhoneVerification(widget.args.phone, resendToken: _verification.resendToken);
      if (!mounted) return;
      setState(() => _verification = v.verificationId == null ? _verification : v);
      _startTimer();
    } catch (e) {
      if (mounted) setState(() => _error = authFailureMessage(context.l10n, toFailure(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.otpTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.otpSentTo(widget.args.phone), style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: 8),
                  decoration: InputDecoration(labelText: l.otpTitle, counterText: ''),
                  validator: (v) => validationText(l, Validators.otp(v)),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Semantics(
                    liveRegion: true,
                    child: Row(children: [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                PrimaryButton(label: l.verifyCode, loading: _busy, onPressed: _verify),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _seconds == 0 ? _resend : null,
                  child: Text(_seconds == 0 ? l.resendCode : l.resendIn('$_seconds')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
