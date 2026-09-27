import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/time/month_labels.dart';
import 'package:patrimonio/core/time/year_month.dart';

void main() {
  test('aritmetica dei mesi attraverso gli anni', () {
    expect(const YearMonth(2026, 1).previous, const YearMonth(2025, 12));
    expect(const YearMonth(2025, 12).next, const YearMonth(2026, 1));
    expect(const YearMonth(2026, 9).addMonths(-12), const YearMonth(2025, 9));
    expect(const YearMonth(2026, 9).monthsSince(const YearMonth(2025, 6)), 15);
  });

  test('parsing e formato del database', () {
    expect(YearMonth.tryParse('2026-09'), const YearMonth(2026, 9));
    expect(YearMonth.tryParse('2026-09-01'), const YearMonth(2026, 9));
    expect(YearMonth.tryParse('2026-13'), isNull);
    expect(YearMonth.tryParse('ciao'), isNull);
    expect(const YearMonth(2026, 9).dbDate, '2026-09-01');
  });

  test('etichette italiane', () {
    expect(MonthLabels.long(const YearMonth(2026, 9)), 'Settembre 2026');
    expect(MonthLabels.inSentence(const YearMonth(2026, 9)), 'settembre 2026');
    expect(MonthLabels.shortWithYear(const YearMonth(2026, 1)), 'gen 26');
    expect(
      MonthLabels.comparedTo(const YearMonth(2026, 8)),
      'rispetto ad agosto',
    );
    expect(
      MonthLabels.comparedTo(const YearMonth(2026, 7)),
      'rispetto a luglio',
    );
  });
}
