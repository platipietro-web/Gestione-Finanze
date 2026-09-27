import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/time/year_month.dart';
import 'package:patrimonio/features/investments/application/investments_providers.dart';
import 'package:patrimonio/features/monthly_update/application/update_form_controller.dart';
import 'package:patrimonio/shared/providers/catalog_providers.dart';
import 'package:patrimonio/shared/providers/snapshot_providers.dart';

import '../helpers/test_app.dart';

/// Rinomina "Fineco · ETF" in "Portafoglio Fineco".
Future<ProviderContainer> renamedEtf() async {
  final container = makeContainer();
  final catalog = await container.read(catalogProvider.future);
  await container.read(snapshotsProvider.future);
  final etf = catalog.itemById('demo-item-etf')!;
  await container
      .read(catalogProvider.notifier)
      .updateItem(etf.copyWith(name: 'Portafoglio Fineco'));
  return container;
}

String lineName(UpdateFormState state, String itemId) =>
    state.lines.firstWhere((l) => l.itemId == itemId).itemName;

void main() {
  test('nell\'ultimo aggiornamento compare il nome nuovo', () async {
    final container = await renamedEtf();
    const args = (snapshotId: null, month: YearMonth(2026, 8));
    container.listen(updateFormProvider(args), (_, _) {});
    final state = container.read(updateFormProvider(args));
    expect(state.isEditing, isTrue);
    expect(lineName(state, 'demo-item-etf'), 'Portafoglio Fineco');
  });

  test('salvando, il nome nuovo entra nell\'aggiornamento', () async {
    final container = await renamedEtf();
    const args = (snapshotId: null, month: YearMonth(2026, 8));
    container.listen(updateFormProvider(args), (_, _) {});
    final saved = await container
        .read(updateFormProvider(args).notifier)
        .save();
    expect(
      saved.items.firstWhere((i) => i.itemId == 'demo-item-etf').itemName,
      'Portafoglio Fineco',
    );
  });

  test('un nuovo mese parte già con il nome nuovo', () async {
    final container = await renamedEtf();
    const args = (snapshotId: null, month: null);
    container.listen(updateFormProvider(args), (_, _) {});
    final state = container.read(updateFormProvider(args));
    expect(state.isEditing, isFalse);
    expect(lineName(state, 'demo-item-etf'), 'Portafoglio Fineco');
  });

  test('i mesi passati conservano il nome di allora', () async {
    final container = await renamedEtf();
    const args = (snapshotId: 'demo-snap-2026-06', month: null);
    container.listen(updateFormProvider(args), (_, _) {});
    expect(
      lineName(container.read(updateFormProvider(args)), 'demo-item-etf'),
      'Fineco · ETF',
    );
  });

  test('la pagina Investimenti usa subito il nome nuovo', () async {
    final container = await renamedEtf();
    final data = container.read(investmentsProvider).value!;
    final names = data.breakdown.map((s) => s.name).toList();
    expect(names, contains('Portafoglio Fineco'));
    expect(names, isNot(contains('Fineco · ETF')));
  });
}
