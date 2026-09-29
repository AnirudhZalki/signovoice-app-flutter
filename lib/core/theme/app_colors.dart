import 'package:flutter/material.dart';

/// Central colour tokens. Status colours must always be paired with an icon
/// and text (see StatusBadge) — never rely on colour alone.
class AppColors {
  const AppColors._();

  static const primary = Color(0xFF3157D5); // Deep indigo
  static const secondary = Color(0xFF12A594); // Accessible teal
  static const accent = Color(0xFF22C7E8); // Electric cyan

  static const backgroundLight = Color(0xFFF7F9FC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF667085);
  static const outlineLight = Color(0xFFD0D5DD);

  static const success = Color(0xFF12B76A);
  static const warning = Color(0xFFF79009);
  static const error = Color(0xFFF04438);

  static const backgroundDark = Color(0xFF0B1020);
  static const surfaceDark = Color(0xFF151B2E);
  static const surfaceDarkElevated = Color(0xFF1D2540);
  static const textPrimaryDark = Color(0xFFF2F4F7);
  static const textSecondaryDark = Color(0xFFA6B0C5);
  static const outlineDark = Color(0xFF2E3859);

  // Lighter/darker variants that keep >= 4.5:1 contrast on their surface.
  static const primaryOnDark = Color(0xFF8FA6FF);
  static const secondaryOnDark = Color(0xFF3ED6C3);
  static const successOnLight = Color(0xFF027A48);
  static const warningOnLight = Color(0xFFB54708);
  static const errorOnLight = Color(0xFFB42318);
  static const successOnDark = Color(0xFF47CD89);
  static const warningOnDark = Color(0xFFFDB022);
  static const errorOnDark = Color(0xFFFDA29B);
}

/// Semantic status colours resolved for the current brightness.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  static const light = StatusColors(
    success: AppColors.successOnLight,
    warning: AppColors.warningOnLight,
    error: AppColors.errorOnLight,
    info: AppColors.primary,
  );
  static const dark = StatusColors(
    success: AppColors.successOnDark,
    warning: AppColors.warningOnDark,
    error: AppColors.errorOnDark,
    info: AppColors.primaryOnDark,
  );

  @override
  StatusColors copyWith({Color? success, Color? warning, Color? error, Color? info}) =>
      StatusColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        error: error ?? this.error,
        info: info ?? this.info,
      );

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
