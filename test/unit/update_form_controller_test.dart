import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/errors/app_failure.dart';
import 'package:patrimonio/core/money/money.dart';
import 'package:patrimonio/core/money/money_parser.dart';
import 'package:patrimonio/core/time/year_month.dart';
import 'package:patrimonio/features/monthly_update/application/update_form_controller.dart';
import 'package:patrimonio/shared/providers/catalog_providers.dart';
import 'package:patrimonio/shared/providers/snapshot_providers.dart';
import 'package:patrimonio/shared/repositories/demo/demo_dataset.dart';

import '../helpers/test_app.dart';

void main() {
  const september = YearMonth(2026, 9);
  const august = YearMonth(2026, 8);

  Future<({ProviderContainer container, UpdateFormArgs args})> open({
    String? snapshotId,
    YearMonth? month,
  }) async {
    final container = makeContainer();
    await container.read(catalogProvider.future);
    await container.read(snapshotsProvider.future);
    final args = (snapshotId: snapshotId, month: month);
    // Tiene vivo il provider autoDispose durante il test.
    container.listen(updateFormProvider(args), (_, _) {});
    return (container: container, args: args);
  }

  test('nuovo mese: valori precompilati dall\'ultimo aggiornamento', () async {
    final (:container, :args) = await open();
    final state = container.read(updateFormProvider(args));
    expect(state.month, september);
    expect(state.isEditing, isFalse);
    expect(state.prefilledFrom, august);
    expect(state.totals.netWorth, const Money.euros(180000));
    expect(state.change.absolute, Money.zero);
    expect(state.lines, hasLength(14));
  });

  test('il totale si ricalcola a ogni modifica', () async {
    final (:container, :args) = await open();
    final controller = container.read(updateFormProvider(args).notifier);
    final before = (container.read(updateFormProvider(args))).totals.netWorth;
    final current = DemoDataset.valuesFor(23)['demo-item-current']!;
    controller.updateAmount('demo-item-current', '${current + 540}');
    final state = container.read(updateFormProvider(args));
    expect(state.totals.netWorth, before + const Money.euros(540));
    expect(state.dirty, isTrue);
    expect(state.change.absolute, const Money.euros(540));
  });

  test('un importo non valido blocca il salvataggio', () async {
    final (:container, :args) = await open();
    final controller = container.read(updateFormProvider(args).notifier);
    controller.updateAmount('demo-item-cash', '12,345');
    final state = container.read(updateFormProvider(args));
    expect(state.hasErrors, isTrue);
    expect(
      state.lines.firstWhere((l) => l.key == 'demo-item-cash').error,
      MoneyParseError.tooManyDecimals,
    );
    expect(controller.save(), throwsA(isA<AppFailure>()));
  });

  test('campo vuoto vale zero', () async {
    final (:container, :args) = await open();
    final controller = container.read(updateFormProvider(args).notifier);
    controller.updateAmount('demo-item-cash', '');
    final state = container.read(updateFormProvider(args));
    expect(
      state.lines.firstWhere((l) => l.key == 'demo-item-cash').amount,
      Money.zero,
    );
    expect(state.hasErrors, isFalse);
  });

  test(
    'salvare crea l\'aggiornamento del mese e aggiorna lo storico',
    () async {
      final (:container, :args) = await open();
      final controller = container.read(updateFormProvider(args).notifier);
      controller.updateAmount('demo-item-cash', '1.000');
      final saved = await controller.save();
      expect(saved.month, september);
      final snapshots = container.read(snapshotsProvider).value!;
      expect(snapshots, hasLength(25));
      expect(snapshots.last.id, saved.id);
      final timeline = container.read(timelineProvider).value!;
      expect(timeline.latest!.month, september);
    },
  );

  test(
    'riaprire un mese già salvato lo modifica invece di duplicarlo',
    () async {
      final (:container, :args) = await open(month: august);
      final state = container.read(updateFormProvider(args));
      expect(state.isEditing, isTrue);
      expect(state.snapshotId, 'demo-snap-2026-08');
      expect(state.previousMonth, const YearMonth(2026, 7));
    },
  );

  test('modificare un mese passato non cambia i mesi successivi', () async {
    final (:container, :args) = await open(snapshotId: 'demo-snap-2026-06');
    final julyBefore = container
        .read(snapshotsProvider)
        .value!
        .firstWhere((s) => s.id == 'demo-snap-2026-07');
    final controller = container.read(updateFormProvider(args).notifier);
    final state = container.read(updateFormProvider(args));
    expect(state.lockMonth, isTrue);
    controller.updateAmount('demo-item-cash', '10.000');
    await controller.save();

    final snapshots = container.read(snapshotsProvider).value!;
    expect(snapshots, hasLength(24));
    final julyAfter = snapshots.firstWhere((s) => s.id == 'demo-snap-2026-07');
    expect(julyAfter, julyBefore);
    final june = snapshots.firstWhere((s) => s.id == 'demo-snap-2026-06');
    expect(
      june.items.firstWhere((i) => i.itemId == 'demo-item-cash').amount,
      const Money.euros(10000),
    );
    // La variazione di luglio si ricalcola rispetto al giugno corretto.
    final timeline = container.read(timelineProvider).value!;
    final july = timeline.byId('demo-snap-2026-07')!;
    final junePoint = timeline.byId('demo-snap-2026-06')!;
    expect(
      july.netWorthChange.absolute,
      july.totals.netWorth - junePoint.totals.netWorth,
    );
  });

  test('aggiornamento inesistente', () async {
    final (:container, :args) = await open(snapshotId: 'non-esiste');
    expect((container.read(updateFormProvider(args))).missing, isTrue);
  });

  test('aggiungere una voce la crea nel catalogo e nel form', () async {
    final (:container, :args) = await open();
    final controller = container.read(updateFormProvider(args).notifier);
    await controller.addItem(
      name: 'Fondo pensione',
      categoryId: 'demo-cat-investments',
    );
    final state = container.read(updateFormProvider(args));
    expect(state.lines.any((l) => l.itemName == 'Fondo pensione'), isTrue);
    final catalog = container.read(catalogProvider).value!;
    expect(catalog.items.any((i) => i.name == 'Fondo pensione'), isTrue);
  });

  test('non si può andare oltre il mese corrente', () async {
    final (:container, :args) = await open();
    final controller = container.read(updateFormProvider(args).notifier);
    controller.selectMonth(september.next);
    expect((container.read(updateFormProvider(args))).month, september);
    controller.selectMonth(august);
    expect((container.read(updateFormProvider(args))).isEditing, isTrue);
  });

  test('un mese prima del primo aggiornamento non parte da zero', () async {
    final (:container, :args) = await open(month: const YearMonth(2024, 1));
    final state = container.read(updateFormProvider(args));
    expect(state.isEditing, isFalse);
    // Valori copiati dal primo aggiornamento disponibile, settembre 2024.
    expect(state.prefilledFrom, const YearMonth(2024, 9));
    expect(state.totals.netWorth, const Money.euros(118000));
    // Nessun mese precedente con cui confrontarsi.
    expect(state.change.isFirst, isTrue);
  });

  test('un mese in un buco dello storico copia il precedente', () async {
    final container = makeContainer();
    await container.read(catalogProvider.future);
    await container.read(snapshotsProvider.future);
    await container
        .read(snapshotsProvider.notifier)
        .delete('demo-snap-2026-05');
    const args = (snapshotId: null, month: YearMonth(2026, 5));
    container.listen(updateFormProvider(args), (_, _) {});
    final state = container.read(updateFormProvider(args));
    expect(state.prefilledFrom, const YearMonth(2026, 4));
    expect(state.previousMonth, const YearMonth(2026, 4));
  });
}
