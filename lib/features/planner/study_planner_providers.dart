import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/study_goal.dart';
import '../../data/providers.dart';

/// All study goals ordered by target date, soonest first (v1.20.0).
final studyGoalsProvider = Provider<List<StudyGoal>>((ref) {
  ref.watch(dataChangesProvider);
  return ref.watch(studyGoalRepositoryProvider).byDate();
});

/// A single study goal by id (reactive).
final studyGoalByIdProvider = Provider.family<StudyGoal?, String>((ref, id) {
  ref.watch(dataChangesProvider);
  return ref.watch(studyGoalRepositoryProvider).getById(id);
});

/// The next upcoming goal (target date today or later), soonest first, or null.
final nextStudyGoalProvider = Provider<StudyGoal?>((ref) {
  final goals = ref.watch(studyGoalsProvider);
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);
  for (final g in goals) {
    final t = DateTime(g.targetDate.year, g.targetDate.month, g.targetDate.day);
    if (!t.isBefore(todayOnly)) return g;
  }
  return null;
});

final studyPlannerControllerProvider =
    Provider<StudyPlannerController>((ref) => StudyPlannerController(ref));

/// Creates, updates and deletes local study goals. All data stays in Hive.
class StudyPlannerController {
  StudyPlannerController(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  String get _userId => _ref.read(currentProfileProvider)?.id ?? 'local';

  /// Creates a new study goal and returns its id.
  Future<String> create({
    required String title,
    required String subject,
    required DateTime targetDate,
    String description = '',
    StudyGoalStatus status = StudyGoalStatus.notStarted,
    String? documentId,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _ref.read(studyGoalRepositoryProvider).save(
          StudyGoal(
            id: id,
            userId: _userId,
            title: title.trim(),
            subject: subject.trim(),
            targetDate: targetDate,
            description: description.trim(),
            status: status,
            createdAt: now,
            updatedAt: now,
            documentId: documentId,
          ),
        );
    return id;
  }

  /// Updates an existing goal. Returns true if it existed.
  Future<bool> update(
    String id, {
    required String title,
    required String subject,
    required DateTime targetDate,
    required String description,
    required StudyGoalStatus status,
    String? documentId,
    bool clearDocumentId = false,
  }) async {
    final repo = _ref.read(studyGoalRepositoryProvider);
    final goal = repo.getById(id);
    if (goal == null) return false;
    await repo.save(
      goal.copyWith(
        title: title.trim(),
        subject: subject.trim(),
        targetDate: targetDate,
        description: description.trim(),
        status: status,
        updatedAt: DateTime.now().toUtc(),
        documentId: documentId,
        clearDocumentId: clearDocumentId,
      ),
    );
    return true;
  }

  Future<void> delete(String id) =>
      _ref.read(studyGoalRepositoryProvider).delete(id);
}

/// Human-readable label for a goal status.
String studyGoalStatusLabel(StudyGoalStatus status) {
  switch (status) {
    case StudyGoalStatus.notStarted:
      return 'Not started';
    case StudyGoalStatus.inProgress:
      return 'In progress';
    case StudyGoalStatus.ready:
      return 'Ready';
  }
}
