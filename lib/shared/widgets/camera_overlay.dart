import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/sign_translation/data/hand_landmark_source.dart';

/// MediaPipe hand skeleton connections (21 landmarks).
const _connections = <(int, int)>[
  (0, 1), (1, 2), (2, 3), (3, 4),
  (0, 5), (5, 6), (6, 7), (7, 8),
  (5, 9), (9, 10), (10, 11), (11, 12),
  (9, 13), (13, 14), (14, 15), (15, 16),
  (13, 17), (17, 18), (18, 19), (19, 20),
  (0, 17),
];

/// Corner brackets, the tracked hand skeleton, and a scanning sweep while no
/// hand is visible. The sweep is replaced by a static hint when motion is
/// reduced. Everything is decorative (excluded from semantics); status is
/// conveyed in text elsewhere.
class CameraOverlay extends StatefulWidget {
  const CameraOverlay({super.key, required this.overlay, required this.scanning, required this.mirror});

  final ValueStreamOverlay? overlay;
  final bool scanning;

  /// Mirror x for front-camera previews (which Flutter mirrors).
  final bool mirror;

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = widget.overlay?.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant CameraOverlay old) {
    super.didUpdateWidget(old);
    if (old.overlay != widget.overlay) _listen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = widget.scanning && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_sweep.isAnimating) {
      _sweep.repeat(reverse: true);
    } else if (!animate && _sweep.isAnimating) {
      _sweep.stop();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final animate = widget.scanning && !reduce;
    if (animate != _sweep.isAnimating) {
      // keep the controller in step with prop changes between dependency changes
      animate ? _sweep.repeat(reverse: true) : _sweep.stop();
    }
    return ExcludeSemantics(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _sweep,
            builder: (context, _) => CustomPaint(
              size: Size.infinite,
              painter: _OverlayPainter(
                hands: widget.overlay?.hands ?? const [],
                mirror: widget.mirror,
                sweep: animate ? _sweep.value : null,
                bracketColor: widget.scanning ? AppColors.accent : AppColors.success,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({required this.hands, required this.mirror, required this.sweep, required this.bracketColor});
  final List<List<({double x, double y})>> hands;
  final bool mirror;
  final double? sweep;
  final Color bracketColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Brackets
    final b = Paint()
      ..color = bracketColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const m = 16.0;
    const len = 34.0;
    void corner(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * len, y), b);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * len), b);
    }

    corner(m, m, 1, 1);
    corner(size.width - m, m, -1, 1);
    corner(m, size.height - m, 1, -1);
    corner(size.width - m, size.height - m, -1, -1);

    if (sweep != null) {
      final y = m + (size.height - 2 * m) * sweep!;
      canvas.drawLine(
        Offset(m, y),
        Offset(size.width - m, y),
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.7)
          ..strokeWidth = 3,
      );
    }

    for (final points in hands) {
      if (points.length != 21) continue;
      Offset o(({double x, double y}) p) => Offset((mirror ? 1 - p.x : p.x) * size.width, p.y * size.height);
      final line = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 3;
      for (final (a, c) in _connections) {
        canvas.drawLine(o(points[a]), o(points[c]), line);
      }
      final dot = Paint()..color = AppColors.secondary;
      for (final p in points) {
        canvas.drawCircle(o(p), 5, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) => true;
}
