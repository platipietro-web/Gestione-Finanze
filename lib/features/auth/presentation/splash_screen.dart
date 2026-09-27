import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/auth_controller.dart';
import '../../../shared/providers/session_providers.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/feedback_views.dart';

/// Mostrata mentre si caricano sessione e profilo. Se il profilo non si
/// carica, spiega il problema e permette di riprovare o di uscire.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: profile.hasError && !profile.isLoading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ErrorView(
                      error: profile.error!,
                      onRetry: () => ref.invalidate(profileProvider),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                      child: Text(l10n.signOut),
                    ),
                  ],
                )
              : Semantics(
                  label: l10n.loading,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLogo(size: 56),
                      SizedBox(height: AppSpacing.xl),
                      SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
