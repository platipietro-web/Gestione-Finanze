import 'package:flutter/foundation.dart';

/// Un mese di calendario, per esempio settembre 2026.
@immutable
final class YearMonth implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month)
    : assert(month >= 1 && month <= 12, 'Mese non valido');

  factory YearMonth.fromDate(DateTime date) => YearMonth(date.year, date.month);

  factory YearMonth.now() => YearMonth.fromDate(DateTime.now());

  /// Inverso di [index].
  factory YearMonth.fromIndex(int index) =>
      YearMonth(index ~/ 12, index % 12 + 1);

  /// Accetta `2026-09` oppure `2026-09-01`.
  static YearMonth? tryParse(String? text) {
    if (text == null) return null;
    final match = RegExp(
      r'^(\d{4})-(\d{2})(?:-\d{2})?$',
    ).firstMatch(text.trim());
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) return null;
    return YearMonth(year, month);
  }

  final int year;
  final int month;

  /// Numero progressivo del mese: utile come asse x dei grafici e per
  /// calcolare distanze tra mesi.
  int get index => year * 12 + (month - 1);

  YearMonth addMonths(int months) => YearMonth.fromIndex(index + months);
  YearMonth get next => addMonths(1);
  YearMonth get previous => addMonths(-1);

  int monthsSince(YearMonth other) => index - other.index;

  bool isBefore(YearMonth other) => index < other.index;
  bool isAfter(YearMonth other) => index > other.index;

  DateTime get firstDay => DateTime(year, month);

  /// `2026-09`
  String get isoMonth => '$year-${month.toString().padLeft(2, '0')}';

  /// `2026-09-01`, il formato salvato nel database.
  String get dbDate => '$isoMonth-01';

  @override
  int compareTo(YearMonth other) => index.compareTo(other.index);

  @override
  bool operator ==(Object other) => other is YearMonth && other.index == index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => isoMonth;
}
