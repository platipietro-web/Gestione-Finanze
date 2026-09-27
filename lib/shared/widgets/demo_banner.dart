import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_mode.dart';
import '../providers/repository_providers.dart';

/// Banner sempre visibile in modalità demo: i dati non vanno confusi con
/// quelli reali.
class DemoBanner extends ConsumerWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Material(
      color: colors.primaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            children: [
              Icon(
                Icons.science_outlined,
                size: 18,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.demoBanner,
                  style: context.textStyles.labelMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: colors.onPrimaryContainer,
                  minimumSize: const Size(48, 36),
                ),
                onPressed: () => exitDemo(ref),
                child: Text(l10n.demoExit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void exitDemo(WidgetRef ref) {
  ref.read(appModeProvider.notifier).exitDemo();
  ref.invalidate(demoStoreProvider);
}
