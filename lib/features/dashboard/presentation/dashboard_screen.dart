import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/layout/breakpoints.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/catalog_providers.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/session_providers.dart';
import '../../../shared/providers/snapshot_providers.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/section_header.dart';
import '../application/dashboard_providers.dart';
import 'widgets/dashboard_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(snapshotsProvider)
      ..invalidate(catalogProvider);
    await ref.read(snapshotsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);
    final compact = context.windowSize.isCompact;
    final l10n = context.l10n;
    final hasData = data.value != null;

    return Scaffold(
      floatingActionButton: compact && hasData
          ? FloatingActionButton.extended(
              heroTag: 'dashboard-update',
              onPressed: () => context.push(AppRoutes.update),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.updateWealthCta),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: AsyncView(
          value: data,
          loading: () => const DashboardSkeleton(),
          onRetry: () => _refresh(ref),
          data: (dashboard) => dashboard == null
              ? const _EmptyDashboard()
              : RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      if (width < 700) {
                        return _CompactDashboard(data: dashboard);
                      }
                      if (width < 1000) {
                        return _MediumDashboard(data: dashboard);
                      }
                      return _WideDashboard(data: dashboard);
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hour = ref.watch(clockProvider)().hour;
    final greeting = hour >= 5 && hour < 12
        ? l10n.greetingMorning
        : hour >= 12 && hour < 18
        ? l10n.greetingAfternoon
        : l10n.greetingEvening;
    final name = ref.watch(profileProvider).value?.displayName;
    return Text(
      name == null ? greeting : l10n.greetingWithName(greeting, name),
      style: context.textStyles.titleMedium,
    );
  }
}

class _SettingsButton extends ConsumerWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final profile = ref.watch(profileProvider).value;
    final source = profile?.displayName ?? profile?.email ?? '';
    final initial = source.isEmpty
        ? null
        : source.characters.first.toUpperCase();
    return Tooltip(
      message: context.l10n.openSettings,
      child: InkResponse(
        onTap: () => context.go(AppRoutes.settings),
        radius: 24,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: initial == null
              ? const Icon(Icons.person_outline_rounded, size: 20)
              : Text(
                  initial,
                  style: context.textStyles.labelLarge?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CompactDashboard extends ConsumerWidget {
  const _CompactDashboard({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showReminder = ref.watch(updateReminderProvider);
    const gap = SizedBox(height: AppSpacing.sm);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        104,
      ),
      children: [
        const Row(
          children: [
            Expanded(child: _Greeting()),
            _SettingsButton(),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        NetWorthHero(latest: data.latest),
        if (showReminder) ...[
          const SizedBox(height: AppSpacing.lg),
          const ReminderBanner(),
        ],
        const SizedBox(height: AppSpacing.xl),
        const NetWorthChartCard(),
        gap,
        CategoryGrid(data: data, columns: 2),
        gap,
        DistributionCard(data: data),
      ],
    );
  }
}

class _MediumDashboard extends ConsumerWidget {
  const _MediumDashboard({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showReminder = ref.watch(updateReminderProvider);
    const gap = AppSpacing.md;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const Row(
          children: [
            Expanded(child: _Greeting()),
            _SettingsButton(),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        NetWorthHero(latest: data.latest),
        if (showReminder) ...[
          const SizedBox(height: AppSpacing.lg),
          const ReminderBanner(),
        ],
        const SizedBox(height: AppSpacing.xl),
        CategoryGrid(data: data, columns: 3, gap: gap),
        const SizedBox(height: gap),
        const NetWorthChartCard(chartHeight: 280),
        const SizedBox(height: gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: DistributionCard(data: data)),
            const SizedBox(width: gap),
            Expanded(child: RecentUpdatesCard(points: data.recent)),
          ],
        ),
      ],
    );
  }
}

class _WideDashboard extends ConsumerWidget {
  const _WideDashboard({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final showReminder = ref.watch(updateReminderProvider);
    const gap = AppSpacing.xl;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitle(
              l10n.dashboardTitle,
              actions: [
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.update),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.updateWealthCta),
                ),
              ],
            ),
            if (showReminder) ...[
              const SizedBox(height: AppSpacing.lg),
              const ReminderBanner(),
            ],
            const SizedBox(height: gap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: NetWorthHero(latest: data.latest, large: true),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  flex: 8,
                  child: CategoryGrid(
                    data: data,
                    columns: data.assetCategories.length + 1 > 4 ? 3 : 4,
                    gap: AppSpacing.md,
                  ),
                ),
              ],
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: 440,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    flex: 8,
                    child: NetWorthChartCard(chartHeight: 340),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: DistributionCard(data: data),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final compact = context.windowSize.isCompact;
    return Column(
      children: [
        if (compact)
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(child: _Greeting()),
                _SettingsButton(),
              ],
            ),
          ),
        Expanded(
          child: EmptyState(
            icon: Icons.insights_rounded,
            title: l10n.emptyDashboardTitle,
            message: l10n.emptyDashboardMessage,
            actionLabel: l10n.emptyDashboardAction,
            onAction: () => context.push(AppRoutes.update),
          ),
        ),
      ],
    );
  }
}
