import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('storico: elenco, dettaglio, modifica ed eliminazione', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Storico').last);
    await tester.pumpAndSettle();

    expect(find.text('Agosto 2026'), findsOneWidget);
    expect(find.text('Luglio 2026'), findsOneWidget);

    await tester.tap(find.text('Luglio 2026'));
    await tester.pumpAndSettle();
    expect(find.text('€175.000'), findsOneWidget);
    expect(find.textContaining('rispetto a giugno'), findsOneWidget);
    expect(find.byTooltip('Modifica'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Modifica valori'), 300);
    expect(find.text('Modifica valori'), findsOneWidget);

    await tester.tap(find.byTooltip('Altre azioni'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina aggiornamento'));
    await tester.pumpAndSettle();
    expect(find.text("Eliminare l'aggiornamento di luglio?"), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Elimina'));
    await tester.pumpAndSettle();

    expect(find.text('Aggiornamento eliminato'), findsOneWidget);
    expect(find.text('Luglio 2026'), findsNothing);
    expect(find.text('Agosto 2026'), findsOneWidget);
  });

  testWidgets('desktop: elenco e dettaglio affiancati', (tester) async {
    await pumpApp(tester, size: desktop);
    await tester.tap(find.text('Storico'));
    await tester.pumpAndSettle();
    expect(
      find.text('Seleziona un aggiornamento per vedere il dettaglio.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Agosto 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Agosto 2026'), findsNWidgets(2));
    expect(find.text('Modifica'), findsOneWidget);
  });
}
