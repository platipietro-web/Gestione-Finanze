import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/money/money.dart';
import 'package:patrimonio/core/time/year_month.dart';
import 'package:patrimonio/features/onboarding/application/onboarding_controller.dart';
import 'package:patrimonio/shared/models/item_kind.dart';
import 'package:patrimonio/shared/providers/catalog_providers.dart';
import 'package:patrimonio/shared/providers/session_providers.dart';
import 'package:patrimonio/shared/providers/snapshot_providers.dart';

import '../helpers/test_app.dart';

void main() {
  const plan = OnboardingPlan([
    PlannedCategory(
      name: 'Liquidità',
      kind: ItemKind.asset,
      isInvestment: false,
      items: [(name: 'Conto corrente', amount: Money.euros(12500))],
    ),
    PlannedCategory(
      name: 'Investimenti',
      kind: ItemKind.asset,
      isInvestment: true,
      items: [(name: 'ETF', amount: Money.euros(75000))],
    ),
    PlannedCategory(
      name: 'Debiti',
      kind: ItemKind.liability,
      isInvestment: false,
      items: [(name: 'Mutuo', amount: Money.euros(40000))],
    ),
  ]);

  test(
    'crea catalogo e primo aggiornamento, poi completa l\'onboarding',
    () async {
      final store = emptyStore(onboarded: false);
      final container = makeContainer(store: store);
      container.listen(onboardingControllerProvider, (_, _) {});
      await container.read(profileProvider.future);
      expect(container.read(sessionStatusProvider), SessionStatus.ready);

      final ok = await container
          .read(onboardingControllerProvider.notifier)
          .finish(plan);
      expect(ok, isTrue);

      final catalog = container.read(catalogProvider).value!;
      expect(catalog.categories.map((c) => c.name), [
        'Liquidità',
        'Investimenti',
        'Debiti',
      ]);
      expect(catalog.categories[1].isInvestment, isTrue);
      expect(catalog.items, hasLength(3));

      final timeline = container.read(timelineProvider).value!;
      expect(timeline.latest!.month, const YearMonth(2026, 9));
      expect(timeline.latest!.totals.netWorth, const Money.euros(47500));
      expect(timeline.latest!.totals.investments, const Money.euros(75000));
      expect(store.profile.onboardingCompleted, isTrue);
    },
  );

  test('ripetere non crea doppioni', () async {
    final store = emptyStore(onboarded: false);
    final container = makeContainer(store: store);
    container.listen(onboardingControllerProvider, (_, _) {});
    final controller = container.read(onboardingControllerProvider.notifier);
    await controller.finish(plan);
    await controller.finish(plan);
    expect(store.categories, hasLength(3));
    expect(store.items, hasLength(3));
    expect(store.snapshots, hasLength(1));
  });
}
