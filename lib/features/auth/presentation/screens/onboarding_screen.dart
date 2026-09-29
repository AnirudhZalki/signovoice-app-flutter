import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/routing/session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/brand.dart';
import '../../../../shared/widgets/buttons.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _icons = [
    Icons.diversity_3_rounded,
    Icons.sign_language_rounded,
    Icons.record_voice_over_rounded,
    Icons.school_rounded,
    Icons.video_call_rounded,
    Icons.privacy_tip_rounded,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingDoneProvider.notifier).complete();
    if (mounted) context.go(Routes.login);
  }

  void _next() {
    if (_index == _icons.length - 1) {
      _finish();
    } else {
      final reduce = MediaQuery.disableAnimationsOf(context);
      _controller.nextPage(
        duration: reduce ? Duration.zero : const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final titles = [l.onb1Title, l.onb2Title, l.onb3Title, l.onb4Title, l.onb5Title, l.onb6Title];
    final bodies = [l.onb1Body, l.onb2Body, l.onb3Body, l.onb4Body, l.onb5Body, l.onb6Body];
    final scheme = Theme.of(context).colorScheme;
    final last = _index == _icons.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  const BrandMark(size: 36),
                  const SizedBox(width: 10),
                  Text(l.appName, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  if (!last) TextButton(onPressed: _finish, child: Text(l.skip)),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _icons.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Semantics(
                    label: l.pageOf('${i + 1}', '${_icons.length}'),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
                              child: Icon(_icons[i], size: 84, color: scheme.onPrimaryContainer),
                            ),
                            const SizedBox(height: 32),
                            Semantics(
                              header: true,
                              child: Text(titles[i],
                                  style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                            ),
                            const SizedBox(height: 12),
                            Text(bodies[i], style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _icons.length; i++)
                  Container(
                    margin: const EdgeInsets.all(4),
                    width: i == _index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: i == _index ? scheme.primary : scheme.outline,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: AppSpacing.pageAll,
              child: PrimaryButton(label: last ? l.getStarted : l.next, onPressed: _next),
            ),
          ],
        ),
      ),
    );
  }
}
