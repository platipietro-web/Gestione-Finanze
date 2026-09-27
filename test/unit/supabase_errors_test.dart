import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:patrimonio/core/errors/app_failure.dart';
import 'package:patrimonio/shared/repositories/supabase/supabase_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

FailureKind kindOf(Object error) => mapSupabaseError(error).kind;

void main() {
  test('errori di rete', () {
    expect(kindOf(ClientException('offline')), FailureKind.network);
    expect(kindOf(TimeoutException('lento')), FailureKind.network);
    expect(
      kindOf(AuthRetryableFetchException(message: 'x')),
      FailureKind.network,
    );
  });

  test('errori di autenticazione', () {
    expect(
      kindOf(const AuthException('x', code: 'invalid_credentials')),
      FailureKind.invalidCredentials,
    );
    expect(
      kindOf(const AuthException('x', code: 'email_not_confirmed')),
      FailureKind.emailNotConfirmed,
    );
    expect(
      kindOf(const AuthException('x', code: 'user_already_exists')),
      FailureKind.emailAlreadyUsed,
    );
    expect(
      kindOf(const AuthException('x', code: 'over_email_send_rate_limit')),
      FailureKind.rateLimited,
    );
    expect(
      kindOf(const AuthException('x', code: 'session_expired')),
      FailureKind.sessionExpired,
    );
    expect(
      kindOf(const AuthException('x', statusCode: '429')),
      FailureKind.rateLimited,
    );
  });

  test('errori del database', () {
    expect(
      kindOf(const PostgrestException(message: 'x', code: '23505')),
      FailureKind.monthAlreadyExists,
    );
    expect(
      kindOf(const PostgrestException(message: 'x', code: '23001')),
      FailureKind.categoryNotEmpty,
    );
    expect(
      kindOf(
        const PostgrestException(
          message:
              'update or delete on table "categories" violates foreign key '
              'constraint "items_category_id_user_id_fkey" on table "items"',
          code: '23503',
        ),
      ),
      FailureKind.categoryNotEmpty,
    );
    expect(
      kindOf(const PostgrestException(message: 'x', code: '23503')),
      FailureKind.invalidData,
    );
    expect(
      kindOf(const PostgrestException(message: 'x', code: '42501')),
      FailureKind.permissionDenied,
    );
    expect(
      kindOf(const PostgrestException(message: 'x', code: 'PGRST301')),
      FailureKind.sessionExpired,
    );
    expect(
      kindOf(const PostgrestException(message: 'x', code: '23514')),
      FailureKind.invalidData,
    );
    expect(
      kindOf(const PostgrestException(message: 'x', code: 'P0002')),
      FailureKind.notFound,
    );
  });

  test('tutto il resto: errore generico', () {
    expect(kindOf(StateError('boom')), FailureKind.unknown);
    expect(
      kindOf(const AppFailure(FailureKind.notFound)),
      FailureKind.notFound,
    );
  });
}
