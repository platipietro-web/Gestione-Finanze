import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Card del design system: superficie, bordo sottile, raggio 20.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final String? semanticLabel;

  static EdgeInsets defaultPadding(BuildContext context) => EdgeInsets.all(
    MediaQuery.sizeOf(context).width < 600 ? AppSpacing.md : AppSpacing.lg,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = Padding(
      padding: padding ?? defaultPadding(context),
      child: child,
    );
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          boxShadow: AppShadows.card(context.brightness),
        ),
        child: Material(
          color: color ?? colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgAll,
            side: BorderSide(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: onTap == null
              ? content
              : InkWell(onTap: onTap, child: content),
        ),
      ),
    );
  }
}
