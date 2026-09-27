import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/time/month_labels.dart';
import '../../../../core/time/year_month.dart';
import '../../../../shared/widgets/dialogs.dart';

/// Primo anno selezionabile: abbastanza indietro per ricostruire lo storico.
const _firstYear = 2000;

/// Bottone con il mese dell'aggiornamento. Toccandolo si sceglie un altro
/// mese, anche passato; i mesi futuri non sono disponibili.
class MonthButton extends StatelessWidget {
  const MonthButton({
    super.key,
    required this.month,
    required this.currentMonth,
    required this.savedMonths,
    required this.onSelected,
  });

  final YearMonth month;
  final YearMonth currentMonth;
  final Set<YearMonth> savedMonths;
  final ValueChanged<YearMonth> onSelected;

  Future<void> _open(BuildContext context) async {
    final picked = await showAdaptiveSheet<YearMonth>(
      context,
      builder: (context) => _MonthPicker(
        selected: month,
        currentMonth: currentMonth,
        savedMonths: savedMonths,
      ),
    );
    if (picked != null && picked != month) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = MonthLabels.long(month);
    return Semantics(
      button: true,
      label: context.l10n.monthButtonSemantics(label),
      excludeSemantics: true,
      child: Material(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.pill,
        child: InkWell(
          borderRadius: AppRadius.pill,
          onTap: () => _open(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(label, style: context.textStyles.titleMedium),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Icon(Icons.expand_more_rounded, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthPicker extends StatefulWidget {
  const _MonthPicker({
    required this.selected,
    required this.currentMonth,
    required this.savedMonths,
  });

  final YearMonth selected;
  final YearMonth currentMonth;
  final Set<YearMonth> savedMonths;

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  late int _year = widget.selected.year;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final colors = context.colors;
    final lastYear = widget.currentMonth.year;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.chooseMonth, style: text.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.chooseMonthHint, style: text.bodySmall),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            IconButton(
              tooltip: l10n.previousYear,
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _year > _firstYear
                  ? () => setState(() => _year--)
                  : null,
            ),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  '$_year',
                  textAlign: TextAlign.center,
                  style: text.titleLarge,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.nextYear,
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _year < lastYear
                  ? () => setState(() => _year++)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          childAspectRatio: 2.2,
          children: [
            for (var m = 1; m <= 12; m++)
              _MonthCell(
                month: YearMonth(_year, m),
                selected: YearMonth(_year, m) == widget.selected,
                enabled: !YearMonth(_year, m).isAfter(widget.currentMonth),
                saved: widget.savedMonths.contains(YearMonth(_year, m)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                l10n.monthAlreadyUpdatedLegend,
                style: text.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.month,
    required this.selected,
    required this.enabled,
    required this.saved,
  });

  final YearMonth month;
  final bool selected;
  final bool enabled;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final short = MonthLabels.short(month);
    final label = short[0].toUpperCase() + short.substring(1);
    final foreground = !enabled
        ? colors.textTertiary.withValues(alpha: 0.5)
        : selected
        ? colors.onPrimary
        : colors.textPrimary;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: [
        MonthLabels.long(month),
        if (saved) context.l10n.monthAlreadyUpdated,
      ].join(', '),
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.primary : colors.surfaceMuted,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: enabled ? () => Navigator.of(context).pop(month) : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: text.labelLarge?.copyWith(color: foreground)),
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: saved
                      ? (selected ? colors.onPrimary : colors.primary)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
