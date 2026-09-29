import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../sign_translation/presentation/widgets/voice_settings_sheet.dart';

class VoiceSettingsScreen extends StatelessWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.settingsVoice)),
        body: const VoiceSettingsSheet(),
      );
}
