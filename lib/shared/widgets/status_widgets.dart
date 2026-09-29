import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/l10n_ext.dart';

enum StatusTone { success, warning, error, info, neutral }

/// Status is always communicated with icon + text + colour, never colour alone.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = StatusTone.neutral, this.icon});

  final String label;
  final StatusTone tone;
  final IconData? icon;

  static IconData defaultIcon(StatusTone t) => switch (t) {
        StatusTone.success => Icons.check_circle_outline,
        StatusTone.warning => Icons.warning_amber_rounded,
        StatusTone.error => Icons.error_outline,
        StatusTone.info => Icons.info_outline,
        StatusTone.neutral => Icons.circle_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sc = Theme.of(context).extension<StatusColors>() ?? StatusColors.light;
    final color = switch (tone) {
      StatusTone.success => sc.success,
      StatusTone.warning => sc.warning,
      StatusTone.error => sc.error,
      StatusTone.info => sc.info,
      StatusTone.neutral => scheme.onSurfaceVariant,
    };
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon ?? defaultIcon(tone), size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confidence bar with numeric value and a text level (High/Medium/Low).
class ConfidenceIndicator extends StatelessWidget {
  const ConfidenceIndicator({super.key, required this.confidence, this.threshold = 0.7});

  /// 0..1
  final double confidence;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final sc = Theme.of(context).extension<StatusColors>() ?? StatusColors.light;
    final pct = (confidence.clamp(0, 1) * 100).round();
    final (label, color, icon) = confidence >= threshold
        ? (l.confidenceHigh, sc.success, Icons.check_circle_outline)
        : confidence >= threshold - 0.2
            ? (l.confidenceMedium, sc.warning, Icons.remove_circle_outline)
            : (l.confidenceLow, sc.error, Icons.error_outline);
    return Semantics(
      label: l.confidenceValue('$pct'),
      value: label,
      child: ExcludeSemantics(
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: confidence.clamp(0, 1).toDouble(),
                  minHeight: 10,
                  color: color,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('$pct% · $label', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
