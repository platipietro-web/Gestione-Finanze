import 'year_month.dart';

/// Nomi dei mesi in italiano, senza dipendere dall'inizializzazione di intl.
abstract final class MonthLabels {
  static const _names = [
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre',
  ];
  static const _short = [
    'gen',
    'feb',
    'mar',
    'apr',
    'mag',
    'giu',
    'lug',
    'ago',
    'set',
    'ott',
    'nov',
    'dic',
  ];

  /// `settembre`
  static String name(YearMonth month) => _names[month.month - 1];

  /// `Settembre 2026`
  static String long(YearMonth month) =>
      '${_capitalize(name(month))} ${month.year}';

  /// `settembre 2026`, per l'uso a metà frase.
  static String inSentence(YearMonth month) => '${name(month)} ${month.year}';

  /// `set`
  static String short(YearMonth month) => _short[month.month - 1];

  /// `set 26`
  static String shortWithYear(YearMonth month) =>
      '${short(month)} ${(month.year % 100).toString().padLeft(2, '0')}';

  /// `rispetto ad agosto`, `rispetto a luglio`: la "d" eufonica solo
  /// davanti alla stessa vocale.
  static String comparedTo(YearMonth month) {
    final monthName = name(month);
    return monthName.startsWith('a')
        ? 'rispetto ad $monthName'
        : 'rispetto a $monthName';
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
