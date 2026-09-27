import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/router/redirect.dart';
import 'package:patrimonio/shared/providers/session_providers.dart';

String? go(SessionStatus status, String location) =>
    resolveRedirect(status: status, uri: Uri.parse(location));

void main() {
  test('durante il caricamento si resta sulla schermata di avvio', () {
    expect(go(SessionStatus.loading, '/'), '/avvio');
    expect(go(SessionStatus.loading, '/storico'), '/avvio?da=%2Fstorico');
    expect(go(SessionStatus.loading, '/avvio'), isNull);
  });

  test('senza sessione solo le pagine pubbliche', () {
    expect(go(SessionStatus.signedOut, '/'), '/accedi');
    expect(
      go(SessionStatus.signedOut, '/investimenti'),
      '/accedi?da=%2Finvestimenti',
    );
    expect(go(SessionStatus.signedOut, '/registrati'), isNull);
    expect(go(SessionStatus.signedOut, '/password-dimenticata'), isNull);
    // Il reset richiede la sessione di recupero.
    expect(go(SessionStatus.signedOut, '/reimposta-password'), '/accedi');
    // Dall'avvio si conserva la pagina richiesta.
    expect(
      go(SessionStatus.signedOut, '/avvio?da=%2Fstorico'),
      '/accedi?da=%2Fstorico',
    );
  });

  test('dopo il login si torna alla pagina richiesta', () {
    expect(go(SessionStatus.ready, '/accedi?da=%2Fstorico'), '/storico');
    expect(go(SessionStatus.ready, '/accedi'), '/');
    expect(go(SessionStatus.ready, '/storico'), isNull);
  });

  test('i redirect verso altri siti sono ignorati', () {
    expect(go(SessionStatus.ready, '/accedi?da=%2F%2Fevil.com'), '/');
    expect(go(SessionStatus.ready, '/accedi?da=https%3A%2F%2Fevil.com'), '/');
  });

  test('onboarding e recupero password', () {
    expect(go(SessionStatus.needsOnboarding, '/'), '/benvenuto');
    expect(go(SessionStatus.needsOnboarding, '/benvenuto'), isNull);
    expect(go(SessionStatus.ready, '/benvenuto'), '/');
    expect(go(SessionStatus.passwordRecovery, '/'), '/reimposta-password');
    expect(go(SessionStatus.passwordRecovery, '/reimposta-password'), isNull);
  });
}
