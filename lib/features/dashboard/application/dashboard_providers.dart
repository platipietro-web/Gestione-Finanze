import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/year_month.dart';
import '../../../shared/models/item_kind.dart';
import '../../../shared/providers/catalog_providers.dart';
import '../../../shared/providers/chart_range.dart';
import '../../../shared/providers/snapshot_providers.dart';
import '../../../shared/services/wealth_calculator.dart';

final dashboardRangeProvider =
    NotifierProvider<ChartRangeController, ChartRange>(
      ChartRangeController.new,
    );

/// Tutto ciò che serve alla dashboard, calcolato una volta per versione
/// dei dati.
@immutable
class DashboardData {
  const DashboardData({
    required this.latest,
    required this.previous,
    required this.assetCategories,
    required this.liabilitiesChange,
    required this.distribution,
    required this.recent,
  });

  final TimelinePoint latest;
  final TimelinePoint? previous;
  final List<CategoryValue> assetCategories;
  final Change liabilitiesChange;
  final List<DistributionSlice> distribution;
  final List<TimelinePoint> recent;
}

/// `AsyncData(null)` quando non c'è ancora nessun aggiornamento.
final dashboardProvider = Provider<AsyncValue<DashboardData?>>((ref) {
  final timelineAsync = ref.watch(timelineProvider);
  final catalogAsync = ref.watch(catalogProvider);

  final timeline = timelineAsync.value;
  if (timeline == null) {
    return timelineAsync.hasError
        ? AsyncError(timelineAsync.error!, timelineAsync.stackTrace!)
        : const AsyncLoading();
  }
  if (!catalogAsync.hasValue && catalogAsync.isLoading) {
    return const AsyncLoading();
  }
  final catalog = catalogAsync.value;

  final latest = timeline.latest;
  if (latest == null) return const AsyncData(null);
  final previous = timeline.previousOf(latest);

  final categories = WealthCalculator.categoryValues(
    latest: latest.snapshot,
    previous: previous?.snapshot,
    catalog: catalog,
  );
  return AsyncData(
    DashboardData(
      latest: latest,
      previous: previous,
      assetCategories: [
        for (final c in categories)
          if (c.kind == ItemKind.asset) c,
      ],
      liabilitiesChange: WealthCalculator.change(
        latest.totals.liabilities,
        previous?.totals.liabilities,
        comparedTo: previous?.month,
      ),
      distribution: WealthCalculator.distribution(
        latest.snapshot,
        catalog: catalog,
      ),
      recent: timeline.newestFirst.take(3).toList(),
    ),
  );
});

/// Punti del grafico: cambiare intervallo taglia una serie già calcolata,
/// senza ricaricare nulla.
final netWorthSeriesProvider = Provider<List<ChartPoint>>((ref) {
  final timeline = ref.watch(timelineProvider).value;
  if (timeline == null) return const [];
  return WealthCalculator.series(
    timeline,
    ref.watch(dashboardRangeProvider),
    (totals) => totals.netWorth,
  );
});

/// "questo mese" se il confronto è tra il mese corrente e quello prima;
/// altrimenti "rispetto a luglio".
bool isThisMonthComparison(TimelinePoint latest, YearMonth currentMonth) =>
    latest.month == currentMonth &&
    latest.netWorthChange.comparedTo == currentMonth.previous;
