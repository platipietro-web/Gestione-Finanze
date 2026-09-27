import 'package:flutter/material.dart';

/// Spaziature su griglia da 4.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
}

abstract final class AppRadius {
  /// Chip e badge.
  static const double sm = 8;

  /// Bottoni e campi di testo.
  static const double md = 12;

  /// Card.
  static const double lg = 20;

  /// Bottom sheet e dialog.
  static const double xl = 28;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

abstract final class AppShadows {
  /// Card nel tema chiaro: ombra quasi impercettibile. Nel tema scuro nessuna
  /// ombra: l'elevazione si ottiene con superfici più chiare.
  static List<BoxShadow> card(Brightness brightness) =>
      brightness == Brightness.dark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0A101418),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Color(0x0A101418),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ];

  /// Menu, sheet, bottone flottante.
  static List<BoxShadow> elevated(Brightness brightness) =>
      brightness == Brightness.dark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x1F101418),
            offset: Offset(0, 12),
            blurRadius: 32,
          ),
        ];
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 450);
  static const curve = Curves.easeOutCubic;

  /// Rispetta l'impostazione di sistema "Riduci movimento".
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
      ? Duration.zero
      : duration;
}

/// Larghezza massima del contenuto su schermi grandi.
const double kMaxContentWidth = 1320;
