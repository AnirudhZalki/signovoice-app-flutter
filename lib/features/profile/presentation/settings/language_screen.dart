import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../preferences_controller.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final prefs = ref.watch(preferencesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsLanguage)),
      body: RadioGroup<String?>(
        groupValue: prefs.localeCode,
        onChanged: (code) => ref.read(preferencesProvider.notifier).update((p) => p.copyWith(localeCode: code, clearLocale: code == null)),
        child: ListView(children: [
          RadioListTile<String?>(value: null, title: Text(l.langSystem)),
          RadioListTile<String?>(value: 'en', title: Text(l.langEnglish)),
          RadioListTile<String?>(value: 'hi', title: Text(l.langHindi)),
          RadioListTile<String?>(value: 'kn', title: Text(l.langKannada)),
        ]),
      ),
    );
  }
}
