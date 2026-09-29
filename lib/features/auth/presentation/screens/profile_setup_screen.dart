import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/misc_widgets.dart';
import '../../../profile/domain/user_preferences.dart';
import '../../../profile/domain/user_profile.dart';
import '../../../profile/presentation/preferences_controller.dart';
import '../../../profile/presentation/profile_controller.dart';
import '../auth_controller.dart';
import '../auth_helpers.dart';

String modeLabel(AppLocalizations l, CommunicationMode m) => switch (m) {
      CommunicationMode.signToText => l.modeSignToText,
      CommunicationMode.voiceToSign => l.modeVoiceToSign,
      CommunicationMode.signToVoice => l.modeSignToVoice,
      CommunicationMode.interpreter => l.modeInterpreter,
    };

String needLabel(AppLocalizations l, AccessibilityNeed n) => switch (n) {
      AccessibilityNeed.deaf => l.needDeaf,
      AccessibilityNeed.hardOfHearing => l.needHardOfHearing,
      AccessibilityNeed.speechDifference => l.needSpeech,
      AccessibilityNeed.lowVision => l.needLowVision,
      AccessibilityNeed.motor => l.needMotor,
    };

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key, this.editing = false});

  /// When true the screen edits an existing profile (opened from Profile).
  final bool editing;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  String _language = 'en';
  CommunicationMode _mode = CommunicationMode.signToText;
  final Set<AccessibilityNeed> _needs = {};
  String? _photoUrl;
  String? _localPhoto;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    final existing = ref.read(profileProvider).value;
    _name = TextEditingController(text: existing?.displayName ?? user?.displayName ?? '');
    _photoUrl = existing?.photoUrl ?? user?.photoUrl;
    if (existing != null) {
      _language = existing.preferredLanguage;
      _mode = existing.preferredMode;
      _needs.addAll(existing.accessibilityNeeds);
    } else {
      final code = ref.read(preferencesProvider).localeCode;
      if (code != null) _language = code;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
      if (x != null) setState(() => _localPhoto = x.path);
    } catch (_) {
      // Gallery unavailable/denied: profile photo is optional, ignore.
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = ref.read(authControllerProvider);
      final uid = auth.uid;
      var photo = _photoUrl;
      if (_localPhoto != null && auth.isSignedIn) {
        try {
          photo = await ref.read(userRepositoryProvider).uploadAvatar(uid, _localPhoto!);
        } catch (_) {
          // Photo upload is best-effort; continue without blocking setup.
        }
      }
      final name = _name.text.trim();
      final profile = UserProfile(
        uid: uid,
        displayName: name,
        photoUrl: photo,
        preferredLanguage: _language,
        preferredMode: _mode,
        accessibilityNeeds: {..._needs},
        createdAt: ref.read(profileProvider).value?.createdAt ?? DateTime.now(),
      );
      if (auth.isSignedIn) {
        await ref.read(authRepositoryProvider).updateProfile(displayName: name, photoUrl: photo);
      }
      await ref.read(profileProvider.notifier).save(profile);
      if (_needs.contains(AccessibilityNeed.lowVision) || _needs.contains(AccessibilityNeed.motor)) {
        await ref.read(preferencesProvider.notifier).update((p) => p.copyWith(
              textScale: _needs.contains(AccessibilityNeed.lowVision) ? 1.2 : p.textScale,
              highContrast: _needs.contains(AccessibilityNeed.lowVision) ? true : p.highContrast,
            ));
      }
      if (mounted && widget.editing && Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = authFailureMessage(context.l10n, toFailure(e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final languages = {'en': l.langEnglish, 'hi': l.langHindi, 'kn': l.langKannada};
    return Scaffold(
      appBar: AppBar(title: Text(l.profileSetupTitle), automaticallyImplyLeading: widget.editing),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.profileSetupSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                Center(
                  child: Column(children: [
                    ProfileAvatar(name: _name.text, photoUrl: _localPhoto == null ? _photoUrl : null, size: 96),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(_localPhoto != null || _photoUrl != null ? l.changePhoto : l.addPhoto),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l.fullName, prefixIcon: const Icon(Icons.person_outline)),
                  validator: (v) => validationText(l, Validators.name(v)),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                Text(l.preferredLanguage, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final e in languages.entries)
                    ChoiceChip(
                      label: Text(e.value),
                      selected: _language == e.key,
                      onSelected: (_) => setState(() => _language = e.key),
                    ),
                ]),
                const SizedBox(height: 20),
                Text(l.preferredMode, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final m in CommunicationMode.values)
                    ChoiceChip(
                      label: Text(modeLabel(l, m)),
                      selected: _mode == m,
                      onSelected: (_) => setState(() => _mode = m),
                    ),
                ]),
                const SizedBox(height: 20),
                Text(l.accessibilityOptional, style: Theme.of(context).textTheme.titleMedium),
                for (final n in AccessibilityNeed.values)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _needs.contains(n),
                    title: Text(needLabel(l, n)),
                    onChanged: (v) => setState(() => v == true ? _needs.add(n) : _needs.remove(n)),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                  ]),
                ],
                const SizedBox(height: 16),
                PrimaryButton(label: l.saveAndContinue, loading: _busy, onPressed: _save),
                if (!widget.editing) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy ? null : () => ref.read(profileProvider.notifier).skipSetup(),
                    child: Text(l.skipForNow),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
