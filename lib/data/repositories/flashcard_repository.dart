import '../models/flashcard.dart';
import 'hive_repository.dart';

/// Stores study flashcards.
class FlashcardRepository extends HiveRepository<Flashcard> {
  FlashcardRepository(super.box);

  @override
  String idOf(Flashcard item) => item.id;

  List<Flashcard> byDocument(String documentId) =>
      getAll().where((f) => f.documentId == documentId).toList();

  int get reviewedCount => getAll().where((f) => f.isReviewed).length;
}
