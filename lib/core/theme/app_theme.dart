import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Material 3 light/dark themes. Dark mode is designed separately (elevated
/// surfaces lighten, accent colours are brightened) rather than inverted.
class AppTheme {
  const AppTheme._();

  static ThemeData light({bool highContrast = false, bool reduceMotion = false}) =>
      _build(Brightness.light, highContrast, reduceMotion);

  static ThemeData dark({bool highContrast = false, bool reduceMotion = false}) =>
      _build(Brightness.dark, highContrast, reduceMotion);

  static ThemeData _build(Brightness b, bool hc, bool reduceMotion) {
    final isDark = b == Brightness.dark;
    final onSurface = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final onSurfaceVariant = hc
        ? onSurface
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);
    final outline = hc
        ? onSurface
        : (isDark ? AppColors.outlineDark : AppColors.outlineLight);
    final primary = isDark ? AppColors.primaryOnDark : AppColors.primary;

    final scheme = ColorScheme(
      brightness: b,
      primary: primary,
      onPrimary: isDark ? const Color(0xFF0B1020) : Colors.white,
      primaryContainer: isDark ? const Color(0xFF22306B) : const Color(0xFFE0E7FF),
      onPrimaryContainer: isDark ? const Color(0xFFDCE4FF) : const Color(0xFF1B2F86),
      secondary: isDark ? AppColors.secondaryOnDark : AppColors.secondary,
      onSecondary: isDark ? const Color(0xFF04211E) : Colors.white,
      secondaryContainer: isDark ? const Color(0xFF0C3D38) : const Color(0xFFD5F5F0),
      onSecondaryContainer: isDark ? const Color(0xFFC6F5EE) : const Color(0xFF064740),
      tertiary: AppColors.accent,
      onTertiary: const Color(0xFF00252D),
      tertiaryContainer: isDark ? const Color(0xFF0E3F4A) : const Color(0xFFD3F3FB),
      onTertiaryContainer: isDark ? const Color(0xFFCDF3FB) : const Color(0xFF07414C),
      error: isDark ? AppColors.errorOnDark : AppColors.errorOnLight,
      onError: isDark ? const Color(0xFF3A0B07) : Colors.white,
      errorContainer: isDark ? const Color(0xFF5A1611) : const Color(0xFFFEE4E2),
      onErrorContainer: isDark ? const Color(0xFFFEE4E2) : const Color(0xFF7A271A),
      surface: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: isDark ? AppColors.outlineDark : const Color(0xFFEAECF0),
      surfaceContainerLowest: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
      surfaceContainerLow: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      surfaceContainer: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      surfaceContainerHigh: isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF2F4F7),
      surfaceContainerHighest: isDark ? const Color(0xFF262F4E) : const Color(0xFFEAECF0),
      inverseSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      onInverseSurface: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final text = AppTypography.textTheme(onSurface, onSurfaceVariant);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd));
    const minSize = Size(AppSpacing.minTouch, AppSpacing.largeTouch);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: b,
      fontFamily: AppTypography.fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [isDark ? StatusColors.dark : StatusColors.light],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: reduceMotion ? NoSplash.splashFactory : InkRipple.splashFactory,
      pageTransitionsTheme: reduceMotion
          ? const PageTransitionsTheme(builders: {
              TargetPlatform.android: _NoTransitionBuilder(),
              TargetPlatform.iOS: _NoTransitionBuilder(),
            })
          : const PageTransitionsTheme(builders: {
              TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            }),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: scheme.outlineVariant, width: hc ? 2 : 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minSize,
          shape: shape,
          textStyle: text.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: minSize, shape: shape, textStyle: text.labelLarge),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minSize,
          shape: shape,
          textStyle: text.labelLarge,
          side: BorderSide(color: hc ? onSurface : scheme.outline, width: hc ? 2 : 1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTouch, AppSpacing.minTouch),
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(AppSpacing.minTouch, AppSpacing.minTouch)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle: text.bodyMedium?.copyWith(color: onSurfaceVariant),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => text.labelMedium?.copyWith(
              color: s.contains(WidgetState.selected) ? scheme.primary : onSurfaceVariant,
              fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              size: 26,
              color: s.contains(WidgetState.selected) ? scheme.onPrimaryContainer : onSurfaceVariant,
            )),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        shape: shape,
      ),
      chipTheme: ChipThemeData(
        labelStyle: text.labelMedium,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        iconColor: onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      focusColor: scheme.primary.withValues(alpha: 0.2),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith((s) =>
            Icon(s.contains(WidgetState.selected) ? Icons.check : Icons.close, size: 16)),
      ),
    );
  }
}

class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
          Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
      child;
}
