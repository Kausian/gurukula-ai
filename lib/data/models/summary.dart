import 'package:hive_ce/hive.dart';

part 'summary.g.dart';

/// An AI-generated summary of a [StudyDocument].
@HiveType(typeId: 2)
class Summary {
  Summary({
    required this.id,
    required this.documentId,
    required this.shortSummary,
    required this.detailedSummary,
    required this.keyPoints,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String documentId;
  @HiveField(2)
  final String shortSummary;
  @HiveField(3)
  final String detailedSummary;
  @HiveField(4)
  final List<String> keyPoints;
  @HiveField(5)
  final DateTime createdAt;
}
