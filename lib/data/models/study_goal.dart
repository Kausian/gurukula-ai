import 'package:hive_ce/hive.dart';

part 'study_goal.g.dart';

/// How ready the student feels for a [StudyGoal] (v1.20.0 Study Planner).
@HiveType(typeId: 16)
enum StudyGoalStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  ready,
}

/// A local study goal or exam the student is preparing for (v1.20.0).
///
/// Stored in its own Hive box; it references an optional [documentId] (a note)
/// but never owns it, so deleting a note never breaks a goal.
@HiveType(typeId: 15)
class StudyGoal {
  StudyGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.targetDate,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.documentId,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String title;

  /// Subject or module name, e.g. "Operating Systems".
  @HiveField(3)
  final String subject;

  /// The exam / target date the student wants to be ready by.
  @HiveField(4)
  final DateTime targetDate;

  /// Optional free-text description (empty string when none).
  @HiveField(5)
  final String description;

  @HiveField(6)
  final StudyGoalStatus status;

  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final DateTime updatedAt;

  /// Optional linked note. Null when the goal isn't tied to a specific note.
  @HiveField(9)
  final String? documentId;

  StudyGoal copyWith({
    String? title,
    String? subject,
    DateTime? targetDate,
    String? description,
    StudyGoalStatus? status,
    DateTime? updatedAt,
    String? documentId,
    bool clearDocumentId = false,
  }) {
    return StudyGoal(
      id: id,
      userId: userId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documentId: clearDocumentId ? null : (documentId ?? this.documentId),
    );
  }
}
