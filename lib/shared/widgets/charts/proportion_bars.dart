import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/money/money_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../services/wealth_calculator.dart';
import '../money_text.dart';

/// Barre orizzontali di un solo colore: una serie, nessun colore in più.
class ProportionBars extends StatelessWidget {
  const ProportionBars({super.key, required this.items});

  final List<ItemShare> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final l10n = context.l10n;
    return Column(
      children: [
        for (final item in items)
          Semantics(
            label:
                '${item.name}: ${MoneyFormat.spoken(item.value)}, '
                '${l10n.shareOfTotal('${item.percent}%')}',
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.name, style: text.bodyMedium)),
                      MoneyText(
                        item.value,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${item.percent}%',
                          textAlign: TextAlign.end,
                          style: text.labelMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.percent / 100,
                      minHeight: 8,
                      color: colors.chart.first,
                      backgroundColor: colors.surfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
