import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/app_theme.dart';
import '../../services/wealth_calculator.dart';
import '../money_text.dart';

/// Donut della distribuzione con legenda sempre visibile: nome,
/// percentuale e valore. L'identità di una fetta non dipende solo dal colore.
class DistributionDonut extends StatefulWidget {
  const DistributionDonut({
    super.key,
    required this.slices,
    required this.total,
    this.size = 176,
    this.horizontal = false,
  });

  final List<DistributionSlice> slices;

  /// Patrimonio lordo, mostrato al centro.
  final Money total;
  final double size;

  /// Legenda accanto al grafico invece che sotto.
  final bool horizontal;

  @override
  State<DistributionDonut> createState() => _DistributionDonutState();
}

class _DistributionDonutState extends State<DistributionDonut> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final l10n = context.l10n;
    final size = widget.size;

    final chart = SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
            child: RepaintBoundary(
              child: PieChart(
                duration: AppMotion.of(context, AppMotion.slow),
                curve: AppMotion.curve,
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 2,
                  centerSpaceRadius: size * 0.31,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final index =
                          response?.touchedSection?.touchedSectionIndex;
                      final next =
                          event.isInterestedForInteractions &&
                              index != null &&
                              index >= 0
                          ? index
                          : null;
                      if (next != _touched) setState(() => _touched = next);
                    },
                  ),
                  sections: [
                    for (var i = 0; i < widget.slices.length; i++)
                      PieChartSectionData(
                        value: widget.slices[i].value.toChartValue(),
                        color: colors.seriesColor(widget.slices[i].colorSlot),
                        radius: _touched == i ? size * 0.2 : size * 0.17,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: size * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.totalAssets, style: text.labelSmall),
                MoneyText(
                  widget.total,
                  style: text.titleSmall,
                  textAlign: TextAlign.center,
                  fit: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final legend = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.slices.length; i++)
          _LegendRow(
            slice: widget.slices[i],
            label: widget.slices[i].label ?? l10n.otherCategory,
            highlighted: _touched == i,
          ),
      ],
    );

    if (widget.horizontal) {
      return Row(
        children: [
          chart,
          const SizedBox(width: AppSpacing.xl),
          Expanded(child: legend),
        ],
      );
    }
    return Column(
      children: [
        chart,
        const SizedBox(height: AppSpacing.lg),
        legend,
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.label,
    required this.highlighted,
  });

  final DistributionSlice slice;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.fast),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: highlighted ? colors.surfaceMuted : Colors.transparent,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: colors.seriesColor(slice.colorSlot),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Con testo molto grande percentuale e valore vanno a capo.
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              children: [
                Text(label, style: text.bodyMedium),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${slice.percent}%', style: text.labelMedium),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: MoneyText(
                        slice.value,
                        fit: true,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
