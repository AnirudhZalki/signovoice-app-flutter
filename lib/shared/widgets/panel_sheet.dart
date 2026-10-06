import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A bottom panel the person can drag between a compact and a tall size, floating over a full-screen background
/// (camera / sign stage). Content scrolls inside it when it is small.
class PanelSheet extends StatelessWidget {
  const PanelSheet({super.key, required this.child, this.initial = 0.34, this.min = 0.16, this.max = 0.72});
  final Widget child;
  final double initial;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: initial,
      minChildSize: min,
      maxChildSize: max,
      snap: true,
      snapSizes: [min, initial, max],
      builder: (context, controller) => Material(
        color: scheme.surface,
        elevation: 12,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        clipBehavior: Clip.antiAlias,
        child: ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.paddingOf(context).bottom),
          children: [
            ExcludeSemantics(
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
