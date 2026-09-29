import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/l10n_ext.dart';
import 'buttons.dart';
import 'cards.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.name, this.photoUrl, this.size = 44, this.semanticLabel});
  final String? name;
  final String? photoUrl;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = (name ?? '').trim().isEmpty ? null : name!.trim().characters.first.toUpperCase();
    return Semantics(
      image: true,
      label: semanticLabel ?? name,
      child: ExcludeSemantics(
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: scheme.primaryContainer,
          foregroundImage: (photoUrl != null && photoUrl!.isNotEmpty) ? NetworkImage(photoUrl!) : null,
          child: initial != null
              ? Text(initial,
                  style: TextStyle(
                      fontSize: size * 0.42, fontWeight: FontWeight.w700, color: scheme.onPrimaryContainer))
              : Icon(Icons.person_rounded, size: size * 0.55, color: scheme.onPrimaryContainer),
        ),
      ),
    );
  }
}

/// Explains *why* a permission is needed before the system prompt appears,
/// and offers a path to settings when permanently denied.
class PermissionCard extends StatelessWidget {
  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.explanation,
    required this.onGrant,
    this.permanentlyDenied = false,
    this.onOpenSettings,
  });

  final IconData icon;
  final String title;
  final String explanation;
  final VoidCallback onGrant;
  final bool permanentlyDenied;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.pageAll,
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: scheme.primary),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(explanation, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              if (permanentlyDenied)
                PrimaryButton(label: l.openSettings, icon: Icons.settings_rounded, onPressed: onOpenSettings)
              else
                PrimaryButton(label: l.grantPermission, icon: Icons.lock_open_rounded, onPressed: onGrant),
            ],
          ),
        ),
      ),
    );
  }
}
