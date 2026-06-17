import '../models/idea.dart';
import 'hive_repository.dart';

/// Stores project ideas from the Idea Lab.
class IdeaRepository extends HiveRepository<Idea> {
  IdeaRepository(super.box);

  @override
  String idOf(Idea item) => item.id;

  /// Most recently updated ideas first.
  List<Idea> recent([int limit = 5]) {
    final all = getAll()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return all.take(limit).toList();
  }
}
