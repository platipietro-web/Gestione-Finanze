import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
import '../repositories/auth_repository.dart';
import 'app_mode.dart';
import 'repository_providers.dart';

/// Stato dell'autenticazione, aggiornato a ogni evento di Supabase.
final authStateProvider = StreamProvider<AuthSnapshot>(
  (ref) => ref.watch(authRepositoryProvider).changes(),
);

/// Di chi sono i dati mostrati: un utente, la demo o nessuno.
///
/// Cambia solo quando cambia l'utente: il rinnovo del token non provoca
/// ricaricamenti. Quando cambia, tutti i provider di sessione si ricostruiscono,
/// quindi in memoria non restano dati dell'utente precedente.
@immutable
class DataScope {
  const DataScope.user(this.userId, this.email) : isDemo = false;
  const DataScope.demo() : userId = 'demo', email = null, isDemo = true;

  final String userId;
  final String? email;
  final bool isDemo;

  @override
  bool operator ==(Object other) =>
      other is DataScope &&
      other.userId == userId &&
      other.email == email &&
      other.isDemo == isDemo;

  @override
  int get hashCode => Object.hash(userId, email, isDemo);
}

final dataScopeProvider = Provider<DataScope?>((ref) {
  if (ref.watch(appModeProvider) == AppMode.demo) return const DataScope.demo();
  final user = ref.watch(authStateProvider).value?.user;
  return user == null ? null : DataScope.user(user.id, user.email);
});

final profileProvider = AsyncNotifierProvider<ProfileController, Profile?>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    final scope = ref.watch(dataScopeProvider);
    if (scope == null) return null;
    final repository = ref.watch(profileRepositoryProvider);
    return repository.fetch(AuthUser(id: scope.userId, email: scope.email));
  }

  Future<void> updateDisplayName(String? displayName) async {
    final profile = state.value ?? await future;
    if (profile == null) return;
    final updated = await ref
        .read(profileRepositoryProvider)
        .updateDisplayName(profile, displayName);
    state = AsyncData(updated);
  }

  Future<void> completeOnboarding() async {
    final profile = state.value ?? await future;
    if (profile == null) return;
    final updated = await ref
        .read(profileRepositoryProvider)
        .completeOnboarding(profile);
    state = AsyncData(updated);
  }
}

enum SessionStatus {
  /// Sessione o profilo in caricamento.
  loading,
  signedOut,

  /// L'utente ha aperto il link di reset e deve scegliere la password.
  passwordRecovery,
  needsOnboarding,
  ready,
}

/// Unica fonte per il controllo degli accessi del router.
final sessionStatusProvider = Provider<SessionStatus>((ref) {
  if (ref.watch(appModeProvider) == AppMode.demo) return SessionStatus.ready;
  final auth = ref.watch(authStateProvider);
  final snapshot = auth.value;
  if (snapshot == null) {
    return auth.hasError ? SessionStatus.signedOut : SessionStatus.loading;
  }
  if (!snapshot.isSignedIn) return SessionStatus.signedOut;
  if (snapshot.recovery) return SessionStatus.passwordRecovery;
  final profile = ref.watch(profileProvider).value;
  if (profile == null) return SessionStatus.loading;
  return profile.onboardingCompleted
      ? SessionStatus.ready
      : SessionStatus.needsOnboarding;
});
