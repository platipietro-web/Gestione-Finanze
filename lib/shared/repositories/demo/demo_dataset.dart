import '../../../core/money/money.dart';
import '../../../core/time/year_month.dart';
import '../../models/item_kind.dart';
import '../../models/profile.dart';
import '../../models/snapshot.dart';
import '../../models/wealth_category.dart';
import '../../models/wealth_item.dart';
import 'demo_store.dart';

/// 24 mesi di dati di esempio, fino al mese scorso: così nella demo si vede
/// anche il promemoria mensile. Gli ultimi 12 mesi seguono l'andamento della
/// specifica, da €145.000 a €180.000 di patrimonio netto.
abstract final class DemoDataset {
  static const months = 24;

  static const netWorthTargets = [
    // Primo anno
    118000, 119500, 121200, 120400, 123800, 126000,
    128700, 127900, 131500, 134200, 138000, 141600,
    // Ultimi 12 mesi (valori della specifica)
    145000, 148000, 147000, 151000, 155000, 153000,
    160000, 164000, 168000, 171000, 175000, 180000,
  ];

  /// Piccole oscillazioni deterministiche dei mercati.
  static const _wobble = [0, 1, -1, 2, 0, -2, 1, 1, -1, 0, 2, -1];

  static const _categories = [
    WealthCategory(
      id: 'demo-cat-liquidity',
      name: 'Liquidità',
      kind: ItemKind.asset,
    ),
    WealthCategory(
      id: 'demo-cat-investments',
      name: 'Investimenti',
      kind: ItemKind.asset,
      isInvestment: true,
      sortOrder: 1,
    ),
    WealthCategory(
      id: 'demo-cat-real-estate',
      name: 'Immobili',
      kind: ItemKind.asset,
      sortOrder: 2,
    ),
    WealthCategory(
      id: 'demo-cat-other',
      name: 'Altri beni',
      kind: ItemKind.asset,
      sortOrder: 3,
    ),
    WealthCategory(
      id: 'demo-cat-debts',
      name: 'Debiti',
      kind: ItemKind.liability,
      sortOrder: 4,
    ),
  ];

  static const _items = [
    WealthItem(
      id: 'demo-item-current',
      categoryId: 'demo-cat-liquidity',
      name: 'Conto corrente',
    ),
    WealthItem(
      id: 'demo-item-deposit',
      categoryId: 'demo-cat-liquidity',
      name: 'Conto deposito',
      sortOrder: 1,
    ),
    WealthItem(
      id: 'demo-item-cash',
      categoryId: 'demo-cat-liquidity',
      name: 'Contanti',
      sortOrder: 2,
    ),
    WealthItem(
      id: 'demo-item-etf',
      categoryId: 'demo-cat-investments',
      name: 'ETF',
    ),
    WealthItem(
      id: 'demo-item-stocks',
      categoryId: 'demo-cat-investments',
      name: 'Azioni',
      sortOrder: 1,
    ),
    WealthItem(
      id: 'demo-item-bonds',
      categoryId: 'demo-cat-investments',
      name: 'Obbligazioni',
      sortOrder: 2,
    ),
    WealthItem(
      id: 'demo-item-crypto',
      categoryId: 'demo-cat-investments',
      name: 'Crypto',
      sortOrder: 3,
    ),
    WealthItem(
      id: 'demo-item-home',
      categoryId: 'demo-cat-real-estate',
      name: 'Casa',
    ),
    WealthItem(id: 'demo-item-car', categoryId: 'demo-cat-other', name: 'Auto'),
    WealthItem(
      id: 'demo-item-mortgage',
      categoryId: 'demo-cat-debts',
      name: 'Mutuo',
    ),
    WealthItem(
      id: 'demo-item-card',
      categoryId: 'demo-cat-debts',
      name: 'Carta di credito',
      sortOrder: 1,
    ),
  ];

  static DemoStore build(YearMonth currentMonth) {
    final first = currentMonth.addMonths(-months);
    final snapshots = [
      for (var k = 0; k < months; k++) _snapshot(first.addMonths(k), k),
    ];
    return DemoStore(
      categories: _categories,
      items: _items,
      snapshots: snapshots,
      profile: const Profile(id: 'demo', onboardingCompleted: true),
    );
  }

  /// Valori in euro delle voci nel mese [k]. Il conto corrente assorbe la
  /// differenza, così il patrimonio netto coincide con [netWorthTargets].
  static Map<String, int> valuesFor(int k) {
    final values = <String, int>{
      'demo-item-deposit': 6000 + 150 * k,
      'demo-item-cash': 400 + (k % 4) * 50,
      'demo-item-etf': 30000 + 1000 * k + _wobble[k % 12] * 900,
      'demo-item-stocks': 12000 + 400 * k + _wobble[(k + 3) % 12] * 700,
      'demo-item-bonds': 8000 + 60 * k,
      'demo-item-crypto': 1500 + 80 * k + _wobble[(k + 1) % 12] * 600,
      'demo-item-home': 150000,
      'demo-item-car': 19000 - 180 * k,
      'demo-item-mortgage': 118000 - 420 * k,
      'demo-item-card': 600 + (k % 3) * 350,
    };
    const liabilities = {'demo-item-mortgage', 'demo-item-card'};
    var netWithoutCurrent = 0;
    values.forEach((id, value) {
      netWithoutCurrent += liabilities.contains(id) ? -value : value;
    });
    values['demo-item-current'] = netWorthTargets[k] - netWithoutCurrent;
    return values;
  }

  static Snapshot _snapshot(YearMonth month, int k) {
    final values = valuesFor(k);
    final categoriesById = {for (final c in _categories) c.id: c};
    return Snapshot(
      id: 'demo-snap-${month.isoMonth}',
      month: month,
      updatedAt: month.firstDay.add(const Duration(days: 27, hours: 20)),
      items: [
        for (final item in _items)
          SnapshotItem(
            itemId: item.id,
            categoryId: item.categoryId,
            itemName: item.name,
            categoryName: categoriesById[item.categoryId]!.name,
            kind: categoriesById[item.categoryId]!.kind,
            isInvestment: categoriesById[item.categoryId]!.isInvestment,
            categoryOrder: categoriesById[item.categoryId]!.sortOrder,
            itemOrder: item.sortOrder,
            amount: Money.euros(values[item.id]!),
          ),
      ],
    );
  }
}
