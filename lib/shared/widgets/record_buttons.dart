import 'package:flutter/material.dart';

/// Large circular action button used on camera screens (record / pause).
class RecordingButton extends StatelessWidget {
  const RecordingButton({
    super.key,
    required this.active,
    required this.onPressed,
    required this.activeLabel,
    required this.inactiveLabel,
    this.size = 76,
  });

  final bool active;
  final VoidCallback? onPressed;
  final String activeLabel;
  final String inactiveLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      toggled: active,
      label: active ? activeLabel : inactiveLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
          width: size,
          height: size,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: AnimatedContainer(
            duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: active ? scheme.error : scheme.primary,
              borderRadius: BorderRadius.circular(active ? 14 : size),
            ),
            child: Icon(active ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white, size: size * 0.45),
          ),
        ),
      ),
    );
  }
}

/// Microphone button with a pulsing halo while listening (static when motion is reduced).
class VoiceButton extends StatefulWidget {
  const VoiceButton({
    super.key,
    required this.listening,
    required this.onPressed,
    required this.startLabel,
    required this.stopLabel,
    this.size = 88,
  });

  final bool listening;
  final VoidCallback? onPressed;
  final String startLabel;
  final String stopLabel;
  final double size;

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant VoiceButton old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final animate = widget.listening && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_c.isAnimating) {
      _c.repeat();
    } else if (!animate && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.listening ? scheme.error : scheme.primary;
    return Semantics(
      button: true,
      toggled: widget.listening,
      label: widget.listening ? widget.stopLabel : widget.startLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: SizedBox(
          width: widget.size * 1.6,
          height: widget.size * 1.6,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, child) => Stack(
              alignment: Alignment.center,
              children: [
                if (widget.listening)
                  Container(
                    width: widget.size * (1 + 0.5 * _c.value),
                    height: widget.size * (1 + 0.5 * _c.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.25 * (1 - _c.value)),
                    ),
                  ),
                child!,
              ],
            ),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(widget.listening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: scheme.onPrimary, size: widget.size * 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
