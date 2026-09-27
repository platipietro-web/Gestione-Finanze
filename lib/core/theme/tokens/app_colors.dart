import 'package:flutter/material.dart';

/// Colori del design system. I widget non usano mai valori esadecimali:
/// leggono questi token con `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.positive,
    required this.negative,
    required this.chart,
    required this.chartOther,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  /// Variazioni favorevoli. Mai usato come colore di una serie.
  final Color positive;

  /// Variazioni sfavorevoli ed errori. Mai usato come colore di una serie.
  final Color negative;

  /// Palette categoriale dei grafici, in ordine fisso. Validata per
  /// daltonismo e contrasto (vedi docs/ARCHITETTURA.md, sezione 7.3).
  final List<Color> chart;

  /// Colore neutro per la fetta "Altro".
  final Color chartOther;

  static const light = AppColors(
    background: Color(0xFFF6F6F3),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEFEFEA),
    border: Color(0xFFE4E4DE),
    textPrimary: Color(0xFF101418),
    textSecondary: Color(0xFF5A6068),
    textTertiary: Color(0xFF666C74),
    primary: Color(0xFF0B7D5E),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE8F5EF),
    onPrimaryContainer: Color(0xFF053D2E),
    positive: Color(0xFF177A48),
    negative: Color(0xFFB93A2E),
    chart: [
      Color(0xFF0B7D5E),
      Color(0xFFB47B0C),
      Color(0xFF3B6FD1),
      Color(0xFFD0668F),
      Color(0xFF6E5BC4),
    ],
    chartOther: Color(0xFF9AA0A6),
  );

  static const dark = AppColors(
    background: Color(0xFF0D1012),
    surface: Color(0xFF15191C),
    surfaceMuted: Color(0xFF1C2125),
    border: Color(0xFF262C31),
    textPrimary: Color(0xFFF1F3F4),
    textSecondary: Color(0xFFA1A9B0),
    textTertiary: Color(0xFF7F8790),
    primary: Color(0xFF5DD3AC),
    onPrimary: Color(0xFF04261C),
    primaryContainer: Color(0xFF12362C),
    onPrimaryContainer: Color(0xFFBDEBD9),
    positive: Color(0xFF5BCB8C),
    negative: Color(0xFFF0837A),
    chart: [
      Color(0xFF22A07A),
      Color(0xFFB98424),
      Color(0xFF4F86E8),
      Color(0xFFC9658F),
      Color(0xFF8A7BE0),
    ],
    chartOther: Color(0xFF5F676E),
  );

  /// Colore della serie in posizione [slot]; fuori palette restituisce il
  /// neutro di "Altro".
  Color seriesColor(int slot) =>
      slot >= 0 && slot < chart.length ? chart[slot] : chartOther;

  @override
  AppColors copyWith({Color? primary, Color? positive, Color? negative}) =>
      AppColors(
        background: background,
        surface: surface,
        surfaceMuted: surfaceMuted,
        border: border,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        textTertiary: textTertiary,
        primary: primary ?? this.primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        positive: positive ?? this.positive,
        negative: negative ?? this.negative,
        chart: chart,
        chartOther: chartOther,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      border: mix(border, other.border),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      primaryContainer: mix(primaryContainer, other.primaryContainer),
      onPrimaryContainer: mix(onPrimaryContainer, other.onPrimaryContainer),
      positive: mix(positive, other.positive),
      negative: mix(negative, other.negative),
      chart: [
        for (var i = 0; i < chart.length; i++) mix(chart[i], other.chart[i]),
      ],
      chartOther: mix(chartOther, other.chartOther),
    );
  }
}
