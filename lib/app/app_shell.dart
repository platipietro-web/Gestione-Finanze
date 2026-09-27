import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../core/layout/breakpoints.dart';
import '../core/router/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../shared/providers/app_mode.dart';
import '../shared/providers/auth_controller.dart';
import '../shared/providers/session_providers.dart';
import '../shared/widgets/app_logo.dart';
import '../shared/widgets/demo_banner.dart';

/// Indici dei rami della navigazione principale.
abstract final class ShellBranch {
  static const dashboard = 0;
  static const assets = 1;
  static const investments = 2;
  static const history = 3;
  static const settings = 4;
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Navigazione adattiva: barra in basso su smartphone, rail su tablet
/// verticale, sidebar su tablet orizzontale e desktop.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goTo(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final size = context.windowSize;
    final isDemo = ref.watch(appModeProvider) == AppMode.demo;
    final destinations = [
      _Destination(l10n.navHome, Icons.home_outlined, Icons.home_rounded),
      _Destination(
        l10n.navAssets,
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded,
      ),
      _Destination(
        l10n.navInvestments,
        Icons.show_chart_rounded,
        Icons.show_chart_rounded,
      ),
      _Destination(
        l10n.navHistory,
        Icons.history_rounded,
        Icons.history_rounded,
      ),
    ];
    final current = navigationShell.currentIndex;

    final body = Column(
      children: [
        if (isDemo) const DemoBanner(),
        Expanded(child: navigationShell),
      ],
    );

    if (size.isCompact) {
      return Scaffold(
        body: body,
        bottomNavigationBar: current == ShellBranch.settings
            ? null
            : NavigationBar(
                selectedIndex: current,
                onDestinationSelected: _goTo,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  for (final d in destinations)
                    NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    ),
                ],
              ),
      );
    }

    final colors = context.colors;
    if (size == WindowSize.medium) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: current == ShellBranch.settings ? null : current,
              onDestinationSelected: _goTo,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  children: [
                    const AppLogo(size: 36),
                    const SizedBox(height: AppSpacing.lg),
                    Tooltip(
                      message: l10n.updateWealthCta,
                      child: FloatingActionButton.small(
                        heroTag: 'rail-update',
                        elevation: 0,
                        onPressed: () => context.push(AppRoutes.update),
                        child: const Icon(Icons.add_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: IconButton(
                      tooltip: l10n.navSettings,
                      isSelected: current == ShellBranch.settings,
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: Icon(
                        Icons.settings_rounded,
                        color: colors.primary,
                      ),
                      onPressed: () => _goTo(ShellBranch.settings),
                    ),
                  ),
                ),
              ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: colors.border),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            width: size == WindowSize.large ? 248 : 224,
            destinations: destinations,
            current: current,
            onSelect: _goTo,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.width,
    required this.destinations,
    required this.current,
    required this.onSelect,
  });

  final double width;
  final List<_Destination> destinations;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.textStyles;
    final l10n = context.l10n;
    final isDemo = ref.watch(appModeProvider) == AppMode.demo;
    final profile = ref.watch(profileProvider).value;
    final who = isDemo
        ? l10n.demoModeLabel
        : (profile?.displayName ?? profile?.email ?? '');

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: AppLogo(size: 32, showName: true),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.update),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  l10n.updateWealthCta,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < destinations.length; i++)
                _SidebarItem(
                  label: destinations[i].label,
                  icon: current == i
                      ? destinations[i].selectedIcon
                      : destinations[i].icon,
                  selected: current == i,
                  onTap: () => onSelect(i),
                ),
              const Spacer(),
              Divider(color: colors.border),
              const SizedBox(height: AppSpacing.xs),
              _SidebarItem(
                label: l10n.navSettings,
                icon: current == ShellBranch.settings
                    ? Icons.settings_rounded
                    : Icons.settings_outlined,
                selected: current == ShellBranch.settings,
                onTap: () => onSelect(ShellBranch.settings),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      who,
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: isDemo ? l10n.exitDemo : l10n.signOut,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    onPressed: () => isDemo
                        ? exitDemo(ref)
                        : ref.read(authControllerProvider.notifier).signOut(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? colors.primaryContainer : Colors.transparent,
          borderRadius: AppRadius.mdAll,
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected
                        ? colors.onPrimaryContainer
                        : colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selected
                            ? colors.onPrimaryContainer
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
