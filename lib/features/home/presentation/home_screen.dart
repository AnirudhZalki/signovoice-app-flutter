import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/misc_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/presentation/profile_controller.dart';

String greetingFor(AppLocalizations l, DateTime now) => switch (dayPartOf(now)) {
      DayPart.morning => l.greetingMorning,
      DayPart.afternoon => l.greetingAfternoon,
      DayPart.evening => l.greetingEvening,
    };

class QuickAction {
  const QuickAction(this.icon, this.title, this.subtitle, this.route, this.color);
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
}

List<QuickAction> quickActions(BuildContext context) {
  final l = context.l10n;
  final scheme = Theme.of(context).colorScheme;
  return [
    QuickAction(Icons.sign_language_rounded, l.modeSignToText, l.qaSignToTextSub, Routes.signToText, scheme.primary),
    QuickAction(Icons.mic_rounded, l.modeVoiceToSign, l.qaVoiceToSignSub, Routes.voiceToSign, scheme.secondary),
    QuickAction(Icons.volume_up_rounded, l.modeSignToVoice, l.qaSignToVoiceSub, Routes.signToVoice, scheme.primary),
    QuickAction(Icons.video_call_rounded, l.modeInterpreter, l.qaInterpreterSub, Routes.live, scheme.secondary),
    QuickAction(Icons.school_rounded, l.navLearn, l.qaLearnSub, Routes.learn, scheme.primary),
    QuickAction(Icons.fitness_center_rounded, l.practiceTitle, l.qaPracticeSub, Routes.practiceHub, scheme.secondary),
  ];
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final profile = ref.watch(profileProvider).value;
    final auth = ref.watch(authControllerProvider);
    final name = (profile?.displayName.isNotEmpty ?? false) ? profile!.displayName : auth.user?.displayName ?? '';
    final now = ref.watch(clockProvider)();
    final greeting = greetingFor(l, now);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final actions = quickActions(context);
    final wide = MediaQuery.textScalerOf(context).scale(16) < 24; // 2 columns unless text is very large

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Semantics(
                  button: true,
                  label: l.openProfileTooltip,
                  child: InkResponse(
                    onTap: () => context.go(Routes.profile),
                    radius: 28,
                    child: ProfileAvatar(name: name, photoUrl: profile?.photoUrl ?? auth.user?.photoUrl, size: 48),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      name.isEmpty ? greeting : l.greetingWithName(greeting, name),
                      style: text.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l.notificationsTooltip,
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () => context.push(Routes.notifications),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _HeroCard(onStart: () => context.push(Routes.signToText)),
            const SizedBox(height: 8),
            SectionHeader(title: l.quickActions),
            GridView.count(
              crossAxisCount: wide ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: wide ? 1.05 : 2.6,
              children: [
                for (final a in actions)
                  FeatureCard(
                    icon: a.icon,
                    title: a.title,
                    subtitle: a.subtitle,
                    accent: a.color,
                    onTap: () => (a.route == Routes.live || a.route == Routes.learn)
                        ? context.go(a.route)
                        : context.push(a.route),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md, child: ColoredBox(color: scheme.surface)),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.coreIdea,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onPrimary.withValues(alpha: 0.85))),
            const SizedBox(height: 8),
            Text(l.heroTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: scheme.onPrimary)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onStart,
              style: FilledButton.styleFrom(backgroundColor: scheme.onPrimary, foregroundColor: scheme.primary),
              icon: const Icon(Icons.sign_language_rounded),
              label: Text(l.heroCta),
            ),
          ],
        ),
      ),
    );
  }
}
