import 'package:flutter/material.dart';

import '../../core/money/money.dart';
import '../../core/money/money_format.dart';
import '../../core/theme/app_theme.dart';

/// Importo formattato all'italiana, con lettura corretta per lo screen reader.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.money, {
    super.key,
    this.style,
    this.whole = true,
    this.signed = false,
    this.textAlign,
    this.fit = false,
  });

  final Money money;
  final TextStyle? style;

  /// Euro interi (riepiloghi) oppure con i centesimi se presenti (dettagli).
  final bool whole;
  final bool signed;
  final TextAlign? textAlign;

  /// Riduce il testo invece di andare a capo quando lo spazio non basta.
  final bool fit;

  @override
  Widget build(BuildContext context) {
    final text = whole
        ? MoneyFormat.whole(money, signed: signed)
        : MoneyFormat.format(money, signed: signed);
    Widget child = Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: 1,
      softWrap: false,
    );
    if (fit) {
      child = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: textAlign == TextAlign.end
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: child,
      );
    }
    return Semantics(
      label: MoneyFormat.spoken(money),
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Importo grande che, quando cambia, scorre dolcemente al nuovo valore.
class AnimatedMoneyText extends StatelessWidget {
  const AnimatedMoneyText(this.money, {super.key, this.style});

  final Money money;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: MoneyFormat.spoken(money),
      excludeSemantics: true,
      child: TweenAnimationBuilder<int>(
        tween: IntTween(end: money.cents),
        duration: AppMotion.of(context, AppMotion.slow),
        curve: AppMotion.curve,
        builder: (context, cents, _) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            MoneyFormat.whole(Money(cents)),
            style: style,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
