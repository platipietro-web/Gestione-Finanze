import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/app_mode.dart';
import '../../../shared/providers/auth_controller.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/session_providers.dart';
import '../../../shared/widgets/form_widgets.dart';
import 'widgets/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    TextInput.finishAutofillContext();
    // Se l'accesso riesce, il router porta alla dashboard.
    await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(authControllerProvider);
    final available = ref.watch(authRepositoryProvider).isAvailable;
    final expired = ref.watch(authStateProvider).value?.sessionExpired ?? false;
    final busy = state.isLoading;

    return AuthScaffold(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      children: [
        if (!available) FormMessage(message: l10n.supabaseNotConfigured),
        if (expired && !state.hasError)
          FormMessage(message: l10n.errorSessionExpired),
        if (state.hasError) FormMessage.error(context, state.error!),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _email,
                  enabled: available,
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
                  onSubmitted: (_) => _submit(),
                  validator: (value) =>
                      (value ?? '').isEmpty ? l10n.validationRequired : null,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: available
                ? () => context.push(AppRoutes.forgotPassword)
                : null,
            child: Text(l10n.forgotPassword),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        BusyButton(
          label: l10n.loginAction,
          busy: busy,
          onPressed: available ? _submit : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.noAccount, style: context.textStyles.bodyMedium),
            TextButton(
              onPressed: available ? () => context.go(AppRoutes.signUp) : null,
              child: Text(l10n.signUpLink),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => ref.read(appModeProvider.notifier).enterDemo(),
          icon: const Icon(Icons.science_outlined),
          label: Text(l10n.tryDemo),
        ),
      ],
    );
  }
}
