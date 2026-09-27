import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/errors/app_failure.dart';
import 'package:patrimonio/core/money/money.dart';
import 'package:patrimonio/core/time/year_month.dart';
import 'package:patrimonio/features/monthly_update/application/update_form_controller.dart';
import 'package:patrimonio/shared/models/snapshot.dart';
import 'package:patrimonio/shared/providers/catalog_providers.dart';
import 'package:patrimonio/shared/providers/snapshot_providers.dart';
import 'package:patrimonio/shared/repositories/demo/demo_dataset.dart';
import 'package:patrimonio/shared/repositories/demo/demo_store.dart';
import 'package:patrimonio/shared/services/wealth_calculator.dart';

import '../helpers/test_app.dart';

const september = YearMonth(2026, 9);

/// Il caso segnalato: agosto con valori veri, settembre salvato con tutti
/// gli importi a zero (per esempio un onboarding chiuso senza valori).
DemoStore storeWithEmptySeptember() {
  final store = DemoDataset.build(september);
  final august = store.snapshots.last;
  store.snapshots.add(
    Snapshot(
      id: 'settembre-vuoto',
      month: september,
      items: [
        for (final item in august.items) item.copyWith(amount: Money.zero),
      ],
    ),
  );
  return store;
}

Future<ProviderContainer> loaded(DemoStore store) async {
  final container = makeContainer(store: store);
  await container.read(catalogProvider.future);
  await container.read(snapshotsProvider.future);
  return container;
}

void main() {
  test('un mese vuoto non conta: niente €0 e niente −100%', () async {
    final container = await loaded(storeWithEmptySeptember());
    final timeline = container.read(timelineProvider).value!;
    expect(timeline.latest!.month, const YearMonth(2026, 8));
    expect(timeline.latest!.totals.netWorth, const Money.euros(180000));
    expect(timeline.byId('settembre-vuoto'), isNull);
    // Settembre risulta ancora da aggiornare.
    expect(container.read(updateReminderProvider), isTrue);
  });

  test('il form del mese vuoto propone gli ultimi valori veri', () async {
    final container = await loaded(storeWithEmptySeptember());
    const args = (snapshotId: null, month: null);
    container.listen(updateFormProvider(args), (_, _) {});
    final state = container.read(updateFormProvider(args));
    expect(state.month, september);
    expect(state.prefilledFrom, const YearMonth(2026, 8));
    expect(state.totals.netWorth, const Money.euros(180000));
    expect(state.isEditingSavedValues, isFalse);
    // Salvando si aggiorna lo stesso mese, senza duplicarlo.
    expect(state.snapshotId, 'settembre-vuoto');
    final saved = await container
        .read(updateFormProvider(args).notifier)
        .save();
    expect(saved.id, 'settembre-vuoto');
    final snapshots = container.read(snapshotsProvider).value!;
    expect(snapshots.where((s) => s.month == september), hasLength(1));
    expect(WealthCalculator.isEmpty(saved), isFalse);
  });

  test('un aggiornamento tutto a zero non si salva', () async {
    final container = await loaded(DemoDataset.build(september));
    const args = (snapshotId: null, month: null);
    container.listen(updateFormProvider(args), (_, _) {});
    final controller = container.read(updateFormProvider(args).notifier);
    for (final line in container.read(updateFormProvider(args)).lines) {
      controller.updateAmount(line.key, '0');
    }
    expect(container.read(updateFormProvider(args)).isAllZero, isTrue);
    await expectLater(controller.save(), throwsA(isA<AppFailure>()));
    expect(container.read(snapshotsProvider).value, hasLength(24));
  });
}
