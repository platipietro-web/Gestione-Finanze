import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  for (final scale in [1.5, 2.0]) {
    testWidgets(
      'testo al ${(scale * 100).round()}%: nessuna schermata si taglia',
      (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpApp(tester);

        // Dashboard, scorrendo fino in fondo.
        await tester.drag(
          find.byType(Scrollable).first,
          const Offset(0, -2000),
        );
        await tester.pumpAndSettle();

        for (final tab in ['Patrimonio', 'Investimenti', 'Storico']) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -2000),
          );
          await tester.pumpAndSettle();
        }

        await tester.tap(find.text('Home').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Aggiorna patrimonio'));
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(Scrollable).first,
          const Offset(0, -3000),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('le variazioni non si affidano solo al colore', (tester) async {
    await pumpApp(tester);
    final semantics = tester.getSemantics(find.textContaining('+€5.000').first);
    expect(semantics.label, contains('in aumento di 5.000 euro'));
    expect(semantics.label, contains('più 2,86 per cento'));
  });
}
