import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/errors/app_failure.dart';
import 'package:patrimonio/core/money/money.dart';
import 'package:patrimonio/core/time/year_month.dart';
import 'package:patrimonio/shared/models/item_kind.dart';
import 'package:patrimonio/shared/models/snapshot.dart';
import 'package:patrimonio/shared/providers/snapshot_providers.dart';

import '../helpers/test_app.dart';

SnapshotItem line(int euros) => SnapshotItem(
  itemName: 'Conto',
  categoryName: 'Liquidità',
  kind: ItemKind.asset,
  amount: Money.euros(euros),
);

void main() {
  test('primo aggiornamento su storico vuoto', () async {
    final container = makeContainer(store: emptyStore());
    expect(await container.read(snapshotsProvider.future), isEmpty);
    await container
        .read(snapshotsProvider.notifier)
        .save(
          SnapshotDraft(month: const YearMonth(2026, 9), items: [line(1000)]),
        );
    final timeline = container.read(timelineProvider).value!;
    expect(timeline.points, hasLength(1));
    expect(timeline.latest!.netWorthChange.isFirst, isTrue);
  });

  test('lo storico resta ordinato anche inserendo un mese passato', () async {
    final container = makeContainer(store: emptyStore());
    await container.read(snapshotsProvider.future);
    final notifier = container.read(snapshotsProvider.notifier);
    await notifier.save(
      SnapshotDraft(month: const YearMonth(2026, 9), items: [line(1)]),
    );
    await notifier.save(
      SnapshotDraft(month: const YearMonth(2026, 7), items: [line(1)]),
    );
    final months = container
        .read(snapshotsProvider)
        .value!
        .map((s) => s.month)
        .toList();
    expect(months, [const YearMonth(2026, 7), const YearMonth(2026, 9)]);
  });

  test('un secondo aggiornamento per lo stesso mese è rifiutato', () async {
    final container = makeContainer(store: emptyStore());
    await container.read(snapshotsProvider.future);
    final notifier = container.read(snapshotsProvider.notifier);
    await notifier.save(
      SnapshotDraft(month: const YearMonth(2026, 9), items: [line(1)]),
    );
    await expectLater(
      notifier.save(
        SnapshotDraft(month: const YearMonth(2026, 9), items: [line(2)]),
      ),
      throwsA(
        isA<AppFailure>().having(
          (f) => f.kind,
          'kind',
          FailureKind.monthAlreadyExists,
        ),
      ),
    );
  });

  test('eliminare un aggiornamento', () async {
    final container = makeContainer();
    await container.read(snapshotsProvider.future);
    await container
        .read(snapshotsProvider.notifier)
        .delete('demo-snap-2026-08');
    final timeline = container.read(timelineProvider).value!;
    expect(timeline.points, hasLength(23));
    expect(timeline.latest!.month, const YearMonth(2026, 7));
  });

  test('promemoria: compare nella demo (manca settembre)', () async {
    final container = makeContainer();
    await container.read(snapshotsProvider.future);
    expect(container.read(updateReminderProvider), isTrue);
  });
}
