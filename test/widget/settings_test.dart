import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('tema scuro dalle impostazioni', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Apri le impostazioni'));
    await tester.pumpAndSettle();
    expect(find.text('Impostazioni'), findsOneWidget);
    expect(
      find.text(
        'Nella demo le impostazioni dell\'account non sono disponibili.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Scuro'));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Impostazioni'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
