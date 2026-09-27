import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_messages.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';

/// Stato vuoto: un titolo, una frase, un bottone.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: AppRadius.lgAll,
                  ),
                  child: Icon(icon, color: colors.onPrimaryContainer, size: 28),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(title, style: text.titleLarge, textAlign: TextAlign.center),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message!,
                  style: text.bodyMedium?.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon ?? Icons.add_rounded),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Errore spiegato in modo comprensibile, con "Riprova".
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isNetwork = AppFailure.from(error).kind == FailureKind.network;
    return EmptyState(
      icon: isNetwork ? Icons.cloud_off_rounded : Icons.error_outline_rounded,
      title: failureMessage(l10n, error),
      actionLabel: onRetry == null ? null : l10n.actionRetry,
      actionIcon: Icons.refresh_rounded,
      onAction: onRetry,
    );
  }
}

/// Mostra dati, caricamento o errore in modo uniforme. Durante un
/// ricaricamento restano visibili i dati precedenti.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    required this.loading,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function() loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) return data(value.value as T);
    if (value.hasError) return ErrorView(error: value.error!, onRetry: onRetry);
    return loading();
  }
}

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showErrorSnackBar(BuildContext context, Object error) {
  showAppSnackBar(context, failureMessage(context.l10n, error));
}
