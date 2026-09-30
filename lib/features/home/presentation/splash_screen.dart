import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/brand.dart';

/// Animated intro: expanding "signal" rings, the logo popping in, then the four things the app
/// does fading in one by one. Honors the system "remove animations" setting.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2600);
  late final AnimationController _c = AnimationController(vsync: this, duration: _duration);
  Timer? _done;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _c.value = 1;
      _done = Timer(const Duration(milliseconds: 400), _finish);
    } else {
      _c.forward();
      _done = Timer(_duration + const Duration(milliseconds: 250), _finish);
    }
  }

  void _finish() {
    if (mounted) ref.read(introDoneProvider.notifier).finish();
  }

  @override
  void dispose() {
    _done?.cancel();
    _c.dispose();
    super.dispose();
  }

  Animation<double> _iv(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _c, curve: Interval(a, b, curve: curve));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final chips = [
      (Icons.sign_language_rounded, l.introSignToText),
      (Icons.mic_rounded, l.introVoiceToSign),
      (Icons.videocam_rounded, l.introLive),
      (Icons.school_rounded, l.introLearn),
    ];
    final logo = _iv(0.05, 0.4, Curves.easeOutBack);
    final title = _iv(0.35, 0.6);
    return Scaffold(
      body: Semantics(
        label: '${l.appName}. ${l.tagline}',
        child: ExcludeSemantics(
          child: Stack(fit: StackFit.expand, children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [scheme.primaryContainer, scheme.surface],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _c,
              builder: (_, _) => CustomPaint(painter: _RingsPainter(_c.value, AppColors.primary.withValues(alpha: 0.35))),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ScaleTransition(scale: logo, child: FadeTransition(opacity: _iv(0.05, 0.25), child: const BrandMark(size: 112))),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: title,
                    child: SlideTransition(
                      position: title.drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero)),
                      child: Column(children: [
                        Text(l.appName, style: text.displaySmall),
                        const SizedBox(height: 4),
                        Text(l.tagline, style: text.bodyLarge, textAlign: TextAlign.center),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
                      for (var i = 0; i < chips.length; i++)
                        _Pop(
                          animation: _iv(0.55 + i * 0.08, 0.75 + i * 0.08),
                          child: Chip(avatar: Icon(chips[i].$1, size: 18, color: scheme.primary), label: Text(chips[i].$2)),
                        ),
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Pop extends StatelessWidget {
  const _Pop({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: animation,
        child: SlideTransition(position: animation.drive(Tween(begin: const Offset(0, 0.6), end: Offset.zero)), child: child),
      );
}

/// Three staggered rings expanding from the logo, like a signal being sent.
class _RingsPainter extends CustomPainter {
  _RingsPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.36);
    final maxR = math.min(size.width, size.height) * 0.7;
    for (var i = 0; i < 3; i++) {
      final p = ((t * 1.6) - i * 0.22).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: color.a * (1 - p));
      canvas.drawCircle(center, 56 + maxR * Curves.easeOut.transform(p), paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.t != t;
}
