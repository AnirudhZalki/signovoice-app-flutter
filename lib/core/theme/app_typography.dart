import 'package:flutter/material.dart';

/// Inter (bundled, so it works offline). Generous line height; no size below
/// 12sp. Text scales with the user's system + in-app text size.
class AppTypography {
  const AppTypography._();

  static const fontFamily = 'Inter';

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle s(double size, FontWeight w, double h, {Color? c, double ls = 0}) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: w,
          height: h,
          letterSpacing: ls,
          color: c ?? primary,
        );
    return TextTheme(
      // Display
      displayLarge: s(40, FontWeight.w700, 1.25, ls: -0.5),
      displayMedium: s(34, FontWeight.w700, 1.25, ls: -0.4),
      displaySmall: s(30, FontWeight.w700, 1.3),
      // Headline
      headlineLarge: s(28, FontWeight.w700, 1.3),
      headlineMedium: s(24, FontWeight.w700, 1.35),
      headlineSmall: s(22, FontWeight.w600, 1.35),
      // Title
      titleLarge: s(20, FontWeight.w600, 1.4),
      titleMedium: s(17, FontWeight.w600, 1.45),
      titleSmall: s(15, FontWeight.w600, 1.45),
      // Body
      bodyLarge: s(17, FontWeight.w400, 1.55),
      bodyMedium: s(16, FontWeight.w400, 1.55),
      bodySmall: s(14, FontWeight.w400, 1.5, c: secondary),
      // Label
      labelLarge: s(16, FontWeight.w600, 1.4, ls: 0.1),
      labelMedium: s(14, FontWeight.w500, 1.4, ls: 0.1),
      // Caption
      labelSmall: s(13, FontWeight.w500, 1.4, c: secondary, ls: 0.2),
    );
  }
}
