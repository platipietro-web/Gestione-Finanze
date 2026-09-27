import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Scala tipografica. Inter è incluso nell'app (nessuna richiesta a server
/// esterni) e tutti i numeri usano cifre a larghezza fissa.
abstract final class AppTypography {
  static const fontFamily = 'Inter';
  static const _tabular = [FontFeature.tabularFigures()];

  static TextStyle _style(
    double size,
    double lineHeight,
    FontWeight weight,
    Color color, {
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    fontFeatures: _tabular,
  );

  static TextTheme textTheme(AppColors c) {
    const semibold = FontWeight.w600;
    const medium = FontWeight.w500;
    const regular = FontWeight.w400;
    return TextTheme(
      // Patrimonio netto su desktop e su smartphone.
      displayLarge: _style(
        56,
        60,
        semibold,
        c.textPrimary,
        letterSpacing: -1.2,
      ),
      displayMedium: _style(
        40,
        44,
        semibold,
        c.textPrimary,
        letterSpacing: -0.8,
      ),
      displaySmall: _style(
        32,
        38,
        semibold,
        c.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineLarge: _style(
        28,
        34,
        semibold,
        c.textPrimary,
        letterSpacing: -0.3,
      ),
      headlineMedium: _style(
        24,
        30,
        semibold,
        c.textPrimary,
        letterSpacing: -0.2,
      ),
      headlineSmall: _style(20, 26, semibold, c.textPrimary),
      titleLarge: _style(18, 26, semibold, c.textPrimary),
      titleMedium: _style(17, 24, semibold, c.textPrimary),
      titleSmall: _style(15, 22, semibold, c.textPrimary),
      bodyLarge: _style(16, 24, regular, c.textPrimary),
      bodyMedium: _style(15, 22, regular, c.textPrimary),
      bodySmall: _style(13, 18, regular, c.textSecondary),
      labelLarge: _style(15, 20, semibold, c.textPrimary),
      labelMedium: _style(13, 18, medium, c.textSecondary),
      labelSmall: _style(12, 16, medium, c.textTertiary),
    );
  }
}
