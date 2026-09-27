import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/auth_controller.dart';
import '../../../shared/widgets/form_widgets.dart';
import 'widgets/auth_scaffold.dart';

/// Aperta dal link dell'email di recupero. Dopo il salvataggio il router
/// porta alla home.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.passwordUpdated;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .updatePassword(_password.text);
    if (ok) messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(authControllerProvider);
    return AuthScaffold(
      title: l10n.resetTitle,
      subtitle: l10n.resetMessage,
      children: [
        if (state.hasError) FormMessage.error(context, state.error!),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PasswordField(
                  controller: _password,
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
                  controller: _confirm,
                  label: l10n.confirmPasswordLabel,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _submit(),
                  validator: (value) =>
                      value == _password.text ? null : l10n.passwordsDoNotMatch,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        BusyButton(
          label: l10n.resetAction,
          busy: state.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
