import '../models/study_goal.dart';
import 'hive_repository.dart';

/// Stores local study goals / exams (v1.20.0 Study Planner).
class StudyGoalRepository extends HiveRepository<StudyGoal> {
  StudyGoalRepository(super.box);

  @override
  String idOf(StudyGoal item) => item.id;

  /// All goals ordered by their target date, soonest first.
  List<StudyGoal> byDate() {
    final all = getAll()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    return all;
  }
}
