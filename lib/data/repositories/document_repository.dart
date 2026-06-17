import '../models/study_document.dart';
import 'hive_repository.dart';

/// Stores uploaded study documents.
class DocumentRepository extends HiveRepository<StudyDocument> {
  DocumentRepository(super.box);

  @override
  String idOf(StudyDocument item) => item.id;

  /// Most recently updated documents first.
  List<StudyDocument> recent([int limit = 5]) {
    final all = getAll()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return all.take(limit).toList();
  }
}
