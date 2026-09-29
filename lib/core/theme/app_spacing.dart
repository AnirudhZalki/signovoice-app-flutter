import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Minimum touch target (WCAG / Material: 48dp).
  static const double minTouch = 48;
  static const double largeTouch = 56;

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets pageAll = EdgeInsets.all(16);
}
