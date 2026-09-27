import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/money/money.dart';
import 'package:patrimonio/core/money/percent.dart';
import 'package:patrimonio/core/time/year_month.dart';
import 'package:patrimonio/shared/models/catalog.dart';
import 'package:patrimonio/shared/models/item_kind.dart';
import 'package:patrimonio/shared/models/snapshot.dart';
import 'package:patrimonio/shared/models/wealth_category.dart';
import 'package:patrimonio/shared/services/wealth_calculator.dart';

SnapshotItem asset(
  String name,
  int euros, {
  String cat = 'liq',
  bool investment = false,
  int order = 0,
}) => SnapshotItem(
  itemId: name,
  categoryId: cat,
  itemName: name,
  categoryName: cat,
  kind: ItemKind.asset,
  isInvestment: investment,
  categoryOrder: order,
  amount: Money.euros(euros),
);

SnapshotItem debt(String name, int euros) => SnapshotItem(
  itemId: name,
  categoryId: 'debts',
  itemName: name,
  categoryName: 'Debiti',
  kind: ItemKind.liability,
  categoryOrder: 9,
  amount: Money.euros(euros),
);

Snapshot snap(int year, int month, List<SnapshotItem> items) =>
    Snapshot(id: '$year-$month', month: YearMonth(year, month), items: items);

