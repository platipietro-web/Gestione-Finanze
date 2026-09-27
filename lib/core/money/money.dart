import 'package:flutter/foundation.dart';

/// Importo in centesimi di euro.
///
/// I calcoli monetari usano solo interi: nessun `double`, quindi nessun
/// errore di arrotondamento binario.
@immutable
final class Money implements Comparable<Money> {
  const Money(this.cents);

  const Money.euros(int euros) : cents = euros * 100;

  static const Money zero = Money(0);

  /// Limite accettato in inserimento: 100 miliardi di euro.
  /// Resta molto sotto il limite degli interi sicuri sul web (2^53).
  static const int maxCents = 10000000000000;

  final int cents;

  bool get isZero => cents == 0;
  bool get isNegative => cents < 0;
  bool get isPositive => cents > 0;

  Money abs() => Money(cents.abs());

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator -() => Money(-cents);
  bool operator <(Money other) => cents < other.cents;
  bool operator >(Money other) => cents > other.cents;
  bool operator <=(Money other) => cents <= other.cents;
  bool operator >=(Money other) => cents >= other.cents;

  static Money sum(Iterable<Money> values) {
    var total = 0;
    for (final value in values) {
      total += value.cents;
    }
    return Money(total);
  }

  /// Valore in euro come `double`: da usare solo per disegnare i grafici,
  /// mai per calcoli o per mostrare importi.
  double toChartValue() => cents / 100;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => 'Money($cents)';
}
