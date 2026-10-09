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
import '../../history/presentation/history_controller.dart';
import '../../history/presentation/history_screen.dart';
import '../../notifications/presentation/notification_providers.dart';
import '../../sign_translation/presentation/widgets/translation_panel.dart' show shareText;
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
                Consumer(builder: (context, ref, _) {
                  final unread = ref.watch(unreadCountProvider);
                  return IconButton(
                    tooltip: unread > 0 ? '${l.notificationsTooltip}. ${l.unreadCount('$unread')}' : l.notificationsTooltip,
                    icon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                    onPressed: () => context.push(Routes.notifications),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            _HeroCard(onStart: () => context.push(Routes.signToText)),
            const SizedBox(height: 12),
            const _CommunityCard(),
            const SizedBox(height: 8),
            SectionHeader(title: l.navTranslate),
            _ActionGrid(columns: wide ? 2 : 1, children: [for (final a in actions.take(3)) _card(context, a)]),
            const SizedBox(height: 8),
            SectionHeader(title: l.homeMore),
            _ActionGrid(columns: wide ? 2 : 1, children: [for (final a in actions.skip(3)) _card(context, a)]),
            const SizedBox(height: 8),
            SectionHeader(title: l.recentActivity, actionLabel: l.seeAll, onAction: () => context.push(Routes.history)),
            _RecentActivity(ref: ref),
            SizedBox(height: AppSpacing.md, child: ColoredBox(color: scheme.surface)),
          ],
        ),
      ),
    );
  }
}

Widget _card(BuildContext context, QuickAction a) => FeatureCard(
      icon: a.icon,
      title: a.title,
      subtitle: a.subtitle,
      accent: a.color,
      onTap: () => (a.route == Routes.live || a.route == Routes.learn) ? context.go(a.route) : context.push(a.route),
    );

/// Says who the app is for and why it helps, instead of explaining what it is.
class _CommunityCard extends StatelessWidget {
  const _CommunityCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final benefits = [
      (Icons.record_voice_over_rounded, l.homeBenefit1Title, l.homeBenefit1Body),
      (Icons.hearing_rounded, l.homeBenefit2Title, l.homeBenefit2Body),
      (Icons.family_restroom_rounded, l.homeBenefit3Title, l.homeBenefit3Body),
      (Icons.lock_outline_rounded, l.homeBenefit4Title, l.homeBenefit4Body),
    ];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.favorite_rounded, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Semantics(header: true, child: Text(l.homeCommunityTitle, style: text.titleMedium))),
        ]),
        const SizedBox(height: 8),
        Text(l.homeCommunityBody),
        const SizedBox(height: 12),
        for (final b in benefits)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ExcludeSemantics(child: Icon(b.$1, size: 22, color: scheme.secondary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.$2, style: text.titleSmall),
                  Text(b.$3, style: text.bodySmall),
                ]),
              ),
            ]),
          ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => shareText(l.homeShareMessage),
            icon: const Icon(Icons.share_rounded),
            label: Text(l.homeShareCta),
          ),
        ),
      ]),
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


class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = (ref.watch(visibleHistoryProvider).value ?? const []).take(3).toList();
    if (items.isEmpty) {
      return AppCard(child: Row(children: [const Icon(Icons.history_rounded), const SizedBox(width: 10), Expanded(child: Text(l.noRecentActivity))]));
    }
    return Column(children: [
      for (final e in items) ...[
        AppCard(
          onTap: () => context.push(Routes.history),
          semanticLabel: '${historyTypeLabel(l, e.inputType)}. ${e.text}',
          child: Row(children: [
            Icon(historyTypeIcon(e.inputType)),
            const SizedBox(width: 10),
            Expanded(child: Text(e.text.isEmpty ? e.glosses.join(' ') : e.text, maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
        ),
        const SizedBox(height: 8),
      ],
    ]);
  }
}


/// Content-sized grid: rows stretch to the tallest card, so wrapped text or a
/// larger font never overflows (a fixed aspect ratio would).
class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.columns, required this.children});
  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final slice = children.skip(i).take(columns).toList();
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var j = 0; j < columns; j++) ...[
            if (j > 0) const SizedBox(width: 12),
            Expanded(child: j < slice.length ? slice[j] : const SizedBox.shrink()),
          ],
        ]),
      ));
      if (i + columns < children.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
}
