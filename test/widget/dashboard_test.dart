import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrimonio/core/errors/app_failure.dart';
import 'package:patrimonio/core/money/money.dart';
import 'package:patrimonio/core/time/year_month.dart';
import 'package:patrimonio/shared/models/snapshot.dart';
import 'package:patrimonio/shared/providers/repository_providers.dart';
import 'package:patrimonio/shared/repositories/demo/demo_dataset.dart';
import 'package:patrimonio/shared/repositories/snapshot_repository.dart';
import 'package:patrimonio/shared/widgets/skeleton.dart';

import '../helpers/test_app.dart';

class FailingSnapshots extends Mock implements SnapshotRepository {}

void main() {
  testWidgets('mostra patrimonio netto, variazione, promemoria e grafici', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(
      find.text('Modalità demo · dati di esempio, non salvati'),
      findsOneWidget,
    );
    expect(find.text('Patrimonio netto'), findsWidgets);
    expect(find.text('€180.000'), findsOneWidget);
    expect(find.textContaining('+€5.000'), findsOneWidget);
    expect(find.text('È ora di aggiornare il tuo patrimonio.'), findsOneWidget);
    expect(find.text('Aggiorna patrimonio'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Dove sono i tuoi soldi'), 300);
    expect(find.text('Dove sono i tuoi soldi'), findsOneWidget);
    expect(find.text('Immobili'), findsWidgets);
  });

  testWidgets('cambiare intervallo non ricarica i dati', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('3M'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tutto'));
    await tester.pumpAndSettle();
    expect(find.text('€180.000'), findsOneWidget);
    expect(find.byType(SkeletonBox), findsNothing);
  });

  testWidgets('stato vuoto con il primo patrimonio', (tester) async {
    await pumpApp(tester, store: emptyStore());
    expect(find.text('Non hai ancora nessun aggiornamento.'), findsOneWidget);
    expect(find.text('Inserisci il primo patrimonio'), findsOneWidget);
  });

  testWidgets('skeleton durante il caricamento', (tester) async {
    await pumpApp(tester, settle: false, latency: const Duration(seconds: 1));
    await tester.pump();
    expect(find.byType(SkeletonBox), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('€180.000'), findsOneWidget);
    // Il profilo (per il saluto) si carica dopo i dati: lasciamo finire l'attesa.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('errore di connessione comprensibile, con Riprova', (
    tester,
  ) async {
    final failing = FailingSnapshots();
    when(failing.fetchAll).thenThrow(const AppFailure(FailureKind.network));
    await pumpApp(
      tester,
      overrides: [snapshotRepositoryProvider.overrideWithValue(failing)],
    );
    expect(
      find.text('Non riesco a collegarmi. Controlla la connessione e riprova.'),
      findsOneWidget,
    );
    expect(find.text('Riprova'), findsOneWidget);
    expect(find.textContaining('AppFailure'), findsNothing);
  });

  testWidgets('desktop: sidebar e dashboard a più colonne', (tester) async {
    await pumpApp(tester, size: desktop);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Impostazioni'), findsOneWidget);
    expect(find.text('Aggiorna patrimonio'), findsNWidgets(2));
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets(
    'mese salvato vuoto: la dashboard mostra gli ultimi valori veri',
    (tester) async {
      final store = DemoDataset.build(const YearMonth(2026, 9));
      final august = store.snapshots.last;
      store.snapshots.add(
        Snapshot(
          id: 'settembre-vuoto',
          month: const YearMonth(2026, 9),
          items: [
            for (final item in august.items) item.copyWith(amount: Money.zero),
          ],
        ),
      );
      await pumpApp(tester, store: store);
      expect(find.text('€180.000'), findsOneWidget);
      expect(find.text('€0'), findsNothing);
      expect(find.textContaining('100,00%'), findsNothing);
      expect(
        find.text('È ora di aggiornare il tuo patrimonio.'),
        findsOneWidget,
      );
    },
  );
}
