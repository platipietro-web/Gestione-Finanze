import 'package:flutter/foundation.dart';

import '../../core/money/money.dart';
import '../../core/money/percent.dart';
import '../../core/time/year_month.dart';
import '../models/catalog.dart';
import '../models/item_kind.dart';
import '../models/snapshot.dart';

/// Totali di un aggiornamento. Il patrimonio netto è sempre derivato.
@immutable
class SnapshotTotals {
  const SnapshotTotals({
    required this.assets,
    required this.liabilities,
    required this.investments,
  });

  static const zero = SnapshotTotals(
    assets: Money.zero,
    liabilities: Money.zero,
    investments: Money.zero,
  );

  /// Patrimonio lordo: somma delle attività.
  final Money assets;

  /// Somma delle passività, in positivo.
  final Money liabilities;

  /// Somma delle voci che contano come investimento.
  final Money investments;

  /// Patrimonio netto: attività meno passività. Può essere negativo.
  Money get netWorth => assets - liabilities;

  @override
  bool operator ==(Object other) =>
      other is SnapshotTotals &&
      other.assets == assets &&
      other.liabilities == liabilities &&
      other.investments == investments;

  @override
  int get hashCode => Object.hash(assets, liabilities, investments);
}

enum Trend { none, flat, up, down }

/// Variazione rispetto a un valore precedente.
@immutable
class Change {
  const Change({this.absolute, this.percent, this.comparedTo});

  /// Nessun confronto possibile: è il primo aggiornamento.
  static const none = Change();

  final Money? absolute;

  /// `null` se il valore precedente era zero: la percentuale non è definita.
  final Percent? percent;

  /// Mese usato per il confronto.
  final YearMonth? comparedTo;

  bool get isFirst => absolute == null;

  Trend get trend {
    final value = absolute;
    if (value == null) return Trend.none;
    if (value.isZero) return Trend.flat;
    return value.isPositive ? Trend.up : Trend.down;
  }

  @override
  bool operator ==(Object other) =>
      other is Change &&
      other.absolute == absolute &&
      other.percent == percent &&
      other.comparedTo == comparedTo;

  @override
  int get hashCode => Object.hash(absolute, percent, comparedTo);

  @override
  String toString() => 'Change($absolute, $percent, vs $comparedTo)';
}

/// Un aggiornamento con i suoi totali e le variazioni già calcolate.
@immutable
class TimelinePoint {
  const TimelinePoint({
    required this.snapshot,
    required this.totals,
    required this.netWorthChange,
    required this.investmentsChange,
  });

  final Snapshot snapshot;
  final SnapshotTotals totals;
  final Change netWorthChange;
  final Change investmentsChange;

  YearMonth get month => snapshot.month;
  String get id => snapshot.id;
}

/// Tutto lo storico, dal mese più vecchio al più recente.
@immutable
class Timeline {
  Timeline(List<TimelinePoint> points) : points = List.unmodifiable(points);

  static final empty = Timeline(const []);

  final List<TimelinePoint> points;

  bool get isEmpty => points.isEmpty;
  bool get isNotEmpty => points.isNotEmpty;

  TimelinePoint? get latest => points.isEmpty ? null : points.last;

  List<TimelinePoint> get newestFirst => points.reversed.toList();

  TimelinePoint? byId(String id) {
    for (final point in points) {
      if (point.id == id) return point;
    }
    return null;
  }

  TimelinePoint? byMonth(YearMonth month) {
    for (final point in points) {
      if (point.month == month) return point;
    }
    return null;
  }

  /// Ultimo aggiornamento precedente a [month].
  TimelinePoint? latestBefore(YearMonth month) {
    TimelinePoint? result;
    for (final point in points) {
      if (point.month.isBefore(month)) result = point;
    }
    return result;
  }

  TimelinePoint? previousOf(TimelinePoint point) => latestBefore(point.month);
}

enum ChartRange {
  threeMonths(3),
  sixMonths(6),
  oneYear(12),
  threeYears(36),
  all(null);

  const ChartRange(this.months);

  /// `null` = tutto lo storico.
  final int? months;
}

/// Un punto del grafico: mese e valore esatto.
@immutable
class ChartPoint {
  const ChartPoint(this.month, this.value);

  final YearMonth month;
  final Money value;

  @override
  bool operator ==(Object other) =>
      other is ChartPoint && other.month == month && other.value == value;

  @override
  int get hashCode => Object.hash(month, value);
}

/// Valore di una categoria nell'ultimo aggiornamento, con la variazione.
@immutable
class CategoryValue {
  const CategoryValue({
    required this.key,
    required this.name,
    required this.kind,
    required this.value,
    required this.change,
    required this.order,
    this.categoryId,
  });

  final String key;
  final String? categoryId;
  final String name;
  final ItemKind kind;
  final Money value;
  final Change change;
  final int order;
}

