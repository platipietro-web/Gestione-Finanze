import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/wealth_calculator.dart';

/// Intervallo scelto per un grafico. Ogni grafico ha il suo provider.
class ChartRangeController extends Notifier<ChartRange> {
  @override
  ChartRange build() => ChartRange.oneYear;

  void select(ChartRange range) => state = range;
}
