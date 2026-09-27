import 'package:flutter/foundation.dart';

import 'money.dart';

/// Percentuale espressa in punti base: 179 = 1,79 %.
@immutable
final class Percent implements Comparable<Percent> {
  const Percent(this.basisPoints);

  final int basisPoints;

  bool get isZero => basisPoints == 0;
  bool get isNegative => basisPoints < 0;
  bool get isPositive => basisPoints > 0;

  /// Variazione percentuale tra [current] e [previous].
  ///
  /// Si divide per il valore assoluto del precedente: così il segno indica
  /// sempre se la situazione è migliorata, anche con patrimonio negativo.
  /// Restituisce `null` se il precedente è zero (percentuale non definita).
  static Percent? change({required Money current, required Money previous}) {
    if (previous.isZero) return null;
    final numerator =
        BigInt.from(current.cents - previous.cents) * BigInt.from(10000);
    final denominator = BigInt.from(previous.cents.abs());
    return Percent(roundedDivision(numerator, denominator));
  }

  /// Quota di [part] su [total]. [total] deve essere positivo.
  static Percent share({required Money part, required Money total}) {
    assert(total.isPositive, 'Il totale deve essere positivo');
    return Percent(
      roundedDivision(
        BigInt.from(part.cents) * BigInt.from(10000),
        BigInt.from(total.cents),
      ),
    );
  }

  @override
  int compareTo(Percent other) => basisPoints.compareTo(other.basisPoints);

  @override
  bool operator ==(Object other) =>
      other is Percent && other.basisPoints == basisPoints;

  @override
  int get hashCode => basisPoints.hashCode;

  @override
  String toString() => 'Percent($basisPoints bp)';
}

/// Divisione intera arrotondata "dalla metà in su, lontano da zero":
/// 1,785 diventa 1,79 e -1,785 diventa -1,79.
int roundedDivision(BigInt numerator, BigInt denominator) {
  if (denominator == BigInt.zero) {
    throw ArgumentError.value(denominator, 'denominator', 'non può essere 0');
  }
  final negative = numerator.isNegative != denominator.isNegative;
  final n = numerator.abs();
  final d = denominator.abs();
  var quotient = n ~/ d;
  final remainder = n - quotient * d;
  if (remainder * BigInt.two >= d) quotient += BigInt.one;
  final value = quotient.toInt();
  return negative ? -value : value;
}

/// Ripartisce [total] unità in proporzione ai [weights] con il metodo del
/// resto maggiore: la somma dei risultati è sempre esattamente [total].
///
/// Serve, per esempio, a far sommare a 100 le percentuali del donut.
List<int> largestRemainder(List<int> weights, int total) {
  final sum = weights.fold<int>(0, (acc, w) => acc + (w > 0 ? w : 0));
  if (sum <= 0 || weights.isEmpty) return List.filled(weights.length, 0);

  final bigSum = BigInt.from(sum);
  final bigTotal = BigInt.from(total);
  final floors = <int>[];
  final remainders = <BigInt>[];
  for (final weight in weights) {
    final scaled = BigInt.from(weight > 0 ? weight : 0) * bigTotal;
    floors.add((scaled ~/ bigSum).toInt());
    remainders.add(scaled.remainder(bigSum));
  }

  var missing = total - floors.fold<int>(0, (acc, f) => acc + f);
  final order = List<int>.generate(weights.length, (i) => i)
    ..sort((a, b) {
      final byRemainder = remainders[b].compareTo(remainders[a]);
      if (byRemainder != 0) return byRemainder;
      final byWeight = weights[b].compareTo(weights[a]);
      if (byWeight != 0) return byWeight;
      return a.compareTo(b);
    });
  for (final index in order) {
    if (missing <= 0) break;
    if (weights[index] <= 0) continue;
    floors[index] += 1;
    missing -= 1;
  }
  return floors;
}
