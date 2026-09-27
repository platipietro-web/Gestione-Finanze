import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_failure.dart';

/// Esegue [body] e traduce ogni errore di Supabase in [AppFailure].
Future<T> guardSupabase<T>(Future<T> Function() body) async {
  try {
    return await body();
  } catch (error, stackTrace) {
    final failure = mapSupabaseError(error);
    if (kDebugMode) {
      // Solo in sviluppo, e mai con importi: i messaggi di Supabase non
      // contengono dati finanziari.
      debugPrint('Supabase: $failure');
      debugPrintStack(stackTrace: stackTrace, maxFrames: 5);
    }
    throw failure;
  }
}

AppFailure mapSupabaseError(Object error) {
  if (error is AppFailure) return error;
  if (error is AuthRetryableFetchException ||
      error is ClientException ||
      error is TimeoutException) {
    return AppFailure(FailureKind.network, debugMessage: '$error');
  }
  if (error is AuthException) return _mapAuth(error);
  if (error is PostgrestException) return _mapPostgrest(error);
  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('XMLHttpRequest')) {
    return AppFailure(FailureKind.network, debugMessage: text);
  }
  return AppFailure(FailureKind.unknown, debugMessage: text);
}

AppFailure _mapAuth(AuthException error) {
  final kind = switch (error.code) {
    'invalid_credentials' => FailureKind.invalidCredentials,
    'email_not_confirmed' => FailureKind.emailNotConfirmed,
    'user_already_exists' || 'email_exists' => FailureKind.emailAlreadyUsed,
    'weak_password' => FailureKind.weakPassword,
    'same_password' => FailureKind.samePassword,
    'over_email_send_rate_limit' ||
    'over_request_rate_limit' => FailureKind.rateLimited,
    'session_expired' ||
    'session_not_found' ||
    'refresh_token_not_found' ||
    'refresh_token_already_used' ||
    'bad_jwt' => FailureKind.sessionExpired,
    _ => null,
  };
  if (kind != null) return AppFailure(kind, debugMessage: error.message);
  if (error is AuthWeakPasswordException) {
    return AppFailure(FailureKind.weakPassword, debugMessage: error.message);
  }
  if (error is AuthSessionMissingException) {
    return AppFailure(FailureKind.sessionExpired, debugMessage: error.message);
  }
  if (error.statusCode == '429') {
    return AppFailure(FailureKind.rateLimited, debugMessage: error.message);
  }
  if (error.statusCode == '400' &&
      error.message.toLowerCase().contains('invalid login')) {
    return AppFailure(
      FailureKind.invalidCredentials,
      debugMessage: error.message,
    );
  }
  return AppFailure(FailureKind.unknown, debugMessage: error.message);
}

AppFailure _mapPostgrest(PostgrestException error) {
  // Eliminare una categoria con voci viola il vincolo RESTRICT: 23001 nelle
  // versioni recenti di PostgreSQL, 23503 nelle precedenti.
  final categoryInUse = error.message.contains(
    'items_category_id_user_id_fkey',
  );
  final kind = switch (error.code) {
    // Violazione di unicità: il mese ha già un aggiornamento.
    '23505' => FailureKind.monthAlreadyExists,
    '23001' => FailureKind.categoryNotEmpty,
    '23503' when categoryInUse => FailureKind.categoryNotEmpty,
    // Altre chiavi esterne: riferimento a dati che non esistono più.
    '23503' => FailureKind.invalidData,
    '23502' || '23514' || '22P02' || '22023' => FailureKind.invalidData,
    '42501' => FailureKind.permissionDenied,
    'P0002' || 'PGRST116' => FailureKind.notFound,
    'PGRST301' || 'PGRST303' || '28000' => FailureKind.sessionExpired,
    _ => null,
  };
  if (kind != null) return AppFailure(kind, debugMessage: error.message);
  final code = error.code ?? '';
  if (code.startsWith('5') || code.startsWith('PGRST')) {
    return AppFailure(FailureKind.server, debugMessage: error.message);
  }
  return AppFailure(FailureKind.unknown, debugMessage: error.message);
}
