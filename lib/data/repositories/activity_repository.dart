import '../models/activity_event.dart';
import 'hive_repository.dart';

/// Stores the activity log that powers dashboard stats and recent activity.
class ActivityRepository extends HiveRepository<ActivityEvent> {
  ActivityRepository(super.box);

  @override
  String idOf(ActivityEvent item) => item.id;

  /// Most recent events first.
  List<ActivityEvent> recent([int limit = 6]) {
    final all = getAll()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(limit).toList();
  }
}
