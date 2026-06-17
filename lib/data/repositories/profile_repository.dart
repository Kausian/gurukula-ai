import '../models/user_profile.dart';
import 'hive_repository.dart';

/// Stores the single local student profile.
class ProfileRepository extends HiveRepository<UserProfile> {
  ProfileRepository(super.box);

  @override
  String idOf(UserProfile item) => item.id;

  /// The current profile, or null if the student has not set one up yet.
  UserProfile? get current {
    final all = getAll();
    return all.isEmpty ? null : all.first;
  }
}
