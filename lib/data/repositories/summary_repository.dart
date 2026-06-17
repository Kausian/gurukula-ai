import '../models/summary.dart';
import 'hive_repository.dart';

/// Stores AI-generated summaries.
class SummaryRepository extends HiveRepository<Summary> {
  SummaryRepository(super.box);

  @override
  String idOf(Summary item) => item.id;

  List<Summary> byDocument(String documentId) =>
      getAll().where((s) => s.documentId == documentId).toList();
}
