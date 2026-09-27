import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../core/config/app_config.dart';
import '../auth_repository.dart';
import 'supabase_errors.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;
  bool _recovery = false;
  bool _signingOut = false;
  bool _expired = false;
  bool _hadSession = false;

  GoTrueClient get _auth => _client.auth;

  @override
  bool get isAvailable => true;

  @override
  AuthSnapshot get current => _snapshot(_auth.currentUser);

  @override
  Stream<AuthSnapshot> changes() async* {
    yield current;
    // Senza rete il rinnovo del token può emettere un errore: lo si ignora,
    // così l'ascolto continua e la sessione resta valida finché il server
    // non dice il contrario (le chiamate successive lo segnaleranno).
    final events = _auth.onAuthStateChange.handleError((Object error) {
      if (kDebugMode) debugPrint('Auth: $error');
    }, test: (error) => error is AuthException);
    await for (final state in events) {
      switch (state.event) {
        case AuthChangeEvent.passwordRecovery:
          _recovery = true;
        case AuthChangeEvent.signedOut:
          _recovery = false;
          // Uscita non richiesta dall'utente: la sessione è scaduta.
          _expired = _hadSession && !_signingOut;
          _signingOut = false;
        case AuthChangeEvent.userUpdated:
          _recovery = false;
        default:
          break;
      }
      final user = state.session?.user;
      if (user != null) {
        _hadSession = true;
        _expired = false;
      } else {
        _hadSession = false;
      }
      yield _snapshot(user);
    }
  }

  AuthSnapshot _snapshot(User? user) => AuthSnapshot(
    user: user == null ? null : AuthUser(id: user.id, email: user.email),
    recovery: user != null && _recovery,
    sessionExpired: user == null && _expired,
  );

  /// Sul web si torna all'indirizzo dell'app; su iOS e Android si usa lo
  /// schema dell'app, gestito da supabase_flutter.
  String _redirect(String webPath) =>
      kIsWeb ? '${Uri.base.origin}$webPath' : AppConfig.mobileAuthCallback;

  @override
  Future<void> signIn({required String email, required String password}) =>
      guardSupabase(
        () => _auth.signInWithPassword(email: email.trim(), password: password),
      );

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) => guardSupabase(() async {
    final response = await _auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: _redirect('/'),
    );
    return response.session == null
        ? SignUpOutcome.confirmationRequired
        : SignUpOutcome.signedIn;
  });

  @override
  Future<void> sendPasswordReset(String email) => guardSupabase(
    () => _auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: _redirect('/reimposta-password'),
    ),
  );

  @override
  Future<void> updatePassword(String newPassword) => guardSupabase(() async {
    await _auth.updateUser(UserAttributes(password: newPassword));
    _recovery = false;
  });

  @override
  Future<void> signOut() => guardSupabase(() async {
    _signingOut = true;
    await _auth.signOut();
  });

  @override
  Future<void> deleteAccount() => guardSupabase(() async {
    await _client.rpc<void>('delete_my_account');
    _signingOut = true;
    try {
      await _auth.signOut();
    } on AuthException {
      // L'utente non esiste più sul server: la sessione locale viene
      // comunque rimossa.
    }
  });
}