/// Fetta del donut.
@immutable
class DistributionSlice {
  const DistributionSlice({
    required this.key,
    required this.label,
    required this.value,
    required this.percent,
    required this.colorSlot,
  });

  final String key;

  /// `null` per la fetta "Altro": l'etichetta la mette l'interfaccia.
  final String? label;
  final Money value;

  /// Percentuale intera; la somma delle fette fa sempre 100.
  final int percent;

  /// Posizione nella palette; `-1` = neutro di "Altro".
  final int colorSlot;

  bool get isOther => colorSlot < 0;
}

/// Quota di una voce sul totale (ripartizione degli investimenti).
@immutable
class ItemShare {
  const ItemShare({
    required this.name,
    required this.value,
    required this.percent,
  });

  final String name;
  final Money value;
  final int percent;
}

/// Variazione su un anno, o dall'inizio se lo storico è più corto.
@immutable
class PeriodChange {
  const PeriodChange({required this.change, required this.isFullYear});

  static const none = PeriodChange(change: Change.none, isFullYear: false);

  final Change change;

  /// `true` se il confronto è con lo stesso mese dell'anno prima.
  final bool isFullYear;
}

/// Tutti i calcoli del patrimonio. Funzioni pure, senza Flutter né Supabase.
abstract final class WealthCalculator {
  /// Massimo di fette colorate nel donut; le altre finiscono in "Altro".
  static const maxColoredSlices = 5;

  static SnapshotTotals totals(Iterable<SnapshotItem> items) {
    var assets = 0;
    var liabilities = 0;
    var investments = 0;
    for (final item in items) {
      if (item.isLiability) {
        liabilities += item.amount.cents;
      } else {
        assets += item.amount.cents;
        if (item.isInvestment) investments += item.amount.cents;
      }
    }
    return SnapshotTotals(
      assets: Money(assets),
      liabilities: Money(liabilities),
      investments: Money(investments),
    );
  }

  /// Variazione di [current] rispetto a [previous]. Senza precedente
  /// (primo aggiornamento) restituisce [Change.none].
  static Change change(
    Money current,
    Money? previous, {
    YearMonth? comparedTo,
  }) {
    if (previous == null) return Change.none;
    return Change(
      absolute: current - previous,
      percent: Percent.change(current: current, previous: previous),
      comparedTo: comparedTo,
    );
  }

  /// Ordina gli aggiornamenti e calcola totali e variazioni una volta sola.
  /// Con mesi mancanti il confronto è con l'ultimo aggiornamento disponibile.
  static Timeline timeline(Iterable<Snapshot> snapshots) {
    final sorted = [...snapshots]..sort((a, b) => a.month.compareTo(b.month));
    final points = <TimelinePoint>[];
    for (final snapshot in sorted) {
      final totals = WealthCalculator.totals(snapshot.items);
      final previous = points.isEmpty ? null : points.last;
      points.add(
        TimelinePoint(
          snapshot: snapshot,
          totals: totals,
          netWorthChange: change(
            totals.netWorth,
            previous?.totals.netWorth,
            comparedTo: previous?.month,
          ),
          investmentsChange: change(
            totals.investments,
            previous?.totals.investments,
            comparedTo: previous?.month,
          ),
        ),
      );
    }
    return Timeline(points);
  }

  /// Variazione dell'ultimo aggiornamento rispetto allo stesso mese
  /// dell'anno prima, o al più recente precedente; se lo storico è più corto
  /// di un anno, rispetto al primo aggiornamento.
  static PeriodChange yearlyChange(
    Timeline timeline,
    Money Function(SnapshotTotals totals) select,
  ) {
    final latest = timeline.latest;
    if (latest == null || timeline.points.length < 2) return PeriodChange.none;
    final target = latest.month.addMonths(-12);
    TimelinePoint? base;
    for (final point in timeline.points) {
      if (!point.month.isAfter(target)) base = point;
    }
    final isFullYear = base != null;
    base ??= timeline.points.first;
    if (identical(base, latest)) return PeriodChange.none;
    return PeriodChange(
      change: change(
        select(latest.totals),
        select(base.totals),
        comparedTo: base.month,
      ),
      isFullYear: isFullYear,
    );
  }

  /// Punti del grafico nell'intervallo scelto, contato a ritroso
  /// dall'ultimo aggiornamento. "3 mesi" mostra 3 variazioni, quindi 4 punti.
  static List<ChartPoint> series(
    Timeline timeline,
    ChartRange range,
    Money Function(SnapshotTotals totals) select,
  ) {
    final latest = timeline.latest;
    if (latest == null) return const [];
    final months = range.months;
    final start = months == null ? null : latest.month.addMonths(-months);
    return [
      for (final point in timeline.points)
        if (start == null || !point.month.isBefore(start))
          ChartPoint(point.month, select(point.totals)),
    ];
  }