void main() {
  group('totali', () {
    test('patrimonio lordo, passività e netto', () {
      final totals = WealthCalculator.totals([
        asset('Conto', 12500),
        asset('ETF', 75000, cat: 'inv', investment: true),
        asset('Casa', 180000, cat: 'home'),
        debt('Mutuo', 120000),
        debt('Prestito', 5000),
      ]);
      expect(totals.assets, const Money.euros(267500));
      expect(totals.liabilities, const Money.euros(125000));
      expect(totals.netWorth, const Money.euros(142500));
      expect(totals.investments, const Money.euros(75000));
    });

    test('nessuna voce: tutto a zero', () {
      expect(WealthCalculator.totals(const []), SnapshotTotals.zero);
    });

    test('patrimonio netto negativo', () {
      final totals = WealthCalculator.totals([
        asset('Conto', 1000),
        debt('Prestito', 5000),
      ]);
      expect(totals.netWorth, const Money.euros(-4000));
    });
  });

  group('variazioni', () {
    test('primo aggiornamento: nessuna variazione', () {
      final timeline = WealthCalculator.timeline([
        snap(2026, 6, [asset('Conto', 1000)]),
      ]);
      final change = timeline.latest!.netWorthChange;
      expect(change.isFirst, isTrue);
      expect(change.trend, Trend.none);
      expect(change.percent, isNull);
    });

    test('variazione assoluta e percentuale tra due mesi', () {
      final timeline = WealthCalculator.timeline([
        snap(2026, 8, [asset('Conto', 181280)]),
        snap(2026, 9, [asset('Conto', 184520)]),
      ]);
      final change = timeline.latest!.netWorthChange;
      expect(change.absolute, const Money.euros(3240));
      expect(change.percent, const Percent(179));
      expect(change.comparedTo, const YearMonth(2026, 8));
      expect(change.trend, Trend.up);
    });

    test('mesi mancanti: confronto con l\'ultimo disponibile', () {
      final timeline = WealthCalculator.timeline([
        snap(2026, 9, [asset('Conto', 1200)]),
        snap(2026, 5, [asset('Conto', 1000)]),
      ]);
      expect(timeline.points.first.month, const YearMonth(2026, 5));
      expect(
        timeline.latest!.netWorthChange.comparedTo,
        const YearMonth(2026, 5),
      );
      expect(timeline.latest!.netWorthChange.absolute, const Money.euros(200));
    });

    test('precedente a zero: importo sì, percentuale no', () {
      // Patrimonio netto di agosto a zero: attività e debiti si compensano.
      final timeline = WealthCalculator.timeline([
        snap(2026, 8, [asset('Conto', 1000), debt('Prestito', 1000)]),
        snap(2026, 9, [asset('Conto', 1500), debt('Prestito', 1000)]),
      ]);
      final change = timeline.latest!.netWorthChange;
      expect(change.absolute, const Money.euros(500));
      expect(change.percent, isNull);
    });

    test('un mese salvato con tutti gli importi a zero non conta', () {
      final timeline = WealthCalculator.timeline([
        snap(2026, 8, [asset('Conto', 500)]),
        snap(2026, 9, [asset('Conto', 0), debt('Prestito', 0)]),
      ]);
      expect(timeline.points, hasLength(1));
      expect(timeline.latest!.month, const YearMonth(2026, 8));
    });

    test('invariato', () {
      final timeline = WealthCalculator.timeline([
        snap(2026, 8, [asset('Conto', 500)]),
        snap(2026, 9, [asset('Conto', 500)]),
      ]);
      expect(timeline.latest!.netWorthChange.trend, Trend.flat);
    });

    test(
      'modificare un mese cambia la variazione del successivo, non i suoi dati',
      () {
        final august = snap(2026, 8, [asset('Conto', 1000)]);
        final september = snap(2026, 9, [asset('Conto', 1500)]);
        final before = WealthCalculator.timeline([august, september]);
        expect(before.latest!.netWorthChange.absolute, const Money.euros(500));

        final correctedAugust = august.copyWith(items: [asset('Conto', 1400)]);
        final after = WealthCalculator.timeline([correctedAugust, september]);
        expect(after.latest!.totals.netWorth, const Money.euros(1500));
        expect(after.latest!.netWorthChange.absolute, const Money.euros(100));
        expect(after.latest!.snapshot, september);
      },
    );

    test('variazione annuale con lo stesso mese dell\'anno prima', () {
      final timeline = WealthCalculator.timeline([
        snap(2025, 9, [asset('ETF', 1000, investment: true)]),
        snap(2026, 3, [asset('ETF', 1050, investment: true)]),
        snap(2026, 9, [asset('ETF', 1100, investment: true)]),
      ]);
      final yearly = WealthCalculator.yearlyChange(
        timeline,
        (t) => t.investments,
      );
      expect(yearly.isFullYear, isTrue);
      expect(yearly.change.absolute, const Money.euros(100));
      expect(yearly.change.percent, const Percent(1000));
    });

    test('variazione annuale con storico più corto di un anno', () {
      final timeline = WealthCalculator.timeline([
        snap(2026, 6, [asset('ETF', 1000, investment: true)]),
        snap(2026, 9, [asset('ETF', 1100, investment: true)]),
      ]);
      final yearly = WealthCalculator.yearlyChange(
        timeline,
        (t) => t.investments,
      );
      expect(yearly.isFullYear, isFalse);
      expect(yearly.change.comparedTo, const YearMonth(2026, 6));
    });
  });

  group('grafico', () {
    final timeline = WealthCalculator.timeline([
      for (var m = 1; m <= 24; m++)
        snap(2024 + (m - 1) ~/ 12, (m - 1) % 12 + 1, [
          asset('Conto', 1000 + m),
        ]),
    ]);

    test('3 mesi mostrano 4 punti (3 variazioni)', () {
      final points = WealthCalculator.series(
        timeline,
        ChartRange.threeMonths,
        (t) => t.netWorth,
      );
      expect(points, hasLength(4));
      expect(points.last.month, const YearMonth(2025, 12));
    });

    test('un anno e tutto lo storico', () {
      expect(
        WealthCalculator.series(
          timeline,
          ChartRange.oneYear,
          (t) => t.netWorth,
        ),
        hasLength(13),
      );
      expect(
        WealthCalculator.series(timeline, ChartRange.all, (t) => t.netWorth),
        hasLength(24),
      );
    });

    test('storico vuoto', () {
      expect(
        WealthCalculator.series(
          Timeline.empty,
          ChartRange.all,
          (t) => t.netWorth,
        ),
        isEmpty,
      );
    });
  });

  group('distribuzione', () {
    final catalog = Catalog(
      categories: const [
        WealthCategory(id: 'liq', name: 'Liquidità', kind: ItemKind.asset),
        WealthCategory(
          id: 'inv',
          name: 'Investimenti',
          kind: ItemKind.asset,
          sortOrder: 1,
        ),
        WealthCategory(
          id: 'home',
          name: 'Immobili',
          kind: ItemKind.asset,
          sortOrder: 2,
        ),
        WealthCategory(
          id: 'debts',
          name: 'Debiti',
          kind: ItemKind.liability,
          sortOrder: 3,
        ),
      ],
      items: const [],
    );

    test('solo attività, percentuali che sommano a 100, colori stabili', () {
      final slices = WealthCalculator.distribution(
        snap(2026, 9, [
          asset('Conto', 1),
          asset('ETF', 1, cat: 'inv', order: 1),
          asset('Casa', 1, cat: 'home', order: 2),
          debt('Mutuo', 100),
        ]),
        catalog: catalog,
      );
      expect(slices.map((s) => s.label), [
        'Liquidità',
        'Investimenti',
        'Immobili',
      ]);
      expect(slices.fold<int>(0, (sum, s) => sum + s.percent), 100);
      expect(slices.map((s) => s.colorSlot), [0, 1, 2]);
    });

    test('categoria eliminata: finisce in "Altro"', () {
      final slices = WealthCalculator.distribution(
        snap(2026, 9, [
          asset('Conto', 50),
          const SnapshotItem(
            itemName: 'Vecchio',
            categoryName: 'Eliminata',
            kind: ItemKind.asset,
            amount: Money.euros(50),
          ),
        ]),
        catalog: catalog,
      );
      expect(slices.last.isOther, isTrue);
      expect(slices.last.percent, 50);
    });

    test('lordo zero: nessuna fetta', () {
      expect(
        WealthCalculator.distribution(
          snap(2026, 9, [debt('Mutuo', 10)]),
          catalog: catalog,
        ),
        isEmpty,
      );
    });
  });

  test('ripartizione degli investimenti per voce', () {
    final shares = WealthCalculator.investmentBreakdown(
      snap(2026, 9, [
        asset('ETF', 75, cat: 'inv', investment: true),
        asset('Azioni', 25, cat: 'inv', investment: true),
        asset('Conto', 1000),
      ]),
    );
    expect(shares.map((s) => s.name), ['ETF', 'Azioni']);
    expect(shares.map((s) => s.percent), [75, 25]);
  });

  test('valori per categoria con variazione', () {
    final values = WealthCalculator.categoryValues(
      latest: snap(2026, 9, [asset('Conto', 1500), debt('Mutuo', 900)]),
      previous: snap(2026, 8, [asset('Conto', 1000), debt('Mutuo', 1000)]),
    );
    final liquidity = values.firstWhere((v) => v.kind == ItemKind.asset);
    final debts = values.firstWhere((v) => v.kind == ItemKind.liability);
    expect(liquidity.change.absolute, const Money.euros(500));
    expect(debts.change.absolute, const Money.euros(-100));
  });

  group('promemoria', () {
    final august = WealthCalculator.timeline([
      snap(2026, 8, [asset('Conto', 1)]),
    ]);

    test('compare se manca il mese corrente', () {
      expect(
        WealthCalculator.needsReminder(august, const YearMonth(2026, 9)),
        isTrue,
      );
    });

    test('non compare se il mese corrente è aggiornato', () {
      expect(
        WealthCalculator.needsReminder(august, const YearMonth(2026, 8)),
        isFalse,
      );
    });

    test('non compare senza aggiornamenti (c\'è lo stato vuoto)', () {
      expect(
        WealthCalculator.needsReminder(
          Timeline.empty,
          const YearMonth(2026, 9),
        ),
        isFalse,
      );
    });
  });
}
