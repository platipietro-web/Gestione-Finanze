import 'money.dart';

enum MoneyParseError { invalid, negative, tooManyDecimals, tooLarge }

class MoneyParseException implements Exception {
  const MoneyParseException(this.error);

  final MoneyParseError error;

  @override
  String toString() => 'MoneyParseException($error)';
}

/// Legge un importo scritto dall'utente, senza mai passare da `double`.
///
/// Regole (formato italiano, con un po' di tolleranza):
/// - `12.500` → 12.500,00 (punto seguito da 3 cifre: migliaia)
/// - `12500,5` → 12.500,50 (virgola: decimali)
/// - `12.50` → 12,50 (punto seguito da 1–2 cifre finali: decimali)
/// - `€ 1.250.000` → simbolo e spazi ignorati
/// - campo vuoto → 0
abstract final class MoneyParser {
  static final _allowed = RegExp(r'^[0-9.,]+$');
  static final _ignored = RegExp('[€\\s  \']');

  static Money parse(String input) {
    var text = input.replaceAll(_ignored, '');
    if (text.isEmpty) return Money.zero;
    if (text.startsWith('-') || text.startsWith('−')) {
      throw const MoneyParseException(MoneyParseError.negative);
    }
    if (text.startsWith('+')) text = text.substring(1);
    if (!_allowed.hasMatch(text)) {
      throw const MoneyParseException(MoneyParseError.invalid);
    }

    String integerPart;
    var decimalPart = '';
    if (text.contains(',')) {
      final parts = text.split(',');
      if (parts.length != 2 || parts[1].contains('.')) {
        throw const MoneyParseException(MoneyParseError.invalid);
      }
      if (!_validGrouping(parts[0])) {
        throw const MoneyParseException(MoneyParseError.invalid);
      }
      integerPart = parts[0].replaceAll('.', '');
      decimalPart = parts[1];
    } else if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length == 2 && parts[1].length <= 2) {
        integerPart = parts[0];
        decimalPart = parts[1];
      } else {
        if (!_validGrouping(text)) {
          throw const MoneyParseException(MoneyParseError.invalid);
        }
        integerPart = text.replaceAll('.', '');
      }
    } else {
      integerPart = text;
    }

    if (integerPart.isEmpty) integerPart = '0';
    if (decimalPart.length > 2) {
      throw const MoneyParseException(MoneyParseError.tooManyDecimals);
    }
    if (integerPart.length > 12) {
      throw const MoneyParseException(MoneyParseError.tooLarge);
    }

    final euros = int.parse(integerPart);
    final cents = decimalPart.isEmpty
        ? 0
        : int.parse(decimalPart.padRight(2, '0'));
    final total = euros * 100 + cents;
    if (total > Money.maxCents) {
      throw const MoneyParseException(MoneyParseError.tooLarge);
    }
    return Money(total);
  }

  /// `null` se il testo è valido, altrimenti il tipo di errore.
  static MoneyParseError? validate(String input) {
    try {
      parse(input);
      return null;
    } on MoneyParseException catch (e) {
      return e.error;
    }
  }

  /// Con i punti come separatori, i gruppi dopo il primo devono avere 3 cifre.
  static bool _validGrouping(String text) {
    if (!text.contains('.')) return true;
    final groups = text.split('.');
    if (groups.first.isEmpty || groups.first.length > 3) return false;
    return groups.skip(1).every((group) => group.length == 3);
  }
}
