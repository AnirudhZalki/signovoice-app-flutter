import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure_mapper.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/failure_message.dart';
import '../../auth/presentation/auth_controller.dart';
import 'interpreter_providers.dart';

/// Register as an interpreter or edit the profile and rate. New profiles wait for approval.
class InterpreterProfileScreen extends ConsumerStatefulWidget {
  const InterpreterProfileScreen({super.key});

  @override
  ConsumerState<InterpreterProfileScreen> createState() => _InterpreterProfileScreenState();
}

class _InterpreterProfileScreenState extends ConsumerState<InterpreterProfileScreen> {
  final _name = TextEditingController();
  final _rate = TextEditingController(text: '0');
  final _bio = TextEditingController();
  final _langs = <String>{};
  bool _loaded = false;
  bool _busy = false;
  String? _error;
  String? _rateError;
  String? _langError;

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _prefill() {
    if (_loaded) return;
    final me = ref.read(interpreterMeProvider).value;
    final user = ref.read(authControllerProvider).user;
    _name.text = (me != null && me.name.isNotEmpty) ? me.name : (user?.displayName ?? '');
    if (me != null && me.applied) {
      _rate.text = '${me.ratePaise ~/ 100}';
      _bio.text = me.bio;
      _langs.addAll(me.languages);
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final l = context.l10n;
    final rupees = int.tryParse(_rate.text.trim());
    setState(() {
      _error = null;
      _rateError = (rupees == null || rupees < 0 || rupees > 5000) ? l.profileInvalidRate : null;
      _langError = _langs.isEmpty ? l.profilePickLanguage : null;
    });
    if (_rateError != null || _langError != null || _name.text.trim().length < 2) {
      if (_name.text.trim().length < 2) setState(() => _error = l.validationRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(interpreterRepositoryProvider).saveProfile(
            name: _name.text.trim(),
            languages: _langs.toList()..sort(),
            ratePaise: rupees! * 100,
            bio: _bio.text,
          );
      ref.invalidate(interpreterMeProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.profileSaved)));
      context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = failureMessageWithReason(l, toFailure(e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    ref.watch(interpreterMeProvider); // load existing profile first
    _prefill();
    final langs = {'en': l.langEnglish, 'hi': l.langHindi, 'kn': l.langKannada};
    return Scaffold(
      appBar: AppBar(title: Text(l.interpreterProfileTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _name, maxLength: 60, decoration: InputDecoration(labelText: l.profileName, prefixIcon: const Icon(Icons.person_outline))),
        const SizedBox(height: 8),
        Semantics(header: true, child: Text(l.profileLanguages, style: Theme.of(context).textTheme.titleSmall)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in langs.entries)
            FilterChip(
              label: Text(e.value),
              selected: _langs.contains(e.key),
              onSelected: (v) => setState(() => v ? _langs.add(e.key) : _langs.remove(e.key)),
            ),
        ]),
        if (_langError != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_langError!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 16),
        TextField(
          controller: _rate,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l.profileRate('30'), prefixText: '₹ ', errorText: _rateError, helperText: l.profileRateHint, helperMaxLines: 3),
        ),
        const SizedBox(height: 16),
        TextField(controller: _bio, maxLength: 300, maxLines: 3, decoration: InputDecoration(labelText: l.profileBio)),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Semantics(liveRegion: true, child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)))),
        const SizedBox(height: 16),
        PrimaryButton(label: l.profileSave, loading: _busy, onPressed: _busy ? null : _save),
      ]),
    );
  }
}
