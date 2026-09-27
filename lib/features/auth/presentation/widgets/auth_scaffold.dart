import 'package:flutter/material.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_logo.dart';

/// Impaginazione comune delle schermate di accesso: a tutta larghezza su
/// smartphone, in una card centrata su tablet e desktop.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final compact = context.windowSize.isCompact;
    final text = context.textStyles;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppLogo(showName: true),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Semantics(header: true, child: Text(title, style: text.headlineMedium)),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: text.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        ...children,
      ],
    );

    return Scaffold(
      appBar: showBack ? AppBar(leading: const BackButton()) : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(compact ? AppSpacing.xl : AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: compact
                  ? content
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: AppRadius.xlAll,
                        border: Border.all(color: context.colors.border),
                        boxShadow: AppShadows.card(context.brightness),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: content,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
