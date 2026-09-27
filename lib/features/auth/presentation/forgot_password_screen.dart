import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/auth_controller.dart';
import '../../../shared/widgets/form_widgets.dart';
import 'widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_email.text);
    if (ok && mounted) setState(() => _sentTo = _email.text.trim());
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(authControllerProvider);
    final sentTo = _sentTo;

    if (sentTo != null) {
      return AuthScaffold(
        title: l10n.forgotTitle,
        subtitle: l10n.forgotSentMessage(sentTo),
        children: [
          FilledButton(onPressed: _back, child: Text(l10n.backToLogin)),
        ],
      );
    }

    return AuthScaffold(
      title: l10n.forgotTitle,
      subtitle: l10n.forgotMessage,
      children: [
        if (state.hasError) FormMessage.error(context, state.error!),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(labelText: l10n.emailLabel),
            validator: (value) =>
                Validators.isEmail(value ?? '') ? null : l10n.invalidEmail,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        BusyButton(
          label: l10n.forgotAction,
          busy: state.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(onPressed: _back, child: Text(l10n.backToLogin)),
      ],
    );
  }
}
