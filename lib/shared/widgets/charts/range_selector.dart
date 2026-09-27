import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../services/wealth_calculator.dart';

/// Scelta dell'intervallo del grafico: 3M · 6M · 1A · 3A · Tutto.
class RangeSelector extends StatelessWidget {
  const RangeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ChartRange value;
  final ValueChanged<ChartRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String short(ChartRange r) => switch (r) {
      ChartRange.threeMonths => l10n.rangeThreeMonths,
      ChartRange.sixMonths => l10n.rangeSixMonths,
      ChartRange.oneYear => l10n.rangeOneYear,
      ChartRange.threeYears => l10n.rangeThreeYears,
      ChartRange.all => l10n.rangeAll,
    };
    String long(ChartRange r) => switch (r) {
      ChartRange.threeMonths => l10n.rangeThreeMonthsLong,
      ChartRange.sixMonths => l10n.rangeSixMonthsLong,
      ChartRange.oneYear => l10n.rangeOneYearLong,
      ChartRange.threeYears => l10n.rangeThreeYearsLong,
      ChartRange.all => l10n.rangeAllLong,
    };
    return Wrap(
      spacing: 2,
      children: [
        for (final range in ChartRange.values)
          _RangePill(
            label: short(range),
            semanticLabel: long(range),
            selected: range == value,
            onTap: () => onChanged(range),
          ),
      ],
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: Tooltip(
        message: semanticLabel,
        waitDuration: const Duration(milliseconds: 600),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.pill,
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? colors.primaryContainer : Colors.transparent,
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              label,
              style: context.textStyles.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? colors.onPrimaryContainer
                    : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
