import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Shared CRUD on top of a Hive [Box], keyed by each item's id.
///
/// Concrete repositories add their own domain queries (recent, byDocument...).
abstract class HiveRepository<T> {
  HiveRepository(this.box);

  final Box<T> box;

  /// The stable id used as the storage key for [item].
  String idOf(T item);

  List<T> getAll() => box.values.toList();

  T? getById(String id) => box.get(id);

  Future<void> save(T item) => box.put(idOf(item), item);

  Future<void> saveAll(Iterable<T> items) =>
      box.putAll({for (final item in items) idOf(item): item});

  Future<void> delete(String id) => box.delete(id);

  Future<void> clearAll() => box.clear();

  /// Notifies listeners whenever the box changes (for live UI updates later).
  ValueListenable<Box<T>> listenable() => box.listenable();
}
