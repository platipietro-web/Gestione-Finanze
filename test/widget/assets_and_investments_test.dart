import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('patrimonio: categorie, voci e nuova voce', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Patrimonio').last);
    await tester.pumpAndSettle();
    expect(find.text('LIQUIDITÀ'), findsOneWidget);
    expect(find.text('Conto Intesa'), findsOneWidget);
    expect(find.text('Conto Fineco'), findsOneWidget);
    expect(
      find.text("Valori dell'aggiornamento di agosto 2026"),
      findsOneWidget,
    );

    await tester.tap(find.text('Aggiungi voce').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Conto titoli');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('Conto titoli'), findsOneWidget);
  });

  testWidgets(
    'archiviare una voce la toglie dall\'elenco ma non dallo storico',
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Patrimonio').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contanti'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archivia'));
      await tester.pumpAndSettle();
      expect(find.text('Contanti'), findsNothing);
      await tester.scrollUntilVisible(find.textContaining('Archiviati'), 300);
      expect(find.text('Archiviati (1)'), findsOneWidget);

      await tester.tap(find.text('Storico').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agosto 2026'));
      await tester.pumpAndSettle();
      expect(find.text('Contanti'), findsOneWidget);
    },
  );

  testWidgets('investimenti: valore, variazioni e ripartizione', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Investimenti').last);
    await tester.pumpAndSettle();
    expect(find.text('Valore investimenti'), findsOneWidget);
    expect(find.text('Ultimo mese'), findsOneWidget);
    expect(find.text('Ultimi 12 mesi'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Ripartizione'), 300);
    expect(find.text('Fineco · ETF'), findsOneWidget);
    expect(find.text('Degiro · ETF'), findsOneWidget);
  });

  testWidgets('investimenti: stato vuoto senza voci di investimento', (
    tester,
  ) async {
    await pumpApp(tester, store: emptyStore());
    await tester.tap(find.text('Investimenti').last);
    await tester.pumpAndSettle();
    expect(find.text('Non hai ancora nessun aggiornamento.'), findsOneWidget);
  });
}
