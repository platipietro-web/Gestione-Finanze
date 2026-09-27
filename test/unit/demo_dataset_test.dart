import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/money/money.dart';
import 'package:patrimonio/core/time/year_month.dart';
import 'package:patrimonio/shared/repositories/demo/demo_dataset.dart';
import 'package:patrimonio/shared/services/wealth_calculator.dart';

void main() {
  final store = DemoDataset.build(const YearMonth(2026, 9));
  final timeline = WealthCalculator.timeline(store.snapshots);

  test('24 mesi fino al mese scorso', () {
    expect(store.snapshots, hasLength(24));
    expect(timeline.latest!.month, const YearMonth(2026, 8));
    expect(timeline.points.first.month, const YearMonth(2024, 9));
  });

  test('gli ultimi 12 mesi seguono i valori della specifica', () {
    final last12 = timeline.points
        .skip(12)
        .map((p) => p.totals.netWorth)
        .toList();
    expect(last12.first, const Money.euros(145000));
    expect(last12.last, const Money.euros(180000));
    for (var k = 0; k < DemoDataset.months; k++) {
      expect(
        timeline.points[k].totals.netWorth,
        Money.euros(DemoDataset.netWorthTargets[k]),
      );
    }
  });

  test('nessun valore negativo o irrealistico', () {
    for (var k = 0; k < DemoDataset.months; k++) {
      final values = DemoDataset.valuesFor(k);
      expect(values.values.every((v) => v > 0), isTrue, reason: 'mese $k');
      expect(values['demo-item-current']!, greaterThan(1000));
    }
  });
}
