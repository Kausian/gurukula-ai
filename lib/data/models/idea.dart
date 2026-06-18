import 'package:hive_ce/hive.dart';

import 'enums.dart';

part 'idea.g.dart';

/// A student project idea generated or refined in the Idea Lab.
@HiveType(typeId: 5)
class Idea {
  Idea({
    required this.id,
    required this.userId,
    required this.title,
    required this.problem,
    required this.targetUsers,
    required this.features,
    required this.techStack,
    required this.difficulty,
    required this.mvpPlan,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.whyUnique,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String problem;
  @HiveField(4)
  final List<String> targetUsers;
  @HiveField(5)
  final List<String> features;
  @HiveField(6)
  final List<String> techStack;
  @HiveField(7)
  final Difficulty difficulty;
  @HiveField(8)
  final String mvpPlan;
  @HiveField(9)
  final String notes;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final DateTime updatedAt;

  /// Why the idea stands out (Phase 6). Nullable so ideas saved before this
  /// field existed still load.
  @HiveField(12)
  final String? whyUnique;

  Idea copyWith({
    String? title,
    String? problem,
    List<String>? targetUsers,
    List<String>? features,
    List<String>? techStack,
    Difficulty? difficulty,
    String? mvpPlan,
    String? notes,
    DateTime? updatedAt,
    String? whyUnique,
  }) {
    return Idea(
      id: id,
      userId: userId,
      title: title ?? this.title,
      problem: problem ?? this.problem,
      targetUsers: targetUsers ?? this.targetUsers,
      features: features ?? this.features,
      techStack: techStack ?? this.techStack,
      difficulty: difficulty ?? this.difficulty,
      mvpPlan: mvpPlan ?? this.mvpPlan,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      whyUnique: whyUnique ?? this.whyUnique,
    );
  }
}
