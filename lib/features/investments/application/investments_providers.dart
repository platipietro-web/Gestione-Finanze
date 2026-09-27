import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/time/year_month.dart';
import '../../../shared/providers/catalog_providers.dart';
import '../../../shared/providers/chart_range.dart';
import '../../../shared/providers/snapshot_providers.dart';
import '../../../shared/services/wealth_calculator.dart';

final investmentsRangeProvider =
    NotifierProvider<ChartRangeController, ChartRange>(
      ChartRangeController.new,
    );

@immutable
class InvestmentsData {
  const InvestmentsData({
    required this.month,
    required this.value,
    required this.monthly,
    required this.yearly,
    required this.breakdown,
    required this.hasInvestments,
  });

  final YearMonth month;
  final Money value;
  final Change monthly;
  final PeriodChange yearly;
  final List<ItemShare> breakdown;

  /// Esiste almeno una categoria o un valore di investimento.
  final bool hasInvestments;
}

/// `AsyncData(null)` quando non c'è ancora nessun aggiornamento.
final investmentsProvider = Provider<AsyncValue<InvestmentsData?>>((ref) {
  final timelineAsync = ref.watch(timelineProvider);
  final timeline = timelineAsync.value;
  if (timeline == null) {
    return timelineAsync.hasError
        ? AsyncError(timelineAsync.error!, timelineAsync.stackTrace!)
        : const AsyncLoading();
  }
  final latest = timeline.latest;
  if (latest == null) return const AsyncData(null);
  final catalog = ref.watch(catalogProvider).value;
  final everInvested = timeline.points.any(
    (p) => p.totals.investments.isPositive,
  );
  return AsyncData(
    InvestmentsData(
      month: latest.month,
      value: latest.totals.investments,
      monthly: latest.investmentsChange,
      yearly: WealthCalculator.yearlyChange(timeline, (t) => t.investments),
      breakdown: WealthCalculator.investmentBreakdown(
        latest.snapshot,
        catalog: catalog,
      ),
      hasInvestments:
          everInvested || (catalog?.hasInvestmentCategories ?? false),
    ),
  );
});

final investmentsSeriesProvider = Provider<List<ChartPoint>>((ref) {
  final timeline = ref.watch(timelineProvider).value;
  if (timeline == null) return const [];
  return WealthCalculator.series(
    timeline,
    ref.watch(investmentsRangeProvider),
    (totals) => totals.investments,
  );
});