  /// Valori per categoria dell'ultimo aggiornamento, con la variazione
  /// rispetto al precedente. Per le categorie ancora esistenti si usa il
  /// nome attuale; per quelle eliminate, quello salvato.
  static List<CategoryValue> categoryValues({
    required Snapshot latest,
    Snapshot? previous,
    Catalog? catalog,
  }) {
    final current = _groupByCategory(latest.items);
    final before = previous == null ? null : _groupByCategory(previous.items);
    final keys = <String>{...current.keys, ...?before?.keys};
    final result = <CategoryValue>[];
    for (final key in keys) {
      final group = current[key] ?? before![key]!;
      final value = current[key]?.total ?? Money.zero;
      final previousValue = before == null
          ? null
          : (before[key]?.total ?? Money.zero);
      if (value.isZero && (previousValue == null || previousValue.isZero)) {
        continue;
      }
      final category = catalog?.categoryById(group.categoryId);
      result.add(
        CategoryValue(
          key: key,
          categoryId: group.categoryId,
          name: category?.name ?? group.name,
          kind: group.kind,
          value: value,
          change: change(value, previousValue, comparedTo: previous?.month),
          order: category?.sortOrder ?? group.order,
        ),
      );
    }
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  /// Fette del donut: solo attività con valore positivo. I colori seguono
  /// la categoria (vedi [Catalog.colorSlotOf]); oltre le prime cinque
  /// categorie, o per categorie eliminate, si usa "Altro".
  static List<DistributionSlice> distribution(
    Snapshot snapshot, {
    Catalog? catalog,
  }) {
    final groups = _groupByCategory(snapshot.items.where((i) => i.isAsset));
    final colored = <_SliceDraft>[];
    var other = Money.zero;
    for (final entry in groups.entries) {
      final group = entry.value;
      if (!group.total.isPositive) continue;
      final category = catalog?.categoryById(group.categoryId);
      final slot = catalog == null
          ? group.order
          : catalog.colorSlotOf(group.categoryId);
      if (slot < 0 ||
          slot >= maxColoredSlices ||
          category == null && catalog != null) {
        other += group.total;
      } else {
        colored.add(
          _SliceDraft(
            key: entry.key,
            label: category?.name ?? group.name,
            value: group.total,
            slot: slot,
          ),
        );
      }
    }
    colored.sort((a, b) => a.slot.compareTo(b.slot));
    final drafts = [
      ...colored,
      if (other.isPositive)
        _SliceDraft(key: 'other', label: null, value: other, slot: -1),
    ];
    if (drafts.isEmpty) return const [];
    final percents = largestRemainder([
      for (final d in drafts) d.value.cents,
    ], 100);
    return [
      for (var i = 0; i < drafts.length; i++)
        DistributionSlice(
          key: drafts[i].key,
          label: drafts[i].label,
          value: drafts[i].value,
          percent: percents[i],
          colorSlot: drafts[i].slot,
        ),
    ];
  }

  /// Ripartizione degli investimenti per voce, dal valore più alto.
  ///
  /// Con [catalog] le voci ancora esistenti usano il nome attuale: la
  /// ripartizione descrive la situazione di oggi.
  static List<ItemShare> investmentBreakdown(
    Snapshot snapshot, {
    Catalog? catalog,
  }) {
    final items =
        snapshot.items
            .where((i) => i.isAsset && i.isInvestment && i.amount.isPositive)
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));
    if (items.isEmpty) return const [];
    final percents = largestRemainder([
      for (final item in items) item.amount.cents,
    ], 100);
    return [
      for (var i = 0; i < items.length; i++)
        ItemShare(
          name: catalog?.itemById(items[i].itemId)?.name ?? items[i].itemName,
          value: items[i].amount,
          percent: percents[i],
        ),
    ];
  }

  /// Il promemoria compare quando il mese corrente non ha ancora un
  /// aggiornamento e l'utente ne ha almeno uno.
  static bool needsReminder(Timeline timeline, YearMonth currentMonth) {
    final latest = timeline.latest;
    if (latest == null) return false;
    return latest.month.isBefore(currentMonth);
  }

  static Map<String, _CategoryGroup> _groupByCategory(
    Iterable<SnapshotItem> items,
  ) {
    final groups = <String, _CategoryGroup>{};
    for (final item in items) {
      final group = groups.putIfAbsent(
        item.categoryKey,
        () => _CategoryGroup(
          categoryId: item.categoryId,
          name: item.categoryName,
          kind: item.kind,
          order: item.categoryOrder,
        ),
      );
      group.total += item.amount;
    }
    return groups;
  }
}

class _CategoryGroup {
  _CategoryGroup({
    required this.categoryId,
    required this.name,
    required this.kind,
    required this.order,
  });

  final String? categoryId;
  final String name;
  final ItemKind kind;
  final int order;
  Money total = Money.zero;
}

class _SliceDraft {
  const _SliceDraft({
    required this.key,
    required this.label,
    required this.value,
    required this.slot,
  });

  final String key;
  final String? label;
  final Money value;
  final int slot;
}
