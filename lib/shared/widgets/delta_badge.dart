import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/money/money_format.dart';
import '../../core/theme/app_theme.dart';
import '../services/wealth_calculator.dart';

/// Variazione con freccia, segno e colore. Il colore non è mai l'unica
/// informazione: freccia e segno dicono la direzione.
class DeltaBadge extends StatelessWidget {
  const DeltaBadge({
    super.key,
    required this.change,
    this.suffix,
    this.inverse = false,
    this.showPercent = true,
    this.showAmount = true,
    this.percentDecimals = 2,
    this.style,
  });

  final Change change;

  /// Testo neutro dopo la variazione, per esempio "questo mese".
  final String? suffix;

  /// Per le passività una diminuzione è una buona notizia (verde).
  final bool inverse;
  final bool showPercent;

  /// Senza importo si mostra solo la percentuale (se definita).
  final bool showAmount;
  final int percentDecimals;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final base = (style ?? context.textStyles.bodyMedium)!;
    final neutral = base.copyWith(color: colors.textSecondary);

    if (change.isFirst) {
      return Text(l10n.firstUpdate, style: neutral);
    }
    final absolute = change.absolute!;
    final trend = change.trend;
    if (trend == Trend.flat) {
      return Text(
        '= ${l10n.unchanged}${suffix == null ? '' : ' $suffix'}',
        style: neutral,
      );
    }

    final isUp = trend == Trend.up;
    final isGood = isUp != inverse;
    final color = isGood ? colors.positive : colors.negative;
    final percent = change.percent;
    final percentValue = showPercent && percent != null
        ? PercentFormat.format(percent, decimals: percentDecimals)
        : null;
    final amountValue = showAmount || percentValue == null
        ? MoneyFormat.whole(absolute, signed: true)
        : null;
    final visible = [?amountValue, ?percentValue].join(' · ');

    final spokenAmount = MoneyFormat.spoken(absolute.abs());
    final spoken = [
      isUp ? l10n.trendUp(spokenAmount) : l10n.trendDown(spokenAmount),
      if (showPercent && percent != null) PercentFormat.spoken(percent),
      ?suffix,
    ].join(', ');

    return Semantics(
      label: spoken,
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${isUp ? '▲' : '▼'} $visible',
              style: base.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
            if (suffix != null) TextSpan(text: ' $suffix', style: neutral),
          ],
        ),
        maxLines: 2,
      ),
    );
  }
}
