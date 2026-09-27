import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrimonio/core/errors/app_failure.dart';
import 'package:patrimonio/shared/models/catalog.dart';
import 'package:patrimonio/shared/models/profile.dart';
import 'package:patrimonio/shared/providers/app_mode.dart';
import 'package:patrimonio/shared/providers/auth_controller.dart';
import 'package:patrimonio/shared/providers/catalog_providers.dart';
import 'package:patrimonio/shared/providers/repository_providers.dart';
import 'package:patrimonio/shared/providers/session_providers.dart';
import 'package:patrimonio/shared/repositories/auth_repository.dart';
import 'package:patrimonio/shared/repositories/catalog_repository.dart';
import 'package:patrimonio/shared/repositories/profile_repository.dart';

import '../helpers/test_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthUser(id: 'x'));
    registerFallbackValue(const Profile(id: 'x'));
  });

  group('AuthController', () {
    late MockAuthRepository auth;

    setUp(() {
      auth = MockAuthRepository();
      when(() => auth.changes()).thenAnswer((_) => const Stream.empty());
    });

    test('accesso riuscito', () async {
      when(
        () => auth.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});
      final container = makeContainer(
        demo: false,
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );
      container.listen(authControllerProvider, (_, _) {});
      final ok = await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'a@b.it', password: 'segreta123');
      expect(ok, isTrue);
      expect(container.read(authControllerProvider).hasError, isFalse);
    });

    test('credenziali errate: errore comprensibile nello stato', () async {
      when(
        () => auth.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AppFailure(FailureKind.invalidCredentials));
      final container = makeContainer(
        demo: false,
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );
      container.listen(authControllerProvider, (_, _) {});
      final ok = await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'a@b.it', password: 'sbagliata');
      expect(ok, isFalse);
      final error = container.read(authControllerProvider).error;
      expect(
        error,
        isA<AppFailure>().having(
          (f) => f.kind,
          'kind',
          FailureKind.invalidCredentials,
        ),
      );
    });

    test('registrazione con conferma email', () async {
      when(
        () => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => SignUpOutcome.confirmationRequired);
      final container = makeContainer(
        demo: false,
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );
      container.listen(authControllerProvider, (_, _) {});
      final outcome = await container
          .read(authControllerProvider.notifier)
          .signUp(email: 'a@b.it', password: 'segreta123');
      expect(outcome, SignUpOutcome.confirmationRequired);
    });

    test(
      'errori sconosciuti diventano AppFailure senza dettagli tecnici',
      () async {
        when(() => auth.signOut()).thenThrow(StateError('boom'));
        final container = makeContainer(
          demo: false,
          overrides: [authRepositoryProvider.overrideWithValue(auth)],
        );
        container.listen(authControllerProvider, (_, _) {});
        expect(
          await container.read(authControllerProvider.notifier).signOut(),
          isFalse,
        );
        expect(
          container.read(authControllerProvider).error,
          isA<AppFailure>().having((f) => f.kind, 'kind', FailureKind.unknown),
        );
      },
    );
  });

  group('Stato della sessione', () {
    late StreamController<AuthSnapshot> events;
    late MockAuthRepository auth;
    late MockProfileRepository profiles;
    late MockCatalogRepository catalogs;

    setUp(() {
      events = StreamController<AuthSnapshot>.broadcast();
      auth = MockAuthRepository();
      profiles = MockProfileRepository();
      catalogs = MockCatalogRepository();
      when(() => auth.changes()).thenAnswer((_) => events.stream);
      when(() => catalogs.fetch()).thenAnswer((_) async => Catalog.empty);
    });

    tearDown(() => events.close());

    ProviderContainer Function() containerFor() =>
        () => makeContainer(
          demo: false,
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            profileRepositoryProvider.overrideWithValue(profiles),
            catalogRepositoryProvider.overrideWithValue(catalogs),
          ],
        );

    test('caricamento, uscita, onboarding, pronto, recupero', () async {
      final container = containerFor()();
      final statuses = <SessionStatus>[];
      container.listen(
        sessionStatusProvider,
        (_, next) => statuses.add(next),
        fireImmediately: true,
      );
      expect(container.read(sessionStatusProvider), SessionStatus.loading);

      events.add(AuthSnapshot.signedOut);
      await pumpEventQueue();
      expect(container.read(sessionStatusProvider), SessionStatus.signedOut);

      when(
        () => profiles.fetch(any()),
      ).thenAnswer((_) async => const Profile(id: 'u1'));
      events.add(
        const AuthSnapshot(
          user: AuthUser(id: 'u1', email: 'a@b.it'),
        ),
      );
      await pumpEventQueue();
      expect(
        container.read(sessionStatusProvider),
        SessionStatus.needsOnboarding,
      );

      when(() => profiles.completeOnboarding(any())).thenAnswer(
        (_) async => const Profile(id: 'u1', onboardingCompleted: true),
      );
      await container.read(profileProvider.notifier).completeOnboarding();
      expect(container.read(sessionStatusProvider), SessionStatus.ready);

      events.add(
        const AuthSnapshot(
          user: AuthUser(id: 'u1', email: 'a@b.it'),
          recovery: true,
        ),
      );
      await pumpEventQueue();
      expect(
        container.read(sessionStatusProvider),
        SessionStatus.passwordRecovery,
      );
    });

    test('al cambio utente la cache dei dati viene ricaricata', () async {
      final container = containerFor()();
      when(() => profiles.fetch(any())).thenAnswer(
        (invocation) async => Profile(
          id: (invocation.positionalArguments.first as AuthUser).id,
          onboardingCompleted: true,
        ),
      );
      container.listen(catalogProvider, (_, _) {});
      events.add(const AuthSnapshot(user: AuthUser(id: 'u1')));
      await pumpEventQueue();
      await container.read(catalogProvider.future);
      verify(() => catalogs.fetch()).called(1);

      events.add(AuthSnapshot.signedOut);
      await pumpEventQueue();
      expect(container.read(dataScopeProvider), isNull);

      events.add(const AuthSnapshot(user: AuthUser(id: 'u2')));
      await pumpEventQueue();
      await container.read(catalogProvider.future);
      verify(() => catalogs.fetch()).called(1);
    });

    test('la demo è sempre pronta e non tocca l\'autenticazione', () async {
      final container = makeContainer(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );
      expect(container.read(sessionStatusProvider), SessionStatus.ready);
      expect(container.read(appModeProvider), AppMode.demo);
      expect(container.read(dataScopeProvider)!.isDemo, isTrue);
    });
  });
}
