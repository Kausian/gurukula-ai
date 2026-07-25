import 'package:hive_ce/hive.dart';

import 'enums.dart';

part 'study_document.g.dart';

/// A piece of study material (pasted text, a PDF, or a scanned image) that the
/// student uploaded. Its summaries, flashcards and rewrites reference its [id].
@HiveType(typeId: 1)
class StudyDocument {
  StudyDocument({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.rawText,
    required this.cleanedText,
    this.sourceFileName,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final DocumentType type;
  @HiveField(4)
  final String rawText;
  @HiveField(5)
  final String cleanedText;
  @HiveField(6)
  final String? sourceFileName;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final DateTime updatedAt;

  /// Returns a copy with the given fields replaced. Used by the note editor
  /// (v1.16.0) to persist title/body edits without touching the Hive schema —
  /// the field layout is identical, so existing stored notes stay compatible.
  StudyDocument copyWith({
    String? title,
    String? rawText,
    String? cleanedText,
    String? sourceFileName,
    DateTime? updatedAt,
  }) {
    return StudyDocument(
      id: id,
      userId: userId,
      title: title ?? this.title,
      type: type,
      rawText: rawText ?? this.rawText,
      cleanedText: cleanedText ?? this.cleanedText,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
