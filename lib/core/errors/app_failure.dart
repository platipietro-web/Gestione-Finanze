/// Tipi di errore che l'interfaccia sa spiegare all'utente.
enum FailureKind {
  network,
  sessionExpired,
  invalidCredentials,
  emailNotConfirmed,
  emailAlreadyUsed,
  weakPassword,
  samePassword,
  rateLimited,
  monthAlreadyExists,
  categoryNotEmpty,
  notFound,
  permissionDenied,
  notConfigured,
  invalidData,
  server,
  unknown,
}

/// Errore già tradotto in un caso noto. Le schermate mostrano un messaggio
/// comprensibile; i dettagli tecnici restano in [debugMessage] e non
/// vengono mai mostrati all'utente.
class AppFailure implements Exception {
  const AppFailure(this.kind, {this.debugMessage});

  final FailureKind kind;
  final String? debugMessage;

  /// Converte qualsiasi errore in [AppFailure].
  static AppFailure from(Object error) {
    if (error is AppFailure) return error;
    return AppFailure(FailureKind.unknown, debugMessage: error.toString());
  }

  @override
  String toString() =>
      'AppFailure($kind${debugMessage == null ? '' : ': $debugMessage'})';
}
