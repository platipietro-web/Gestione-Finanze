import 'package:flutter/widgets.dart';

import '../theme/tokens/app_dimensions.dart';

/// Classi di larghezza della finestra, come in Material 3.
enum WindowSize {
  /// Smartphone: barra di navigazione in basso.
  compact,

  /// Tablet verticale: navigation rail.
  medium,

  /// Tablet orizzontale e finestre piccole: sidebar compatta.
  expanded,

  /// Desktop: sidebar completa.
  large;

  static WindowSize fromWidth(double width) {
    if (width < 600) return compact;
    if (width < 840) return medium;
    if (width < 1200) return expanded;
    return large;
  }

  bool get isCompact => this == compact;

  /// Da tablet orizzontale in su: elenco e dettaglio affiancati.
  bool get isWide => index >= expanded.index;

  double get pagePadding => switch (this) {
    compact => AppSpacing.md,
    medium => AppSpacing.xl,
    _ => AppSpacing.xxl,
  };

  double get gap => switch (this) {
    compact => AppSpacing.sm,
    medium => AppSpacing.md,
    _ => AppSpacing.xl,
  };
}

extension WindowSizeX on BuildContext {
  WindowSize get windowSize =>
      WindowSize.fromWidth(MediaQuery.sizeOf(this).width);
}
