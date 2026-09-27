import 'money.dart';
import 'percent.dart';

/// Formattazione italiana di importi e percentuali, senza passare da `double`.
abstract final class MoneyFormat {
  /// Segno meno tipografico (U+2212), più leggibile del trattino.
  static const minus = '−';

  /// `€184.520`, `€184.520,50`, `−€52.000`.
  ///
  /// I centesimi compaiono solo se diversi da zero, a meno di [alwaysShowCents].
  static String format(
    Money money, {
    bool signed = false,
    bool alwaysShowCents = false,
  }) {
    final absCents = money.cents.abs();
    final euros = absCents ~/ 100;
    final cents = absCents % 100;
    final buffer = StringBuffer(_sign(money.cents, signed))
      ..write('€')
      ..write(groupThousands(euros));
    if (alwaysShowCents || cents != 0) {
      buffer
        ..write(',')
        ..write(cents.toString().padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// Euro interi, arrotondati: per riepiloghi, card e grafici.
  static String whole(Money money, {bool signed = false}) {
    final euros = roundedDivision(BigInt.from(money.cents), BigInt.from(100));
    return '${_sign(euros, signed)}€${groupThousands(euros.abs())}';
  }

  /// Forma compatta per gli assi dei grafici: `€950`, `€9,5k`, `€185k`, `€1,2M`.
  static String compact(Money money) {
    final euros = roundedDivision(BigInt.from(money.cents), BigInt.from(100));
    final sign = euros < 0 ? minus : '';
    final value = euros.abs();
    if (value >= 1000000) {
      return '$sign€${_oneDecimal(value, 1000000)}M';
    }
    if (value >= 10000) {
      final thousands = roundedDivision(BigInt.from(value), BigInt.from(1000));
      return '$sign€${thousands}k';
    }
    if (value >= 1000) {
      return '$sign€${_oneDecimal(value, 1000)}k';
    }
    return '$sign€$value';
  }

  /// Testo per i campi di inserimento: `15.520` o `15.520,50`, senza simbolo.
  static String input(Money money) {
    final absCents = money.cents.abs();
    final euros = groupThousands(absCents ~/ 100);
    final cents = absCents % 100;
    return cents == 0 ? euros : '$euros,${cents.toString().padLeft(2, '0')}';
  }

  /// Versione per gli screen reader: `184.520 euro`, `meno 52.000 euro`.
  static String spoken(Money money) {
    final absCents = money.cents.abs();
    final cents = absCents % 100;
    final base = groupThousands(absCents ~/ 100);
    final amount = cents == 0
        ? base
        : '$base,${cents.toString().padLeft(2, '0')}';
    return '${money.isNegative ? 'meno ' : ''}$amount euro';
  }

  /// `1.234.567`
  static String groupThousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? minus : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String _sign(int value, bool signed) {
    if (value < 0) return minus;
    if (signed && value > 0) return '+';
    return '';
  }

  static String _oneDecimal(int value, int unit) {
    final tenths = roundedDivision(
      BigInt.from(value) * BigInt.from(10),
      BigInt.from(unit),
    );
    final whole = tenths ~/ 10;
    final decimal = tenths % 10;
    return decimal == 0 ? '$whole' : '$whole,$decimal';
  }
}

abstract final class PercentFormat {
  /// `+1,79%`, `−0,5%`, `0%`. [decimals] può essere 0, 1 o 2.
  static String format(
    Percent percent, {
    bool signed = true,
    int decimals = 2,
  }) {
    assert(decimals >= 0 && decimals <= 2, 'Da 0 a 2 decimali');
    final divisor = decimals == 2 ? 1 : (decimals == 1 ? 10 : 100);
    final scaled = roundedDivision(
      BigInt.from(percent.basisPoints),
      BigInt.from(divisor),
    );
    final sign = scaled < 0
        ? MoneyFormat.minus
        : (signed && scaled > 0 ? '+' : '');
    final absValue = scaled.abs();
    if (decimals == 0) return '$sign$absValue%';
    final unit = decimals == 2 ? 100 : 10;
    final whole = absValue ~/ unit;
    final fraction = (absValue % unit).toString().padLeft(decimals, '0');
    return '$sign$whole,$fraction%';
  }

  /// Versione per gli screen reader: `più 1,79 per cento`.
  static String spoken(Percent percent) {
    final text = format(percent, signed: false).replaceAll('%', '');
    final prefix = percent.isNegative
        ? 'meno '
        : (percent.isPositive ? 'più ' : '');
    return '$prefix${text.replaceAll(MoneyFormat.minus, '')} per cento';
  }
}
