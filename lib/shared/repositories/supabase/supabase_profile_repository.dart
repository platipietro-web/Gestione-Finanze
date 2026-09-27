import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../models/profile.dart';
import '../auth_repository.dart';
import '../profile_repository.dart';
import 'supabase_errors.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  static const _columns = 'id, display_name, onboarding_completed_at';

  @override
  Future<Profile> fetch(AuthUser user) => guardSupabase(() async {
    final row = await _client
        .from('profiles')
        .select(_columns)
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return Profile(id: user.id, email: user.email);
    return _map(row, user.email);
  });

  @override
  Future<Profile> updateDisplayName(Profile profile, String? displayName) =>
      guardSupabase(() async {
        final name = displayName?.trim();
        final row = await _client
            .from('profiles')
            .update({
              'display_name': (name == null || name.isEmpty) ? null : name,
            })
            .eq('id', profile.id)
            .select(_columns)
            .single();
        return _map(row, profile.email);
      });

  @override
  Future<Profile> completeOnboarding(Profile profile) => guardSupabase(
    () async {
      final row = await _client
          .from('profiles')
          .update({
            'onboarding_completed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', profile.id)
          .select(_columns)
          .single();
      return _map(row, profile.email);
    },
  );

  Profile _map(Map<String, dynamic> row, String? email) => Profile(
    id: row['id'] as String,
    email: email,
    displayName: row['display_name'] as String?,
    onboardingCompleted: row['onboarding_completed_at'] != null,
  );
}
