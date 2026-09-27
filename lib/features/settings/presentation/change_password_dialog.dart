import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/auth_controller.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/form_widgets.dart';

/// Dialog per cambiare password dalle impostazioni.
Future<void> showChangePasswordDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = context.l10n;
  final formKey = GlobalKey<FormState>();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(authControllerProvider);
        return AlertDialog(
          title: Text(l10n.changePassword),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.hasError) FormMessage.error(context, state.error!),
                  PasswordField(
                    controller: password,
                    label: l10n.newPasswordLabel,
                    helperText: l10n.passwordHelper,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    validator: (value) => Validators.isStrongEnough(value ?? '')
                        ? null
                        : l10n.passwordTooShort,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PasswordField(
                    controller: confirm,
                    label: l10n.confirmPasswordLabel,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => value == password.text
                        ? null
                        : l10n.passwordsDoNotMatch,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final ok = await ref
                          .read(authControllerProvider.notifier)
                          .updatePassword(password.text);
                      if (ok && dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(true);
                      }
                    },
              child: Text(l10n.actionSave),
            ),
          ],
        );
      },
    ),
  );
  password.dispose();
  confirm.dispose();
  if (saved == true && context.mounted) {
    showAppSnackBar(context, l10n.passwordUpdated);
  }
}
