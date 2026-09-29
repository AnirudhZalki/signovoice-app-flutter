import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// SignoVoice mark: a speech bubble holding a signing hand, with a small
/// connection motif. Decorative — excluded from semantics.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 88});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(size * 0.3),
              ),
            ),
            Positioned(
              left: size * 0.12,
              bottom: -size * 0.04,
              child: Transform.rotate(
                angle: 0.6,
                child: Container(
                  width: size * 0.2,
                  height: size * 0.2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(size * 0.04),
                  ),
                ),
              ),
            ),
            Icon(Icons.sign_language_rounded, size: size * 0.56, color: Colors.white),
            Positioned(
              right: size * 0.1,
              top: size * 0.1,
              child: Container(
                width: size * 0.16,
                height: size * 0.16,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: size * 0.2,
              bottom: size * 0.14,
              child: Container(
                width: size * 0.11,
                height: size * 0.11,
                decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
