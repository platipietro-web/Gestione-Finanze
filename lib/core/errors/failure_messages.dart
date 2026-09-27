import '../l10n/l10n.dart';
import 'app_failure.dart';

/// Messaggio comprensibile per ogni tipo di errore. Mai dettagli tecnici.
String failureMessage(AppLocalizations l10n, Object error) {
  final failure = AppFailure.from(error);
  return switch (failure.kind) {
    FailureKind.network => l10n.errorNetwork,
    FailureKind.sessionExpired => l10n.errorSessionExpired,
    FailureKind.invalidCredentials => l10n.errorInvalidCredentials,
    FailureKind.emailNotConfirmed => l10n.errorEmailNotConfirmed,
    FailureKind.emailAlreadyUsed => l10n.errorEmailAlreadyUsed,
    FailureKind.weakPassword => l10n.errorWeakPassword,
    FailureKind.samePassword => l10n.errorSamePassword,
    FailureKind.rateLimited => l10n.errorRateLimited,
    FailureKind.monthAlreadyExists => l10n.errorMonthAlreadyExists,
    FailureKind.categoryNotEmpty => l10n.errorCategoryNotEmpty,
    FailureKind.notFound => l10n.errorNotFound,
    FailureKind.permissionDenied => l10n.errorPermissionDenied,
    FailureKind.notConfigured => l10n.errorNotConfigured,
    FailureKind.invalidData => l10n.errorInvalidData,
    FailureKind.server => l10n.errorServer,
    FailureKind.unknown => l10n.errorUnknown,
  };
}
