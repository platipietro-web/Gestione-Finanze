import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_failure.dart';
import '../repositories/auth_repository.dart';
import 'repository_providers.dart';

final authControllerProvider =
    NotifierProvider.autoDispose<AuthController, AsyncValue<void>>(
      AuthController.new,
    );

/// Azioni di autenticazione. Lo stato indica se un'azione è in corso o se
/// l'ultima è fallita; la navigazione la decide il router in base alla sessione.
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> signIn({
    required String email,
    required String password,
  }) async => (await _run(
    () => _repository.signIn(email: email, password: password),
  )).ok;

  /// `null` se la registrazione non è riuscita.
  Future<SignUpOutcome?> signUp({
    required String email,
    required String password,
  }) async => (await _run(
    () => _repository.signUp(email: email, password: password),
  )).value;

  Future<bool> sendPasswordReset(String email) async =>
      (await _run(() => _repository.sendPasswordReset(email))).ok;

  Future<bool> updatePassword(String password) async =>
      (await _run(() => _repository.updatePassword(password))).ok;

  Future<bool> signOut() async => (await _run(_repository.signOut)).ok;

  Future<bool> deleteAccount() async =>
      (await _run(_repository.deleteAccount)).ok;

  void clearError() {
    if (state.hasError) state = const AsyncData(null);
  }

  Future<({bool ok, T? value})> _run<T>(Future<T> Function() action) async {
    state = const AsyncLoading();
    try {
      final value = await action();
      if (ref.mounted) state = const AsyncData(null);
      return (ok: true, value: value);
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(AppFailure.from(error), stackTrace);
      return (ok: false, value: null);
    }
  }
}
