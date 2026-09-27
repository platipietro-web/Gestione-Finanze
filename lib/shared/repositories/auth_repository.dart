import 'package:flutter/foundation.dart';

import '../../core/errors/app_failure.dart';

@immutable
class AuthUser {
  const AuthUser({required this.id, this.email});

  final String id;
  final String? email;

  @override
  bool operator ==(Object other) =>
      other is AuthUser && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}

/// Stato dell'autenticazione in un certo momento.
@immutable
class AuthSnapshot {
  const AuthSnapshot({
    this.user,
    this.recovery = false,
    this.sessionExpired = false,
  });

  static const signedOut = AuthSnapshot();

  final AuthUser? user;

  /// L'utente ha aperto il link di reset password e deve sceglierne una nuova.
  final bool recovery;

  /// La sessione è terminata senza che l'utente abbia premuto "Esci".
  final bool sessionExpired;

  bool get isSignedIn => user != null;

  @override
  bool operator ==(Object other) =>
      other is AuthSnapshot &&
      other.user == user &&
      other.recovery == recovery &&
      other.sessionExpired == sessionExpired;

  @override
  int get hashCode => Object.hash(user, recovery, sessionExpired);
}

enum SignUpOutcome { signedIn, confirmationRequired }

abstract interface class AuthRepository {
  /// `false` quando Supabase non è configurato: è disponibile solo la demo.
  bool get isAvailable;

  AuthSnapshot get current;

  /// Emette subito lo stato corrente e poi ogni cambiamento.
  Stream<AuthSnapshot> changes();

  Future<void> signIn({required String email, required String password});

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> signOut();

  /// Cancella l'account e tutti i dati collegati, poi esce.
  Future<void> deleteAccount();
}

/// Usato quando mancano URL e chiave di Supabase.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  static const _failure = AppFailure(FailureKind.notConfigured);

  @override
  bool get isAvailable => false;

  @override
  AuthSnapshot get current => AuthSnapshot.signedOut;

  @override
  Stream<AuthSnapshot> changes() => Stream.value(AuthSnapshot.signedOut);

  @override
  Future<void> signIn({required String email, required String password}) =>
      Future.error(_failure);

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) => Future.error(_failure);

  @override
  Future<void> sendPasswordReset(String email) => Future.error(_failure);

  @override
  Future<void> updatePassword(String newPassword) => Future.error(_failure);

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() => Future.error(_failure);
}
