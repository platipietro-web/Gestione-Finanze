import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/money/money.dart';
import '../../../core/money/money_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/time/month_labels.dart';
import '../../../core/time/year_month.dart';
import '../../services/wealth_calculator.dart';

/// Grafico a linea di una sola serie mensile, con tooltip e animazioni.
///
/// L'asse x usa il numero progressivo del mese: i mesi mancanti restano
/// spazi proporzionali, non vengono compressi.
class ValueLineChart extends StatelessWidget {
  const ValueLineChart({
    super.key,
    required this.points,
    required this.title,
    this.height = 240,
  });

  final List<ChartPoint> points;

  /// Nome della serie, usato per lo screen reader.
  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final l10n = context.l10n;
    if (points.isEmpty) return SizedBox(height: height);
    if (points.length == 1) {
      return SizedBox(
        height: height,
        child: _SinglePoint(
          point: points.first,
          message: l10n.chartSinglePoint,
        ),
      );
    }

    final series = colors.chart.first;
    final minX = points.first.month.index.toDouble();
    final maxX = points.last.month.index.toDouble();
    final values = [for (final p in points) p.value.toChartValue()];
    final bounds = _AxisBounds.from(values);
    final spanMonths = (maxX - minX).round();
    final xInterval = math.max(1, (spanMonths / 5).ceil()).toDouble();
    final showYear = spanMonths >= 12;
    final caption = text.labelSmall;

    final first = points.first;
    final last = points.last;
    final semantics = l10n.chartSemantics(
      title,
      MoneyFormat.spoken(first.value),
      MonthLabels.long(first.month),
      MoneyFormat.spoken(last.value),
      MonthLabels.long(last.month),
    );

    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: RepaintBoundary(
        child: SizedBox(
          height: height,
          child: LineChart(
            duration: AppMotion.of(context, AppMotion.slow),
            curve: AppMotion.curve,
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: bounds.min,
              maxY: bounds.max,
              clipData: const FlClipData.horizontal(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: bounds.interval,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colors.border,
                  strokeWidth: 1,
                  dashArray: const [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    interval: bounds.interval,
                    maxIncluded: false,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        MoneyFormat.compact(Money((value * 100).round())),
                        style: caption,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: xInterval,
                    maxIncluded: false,
                    getTitlesWidget: (value, meta) {
                      if ((value - value.round()).abs() > 0.01) {
                        return const SizedBox.shrink();
                      }
                      final month = YearMonth.fromIndex(value.round());
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          showYear
                              ? MonthLabels.shortWithYear(month)
                              : MonthLabels.short(month),
                          style: caption,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => colors.textPrimary,
                  tooltipBorderRadius: AppRadius.smAll,
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  maxContentWidth: 200,
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      LineTooltipItem(
                        '${MonthLabels.long(points[spot.spotIndex].month)}\n',
                        (caption ?? const TextStyle()).copyWith(
                          color: colors.background.withValues(alpha: 0.75),
                        ),
                        children: [
                          TextSpan(
                            text: MoneyFormat.whole(
                              points[spot.spotIndex].value,
                            ),
                            style: (text.labelLarge ?? const TextStyle())
                                .copyWith(color: colors.background),
                          ),
                        ],
                      ),
                  ],
                ),
                getTouchedSpotIndicator: (bar, indexes) => [
                  for (final _ in indexes)
                    TouchedSpotIndicatorData(
                      FlLine(
                        color: colors.textTertiary,
                        strokeWidth: 1,
                        dashArray: const [3, 3],
                      ),
                      FlDotData(
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                              radius: 5,
                              color: series,
                              strokeColor: colors.surface,
                              strokeWidth: 2,
                            ),
                      ),
                    ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (final p in points)
                      FlSpot(p.month.index.toDouble(), p.value.toChartValue()),
                  ],
                  isCurved: true,
                  curveSmoothness: 0.2,
                  preventCurveOverShooting: true,
                  color: series,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    checkToShowDot: (spot, bar) => spot == bar.spots.last,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 4.5,
                          color: series,
                          strokeColor: colors.surface,
                          strokeWidth: 2,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        series.withValues(alpha: 0.18),
                        series.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SinglePoint extends StatelessWidget {
  const _SinglePoint({required this.point, required this.message});

  final ChartPoint point;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: colors.chart.first,
            shape: BoxShape.circle,
            border: Border.all(color: colors.surface, width: 3),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          MonthLabels.long(point.month),
          style: context.textStyles.labelSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall,
        ),
      ],
    );
  }
}

/// Limiti dell'asse y arrotondati a valori "belli", con 4 intervalli circa.
class _AxisBounds {
  const _AxisBounds(this.min, this.max, this.interval);

  factory _AxisBounds.from(List<double> values) {
    var low = values.reduce(math.min);
    var high = values.reduce(math.max);
    final span = high - low;
    final padding = span == 0
        ? math.max(high.abs() * 0.05, 100.0)
        : span * 0.12;
    low -= padding;
    high += padding;
    if (values.every((v) => v >= 0) && low < 0) low = 0;
    final interval = _niceStep((high - low) / 4);
    return _AxisBounds(
      (low / interval).floorToDouble() * interval,
      (high / interval).ceilToDouble() * interval,
      interval,
    );
  }

  final double min;
  final double max;
  final double interval;

  static double _niceStep(double raw) {
    if (raw <= 0) return 1;
    final exponent = math
        .pow(10, (math.log(raw) / math.ln10).floor())
        .toDouble();
    final fraction = raw / exponent;
    final nice = fraction <= 1
        ? 1
        : fraction <= 2
        ? 2
        : fraction <= 2.5
        ? 2.5
        : fraction <= 5
        ? 5
        : 10;
    return nice * exponent;
  }
}
