import 'package:hive_ce/hive.dart';

import 'enums.dart';

part 'activity_event.g.dart';

/// A record of something the student did. The dashboard stats and the recent
/// activity list are both computed from these events. [title] is denormalized
/// so the activity list can render without loading the referenced item.
@HiveType(typeId: 6)
class ActivityEvent {
  ActivityEvent({
    required this.id,
    required this.userId,
    required this.type,
    required this.referenceId,
    required this.title,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final ActivityType type;
  @HiveField(3)
  final String referenceId;
  @HiveField(4)
  final String title;
  @HiveField(5)
  final DateTime createdAt;
}
