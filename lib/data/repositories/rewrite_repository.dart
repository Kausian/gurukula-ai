import '../models/rewrite.dart';
import 'hive_repository.dart';

/// Stores text rewrites.
class RewriteRepository extends HiveRepository<Rewrite> {
  RewriteRepository(super.box);

  @override
  String idOf(Rewrite item) => item.id;

  List<Rewrite> byDocument(String documentId) =>
      getAll().where((r) => r.documentId == documentId).toList();
}
