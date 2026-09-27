import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/auth_controller.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/widgets/form_widgets.dart';
import 'widgets/auth_scaffold.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _confirmationSentTo;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    TextInput.finishAutofillContext();
    final outcome = await ref
        .read(authControllerProvider.notifier)
        .signUp(email: _email.text, password: _password.text);
    if (outcome == SignUpOutcome.confirmationRequired && mounted) {
      setState(() => _confirmationSentTo = _email.text.trim());
    }
    // Con la conferma email disattivata l'utente è già dentro: ci pensa il router.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(authControllerProvider);
    final sentTo = _confirmationSentTo;

    if (sentTo != null) {
      return AuthScaffold(
        title: l10n.confirmEmailTitle,
        subtitle: l10n.confirmEmailMessage(sentTo),
        children: [
          FilledButton(
            onPressed: () => context.go(AppRoutes.login),
            child: Text(l10n.backToLogin),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: l10n.signUpTitle,
      subtitle: l10n.signUpSubtitle,
      children: [
        if (state.hasError) FormMessage.error(context, state.error!),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l10n.emailLabel),
                  validator: (value) => Validators.isEmail(value ?? '')
                      ? null
                      : l10n.invalidEmail,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  controller: _password,
                  label: l10n.passwordLabel,
                  helperText: l10n.passwordHelper,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _submit(),
                  validator: (value) => Validators.isStrongEnough(value ?? '')
                      ? null
                      : l10n.passwordTooShort,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        BusyButton(
          label: l10n.signUpAction,
          busy: state.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.haveAccount, style: context.textStyles.bodyMedium),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: Text(l10n.loginAction),
            ),
          ],
        ),
      ],
    );
  }
}
