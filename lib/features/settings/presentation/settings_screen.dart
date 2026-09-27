import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/layout/breakpoints.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/app_mode.dart';
import '../../../shared/providers/auth_controller.dart';
import '../../../shared/providers/session_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/section_header.dart';
import 'change_password_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final compact = context.windowSize.isCompact;
    final isDemo = ref.watch(appModeProvider) == AppMode.demo;

    final sections = <Widget>[
      if (!isDemo) ...[
        _Section(title: l10n.profileSection, child: const _ProfileForm()),
        const SizedBox(height: AppSpacing.lg),
      ],
      _Section(title: l10n.appearanceSection, child: const _ThemeSelector()),
      const SizedBox(height: AppSpacing.lg),
      if (isDemo)
        _Section(
          title: l10n.accountSection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.demoSettingsNote, style: context.textStyles.bodySmall),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => exitDemo(ref),
                icon: const Icon(Icons.logout_rounded),
                label: Text(l10n.exitDemo),
              ),
            ],
          ),
        )
      else ...[
        _Section(
          title: l10n.securitySection,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline_rounded),
            title: Text(l10n.changePassword),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showChangePasswordDialog(context, ref),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _Section(title: '', child: _AccountActions()),
      ],
    ];

    return Scaffold(
      appBar: compact
          ? AppBar(
              leading: BackButton(
                onPressed: () => context.go(AppRoutes.dashboard),
              ),
              title: Text(l10n.settingsTitle),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xxl),
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!compact) ...[
                      PageTitle(l10n.settingsTitle),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    ...sections,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.isNotEmpty) ...[
          SectionHeader(title),
          const SizedBox(height: AppSpacing.sm),
        ],
        AppCard(child: child),
      ],
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm();

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final _name = TextEditingController(
    text: ref.read(profileProvider).value?.displayName ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      await ref.read(profileProvider.notifier).updateDisplayName(_name.text);
      if (mounted) showAppSnackBar(context, l10n.profileSaved);
    } catch (error) {
      if (mounted) showErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = ref.watch(profileProvider).value?.email;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (email != null) ...[
          Text(l10n.signedInAs(email), style: context.textStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
        ],
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          maxLength: Validators.maxNameLength,
          onSubmitted: (_) => _save(),
          decoration: InputDecoration(
            labelText: l10n.displayNameLabel,
            helperText: l10n.displayNameHint,
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton.tonal(
            onPressed: _saving ? null : _save,
            child: Text(l10n.actionSave),
          ),
        ),
      ],
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(themeModeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.themeLabel, style: context.textStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              icon: const Icon(Icons.brightness_auto_outlined),
              label: Text(l10n.themeSystem),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: const Icon(Icons.light_mode_outlined),
              label: Text(l10n.themeLight),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode_outlined),
              label: Text(l10n.themeDark),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) =>
              ref.read(themeModeProvider.notifier).select(selection.first),
        ),
      ],
    );
  }
}

class _AccountActions extends ConsumerWidget {
  const _AccountActions();

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteAccountTitle,
      message: l10n.deleteAccountMessage,
      confirmLabel: l10n.deleteAccountConfirm,
      destructive: true,
    );
    if (!confirmed) return;
    final ok = await ref.read(authControllerProvider.notifier).deleteAccount();
    if (!ok && context.mounted) {
      final error = ref.read(authControllerProvider).error;
      if (error != null) showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final busy = ref.watch(authControllerProvider).isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout_rounded),
          title: Text(l10n.signOut),
          enabled: !busy,
          onTap: () => ref.read(authControllerProvider.notifier).signOut(),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.delete_forever_outlined, color: colors.negative),
          title: Text(
            l10n.deleteAccount,
            style: TextStyle(color: colors.negative),
          ),
          enabled: !busy,
          onTap: () => _delete(context, ref),
        ),
      ],
    );
  }
}
