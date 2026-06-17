import 'package:hive_ce/hive.dart';

import 'enums.dart';

part 'rewrite.g.dart';

/// A reworded version of some text from a [StudyDocument].
@HiveType(typeId: 4)
class Rewrite {
  Rewrite({
    required this.id,
    required this.documentId,
    required this.originalText,
    required this.rewrittenText,
    required this.tone,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String documentId;
  @HiveField(2)
  final String originalText;
  @HiveField(3)
  final String rewrittenText;
  @HiveField(4)
  final RewriteTone tone;
  @HiveField(5)
  final DateTime createdAt;
}
