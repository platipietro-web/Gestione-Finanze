import '../models/profile.dart';
import 'auth_repository.dart';

abstract interface class ProfileRepository {
  Future<Profile> fetch(AuthUser user);

  Future<Profile> updateDisplayName(Profile profile, String? displayName);

  Future<Profile> completeOnboarding(Profile profile);
}
