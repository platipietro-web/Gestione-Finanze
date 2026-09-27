import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/money/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/time/month_labels.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../../shared/services/wealth_calculator.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/charts/distribution_donut.dart';
import '../../../../shared/widgets/charts/range_selector.dart';
import '../../../../shared/widgets/charts/value_line_chart.dart';
import '../../../../shared/widgets/delta_badge.dart';
import '../../../../shared/widgets/money_text.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../application/dashboard_providers.dart';

/// Testo neutro dopo la variazione del patrimonio netto.
String changeSuffix(BuildContext context, WidgetRef ref, TimelinePoint latest) {
  final comparedTo = latest.netWorthChange.comparedTo;
  if (comparedTo == null) return '';
  return isThisMonthComparison(latest, ref.watch(currentMonthProvider))
      ? context.l10n.thisMonth
      : MonthLabels.comparedTo(comparedTo);
}

/// Il numero principale: patrimonio netto e variazione.
class NetWorthHero extends ConsumerWidget {
  const NetWorthHero({super.key, required this.latest, this.large = false});

  final TimelinePoint latest;
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.textStyles;
    final suffix = changeSuffix(context, ref, latest);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.netWorth, style: text.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        AnimatedMoneyText(
          latest.totals.netWorth,
          style: large ? text.displayLarge : text.displayMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        DeltaBadge(
          change: latest.netWorthChange,
          suffix: suffix.isEmpty ? null : suffix,
        ),
      ],
    );
  }
}

class ReminderBanner extends StatelessWidget {
  const ReminderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: AppRadius.mdAll,
        ),
        // Con testo molto grande il bottone va sotto il messaggio.
        child: OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          overflowAlignment: OverflowBarAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 20,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    l10n.reminderMessage,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: colors.onPrimaryContainer,
              ),
              onPressed: () => context.push(AppRoutes.update),
              child: Text(l10n.reminderAction),
            ),
          ],
        ),
      ),
    );
  }
}

class NetWorthChartCard extends ConsumerWidget {
  const NetWorthChartCard({super.key, this.chartHeight = 220});

  final double chartHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final points = ref.watch(netWorthSeriesProvider);
    final range = ref.watch(dashboardRangeProvider);
    final title = SectionHeader(l10n.netWorth);
    final selector = RangeSelector(
      value: range,
      onChanged: ref.read(dashboardRangeProvider.notifier).select,
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth < 420
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
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ValueLineChart(
            points: points,
            title: l10n.netWorth,
            height: chartHeight,
          ),
        ],
      ),
    );
  }
}

class CategoryValueCard extends StatelessWidget {
  const CategoryValueCard({
    super.key,
    required this.name,
    required this.value,
    required this.change,
    this.isLiability = false,
    this.onTap,
  });

  final String name;
  final Money value;
  final Change change;
  final bool isLiability;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: text.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          MoneyText(
            isLiability ? -value : value,
            style: text.titleLarge,
            fit: true,
          ),
          const SizedBox(height: AppSpacing.xxs),
          DeltaBadge(
            change: change,
            inverse: isLiability,
            showPercent: false,
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Griglia delle categorie più la card delle passività.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.data,
    required this.columns,
    this.gap = AppSpacing.sm,
  });

  final DashboardData data;
  final int columns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = <Widget>[
      for (final category in data.assetCategories)
        CategoryValueCard(
          name: category.name,
          value: category.value,
          change: category.change,
          onTap: () => context.go(AppRoutes.assets),
        ),
      if (data.latest.totals.liabilities.isPositive ||
          data.liabilitiesChange.absolute?.isZero == false)
        CategoryValueCard(
          name: l10n.totalLiabilities,
          value: data.latest.totals.liabilities,
          change: data.liabilitiesChange,
          isLiability: true,
          onTap: () => context.go(AppRoutes.assets),
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

class DistributionCard extends StatelessWidget {
  const DistributionCard({
    super.key,
    required this.data,
    this.horizontal = false,
  });

  final DashboardData data;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(l10n.distributionTitle),
          const SizedBox(height: AppSpacing.lg),
          if (data.distribution.isEmpty)
            Text(l10n.distributionEmpty, style: context.textStyles.bodySmall)
          else
            DistributionDonut(
              slices: data.distribution,
              total: data.latest.totals.assets,
              horizontal: horizontal,
            ),
        ],
      ),
    );
  }
}

class RecentUpdatesCard extends StatelessWidget {
  const RecentUpdatesCard({super.key, required this.points});

  final List<TimelinePoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            l10n.recentUpdates,
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.history),
              child: Text(l10n.seeAll),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final point in points)
            InkWell(
              borderRadius: AppRadius.smAll,
              onTap: () => context.go(AppRoutes.historyDetail(point.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        MonthLabels.long(point.month),
                        style: text.bodyMedium,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MoneyText(
                          point.totals.netWorth,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        DeltaBadge(
                          change: point.netWorthChange,
                          showPercent: false,
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        SkeletonBox(width: 140, height: 18),
        SizedBox(height: AppSpacing.xl),
        SkeletonBox(width: 110, height: 14),
        SizedBox(height: AppSpacing.xs),
        SkeletonBox(width: 240, height: 44, radius: AppRadius.md),
        SizedBox(height: AppSpacing.xs),
        SkeletonBox(width: 200),
        SizedBox(height: AppSpacing.xl),
        SkeletonCard(height: 280, lines: 0),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: SkeletonCard(height: 104, lines: 1)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: SkeletonCard(height: 104, lines: 1)),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        SkeletonCard(height: 220),
      ],
    );
  }
}
