import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrimonio/core/errors/app_failure.dart';
import 'package:patrimonio/features/onboarding/presentation/onboarding_screen.dart';
import 'package:patrimonio/shared/providers/repository_providers.dart';
import 'package:patrimonio/shared/repositories/auth_repository.dart';

import '../helpers/test_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('senza configurazione: avviso e accesso alla demo', (
    tester,
  ) async {
    await pumpApp(tester, demo: false);
    expect(find.text('Accedi'), findsWidgets);
    expect(
      find.text(
        "Il collegamento al server non è configurato. Puoi provare l'app in modalità demo.",
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Prova la demo'));
    await tester.pumpAndSettle();
    expect(find.text('€180.000'), findsOneWidget);

    // Uscire dalla demo riporta al login.
    await tester.tap(find.text('Esci'));
    await tester.pumpAndSettle();
    expect(find.text('Prova la demo'), findsOneWidget);
  });

  testWidgets('login: validazione e credenziali errate', (tester) async {
    final auth = MockAuthRepository();
    when(() => auth.isAvailable).thenReturn(true);
    when(() => auth.current).thenReturn(AuthSnapshot.signedOut);
    when(auth.changes).thenAnswer((_) => Stream.value(AuthSnapshot.signedOut));
    when(
      () => auth.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AppFailure(FailureKind.invalidCredentials));

    await pumpApp(
      tester,
      demo: false,
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    final loginButton = find.widgetWithText(FilledButton, 'Accedi');

    await tester.enterText(find.byType(TextFormField).at(0), 'non-una-email');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text("Inserisci un'email valida"), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'mario@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'sbagliata');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text('Email o password non corrette.'), findsOneWidget);
  });

  testWidgets('sessione scaduta: il login lo spiega', (tester) async {
    final auth = MockAuthRepository();
    when(() => auth.isAvailable).thenReturn(true);
    when(() => auth.current).thenReturn(AuthSnapshot.signedOut);
    when(
      auth.changes,
    ).thenAnswer((_) => Stream.value(const AuthSnapshot(sessionExpired: true)));
    await pumpApp(
      tester,
      demo: false,
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    expect(
      find.text('La sessione è scaduta. Accedi di nuovo.'),
      findsOneWidget,
    );
  });

  testWidgets('registrazione: password troppo corta', (tester) async {
    final auth = MockAuthRepository();
    when(() => auth.isAvailable).thenReturn(true);
    when(() => auth.current).thenReturn(AuthSnapshot.signedOut);
    when(auth.changes).thenAnswer((_) => Stream.value(AuthSnapshot.signedOut));
    await pumpApp(
      tester,
      demo: false,
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    await tester.tap(find.text('Registrati'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'mario@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'corta');
    await tester.tap(find.text('Crea account'));
    await tester.pumpAndSettle();
    expect(
      find.text('La password deve avere almeno 8 caratteri'),
      findsOneWidget,
    );
    verifyNever(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('onboarding in tre passi crea il primo patrimonio', (
    tester,
  ) async {
    final store = emptyStore(onboarded: false);
    await pumpWidgetInApp(tester, const OnboardingScreen(), store: store);

    expect(find.text('Benvenuto'), findsOneWidget);
    expect(
      find.text('Monitora il tuo patrimonio aggiornandolo una volta al mese.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Inizia'));
    await tester.pumpAndSettle();

    expect(find.text('Cosa possiedi?'), findsOneWidget);
    await tester.ensureVisible(find.text('Mutuo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mutuo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continua'));
    await tester.pumpAndSettle();

    expect(find.text('Quanto vale oggi?'), findsOneWidget);
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3));
    await tester.enterText(fields.at(0), '12.500');
    await tester.enterText(fields.at(1), '75.000');
    await tester.enterText(fields.at(2), '40.000');
    await tester.pump();
    expect(find.text('€47.500'), findsOneWidget);

    await tester.tap(find.text('Salva e vai alla home'));
    await tester.pumpAndSettle();
    expect(store.profile.onboardingCompleted, isTrue);
    expect(store.items.map((i) => i.name), ['Conto corrente', 'ETF', 'Mutuo']);
    expect(store.snapshots, hasLength(1));
  });

  testWidgets('onboarding: senza importi non si salva', (tester) async {
    final store = emptyStore(onboarded: false);
    await pumpWidgetInApp(tester, const OnboardingScreen(), store: store);
    await tester.tap(find.text('Inizia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva e vai alla home'));
    await tester.pumpAndSettle();
    expect(
      find.text('Inserisci almeno un importo diverso da zero.'),
      findsOneWidget,
    );
    expect(store.snapshots, isEmpty);
    expect(store.profile.onboardingCompleted, isFalse);
  });
}
