import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/shared/repositories/demo/demo_dataset.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets(
    'aggiornamento mensile completo: valori, totale in tempo reale, salvataggio',
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Aggiorna patrimonio'));
      await tester.pumpAndSettle();

      expect(find.text('Settembre 2026'), findsOneWidget);
      expect(
        find.text(
          "Valori copiati dall'aggiornamento di agosto 2026: modifica solo quello che è cambiato.",
        ),
        findsOneWidget,
      );

      // Il primo campo è il conto corrente: aggiungiamo 540 euro.
      final current = DemoDataset.valuesFor(23)['demo-item-current']!;
      await tester.enterText(find.byType(TextField).first, '${current + 540}');
      await tester.pump();
      expect(find.text('€180.540'), findsOneWidget);
      expect(find.textContaining('+€540'), findsOneWidget);

      await tester.tap(find.text('Salva aggiornamento'));
      await tester.pumpAndSettle();

      expect(find.text('Aggiornamento salvato'), findsOneWidget);
      expect(find.text('€180.540'), findsOneWidget);
      // Il mese corrente ora c'è: niente più promemoria.
      expect(find.text('È ora di aggiornare il tuo patrimonio.'), findsNothing);
    },
  );

  testWidgets('un importo non valido mostra un messaggio chiaro', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Aggiorna patrimonio'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '12,345');
    await tester.pump();
    expect(find.text('Usa al massimo due decimali.'), findsOneWidget);
    await tester.tap(find.text('Salva aggiornamento'));
    await tester.pumpAndSettle();
    expect(
      find.text('Correggi i campi segnalati prima di salvare.'),
      findsOneWidget,
    );
  });

  testWidgets('chiudere con modifiche non salvate chiede conferma', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Aggiorna patrimonio'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pump();
    await tester.tap(find.byTooltip('Chiudi'));
    await tester.pumpAndSettle();
    expect(find.text('Uscire senza salvare?'), findsOneWidget);
    await tester.tap(find.text('Esci senza salvare'));
    await tester.pumpAndSettle();
    expect(find.text('€180.000'), findsOneWidget);
  });

  testWidgets('desktop: riepilogo fisso accanto al form', (tester) async {
    await pumpApp(tester, size: desktop);
    await tester.tap(find.text('Aggiorna patrimonio').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Riepilogo · Settembre 2026'), findsOneWidget);
    expect(
      find.text('Tab: campo successivo · Ctrl/Cmd+S: salva · Esc: chiudi'),
      findsOneWidget,
    );
  });

  testWidgets('si sceglie un mese passato dal selettore, non uno futuro', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Aggiorna patrimonio'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settembre 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Scegli il mese'), findsOneWidget);

    // Ottobre 2026 è nel futuro: non si può scegliere.
    await tester.tap(find.text('Ott'));
    await tester.pumpAndSettle();
    expect(find.text('Scegli il mese'), findsOneWidget);

    await tester.tap(find.text('Lug'));
    await tester.pumpAndSettle();
    expect(find.text('Luglio 2026'), findsOneWidget);
    expect(
      find.text("Stai modificando l'aggiornamento di luglio."),
      findsOneWidget,
    );
  });

  testWidgets('si può andare indietro di anni', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Aggiorna patrimonio'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settembre 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Anno precedente'));
    await tester.pumpAndSettle();
    expect(find.text('2025'), findsOneWidget);
    await tester.tap(find.text('Mar'));
    await tester.pumpAndSettle();
    expect(find.text('Marzo 2025'), findsOneWidget);
    expect(
      find.text("Stai modificando l'aggiornamento di marzo."),
      findsOneWidget,
    );

    // Un mese prima dell'inizio della demo: i valori non partono da zero ma
    // dal primo aggiornamento disponibile (settembre 2024, €118.000).
    await tester.tap(find.text('Marzo 2025'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Anno precedente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gen'));
    await tester.pumpAndSettle();
    expect(find.text('Gennaio 2024'), findsOneWidget);
    expect(
      find.text(
        "Valori copiati dall'aggiornamento di settembre 2024: "
        'modifica solo quello che è cambiato.',
      ),
      findsOneWidget,
    );
    expect(find.text('€118.000'), findsOneWidget);
    expect(find.text('Primo aggiornamento'), findsOneWidget);
  });
}
