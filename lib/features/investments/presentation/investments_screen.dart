import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/time/month_labels.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/snapshot_providers.dart';
import '../../../shared/services/wealth_calculator.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/charts/proportion_bars.dart';
import '../../../shared/widgets/charts/range_selector.dart';
import '../../../shared/widgets/charts/value_line_chart.dart';
import '../../../shared/widgets/delta_badge.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton.dart';
import '../application/investments_providers.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final data = ref.watch(investmentsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncView(
          value: data,
          onRetry: () => ref.invalidate(snapshotsProvider),
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                SkeletonCard(height: 140, lines: 2),
                SizedBox(height: AppSpacing.sm),
                SkeletonCard(height: 280, lines: 0),
              ],
            ),
          ),
          data: (investments) {
            if (investments == null) {
              return EmptyState(
                icon: Icons.show_chart_rounded,
                title: l10n.emptyDashboardTitle,
                message: l10n.emptyDashboardMessage,
                actionLabel: l10n.emptyDashboardAction,
                onAction: () => context.push(AppRoutes.update),
              );
            }
            if (!investments.hasInvestments) {
              return EmptyState(
                icon: Icons.show_chart_rounded,
                title: l10n.investmentsEmptyTitle,
                message: l10n.investmentsEmptyMessage,
                actionLabel: l10n.goToAssets,
                actionIcon: Icons.arrow_forward_rounded,
                onAction: () => context.go(AppRoutes.assets),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) => _InvestmentsContent(
                data: investments,
                wide: constraints.maxWidth >= 900,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InvestmentsContent extends ConsumerWidget {
  const _InvestmentsContent({required this.data, required this.wide});

  final InvestmentsData data;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final currentMonth = ref.watch(currentMonthProvider);
    final gap = wide ? AppSpacing.xl : AppSpacing.sm;

    final yearly = data.yearly;
    final yearlyComparedTo = yearly.change.comparedTo;
    final yearlyTitle = yearly.isFullYear || yearlyComparedTo == null
        ? l10n.yearlyChange
        : l10n.sinceMonth(MonthLabels.name(yearlyComparedTo));

    final hero = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.investmentsValue, style: text.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        AnimatedMoneyText(
          data.value,
          style: wide ? text.displayLarge : text.displayMedium,
        ),
      ],
    );

    final stats = Row(
      children: [
        Expanded(
          child: _StatCard(
            title: data.month == currentMonth
                ? l10n.monthlyChange
                : l10n.lastMonthChange,
            change: data.monthly,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _StatCard(title: yearlyTitle, change: yearly.change),
        ),
      ],
    );

    final chart = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = SectionHeader(l10n.investmentsChartTitle);
              final selector = RangeSelector(
                value: ref.watch(investmentsRangeProvider),
                onChanged: ref.read(investmentsRangeProvider.notifier).select,
              );
              return constraints.maxWidth < 440
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        const SizedBox(height: AppSpacing.xs),
                        selector,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: title),
                        selector,
                      ],
                    );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          ValueLineChart(
            points: ref.watch(investmentsSeriesProvider),
            title: l10n.investmentsChartTitle,
            height: wide ? 320 : 220,
          ),
        ],
      ),
    );

    final breakdown = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            l10n.breakdownTitle,
            subtitle: MonthLabels.long(data.month),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.breakdown.isEmpty)
            Text(l10n.noInvestmentValues, style: text.bodySmall)
          else
            ProportionBars(items: data.breakdown),
        ],
      ),
    );

    if (!wide) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          PageTitle(l10n.investmentsTitle),
          const SizedBox(height: AppSpacing.xl),
          hero,
          const SizedBox(height: AppSpacing.lg),
          stats,
          SizedBox(height: gap),
          chart,
          SizedBox(height: gap),
          breakdown,
        ],
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitle(l10n.investmentsTitle),
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 5, child: hero),
                SizedBox(width: gap),
                Expanded(flex: 7, child: stats),
              ],
            ),
            SizedBox(height: gap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: chart),
                SizedBox(width: gap),
                Expanded(flex: 5, child: breakdown),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.change});

  final String title;
  final Change change;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final absolute = change.absolute;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          if (absolute == null)
            DeltaBadge(change: change, style: text.bodyMedium)
          else ...[
            DeltaBadge(
              change: change,
              showPercent: false,
              style: text.titleMedium,
            ),
            if (change.percent != null)
              DeltaBadge(
                change: change,
                showAmount: false,
                style: text.bodySmall,
              ),
          ],
        ],
      ),
    );
  }
}
