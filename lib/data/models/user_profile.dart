import 'package:hive_ce/hive.dart';

part 'user_profile.g.dart';

/// The student's profile. Stored locally; Firebase (Phase 3) only fills the
/// identity fields (googleUid, email, displayName, photoUrl).
@HiveType(typeId: 0)
class UserProfile {
  UserProfile({
    required this.id,
    this.googleUid,
    this.email,
    this.displayName,
    required this.username,
    this.photoUrl,
    required this.studyLevel,
    required this.mainSubject,
    required this.learningGoal,
    required this.preferredLanguage,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? googleUid;
  @HiveField(2)
  final String? email;
  @HiveField(3)
  final String? displayName;
  @HiveField(4)
  final String username;
  @HiveField(5)
  final String? photoUrl;
  @HiveField(6)
  final String studyLevel;
  @HiveField(7)
  final String mainSubject;
  @HiveField(8)
  final String learningGoal;
  @HiveField(9)
  final String preferredLanguage;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final DateTime updatedAt;
}
