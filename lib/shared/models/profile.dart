import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    String? email,
    String? displayName,
    @Default(false) bool onboardingCompleted,
  }) = _Profile;
}
