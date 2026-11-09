import 'cache_record.dart';

/// Persistence contract for the offline cache.
///
/// The app uses SQLite at runtime and [MemoryCacheStore] in tests and on
/// platforms without SQLite. The contract is intentionally small: the cache
/// manager owns keys, scopes and policy, so a store only has to persist rows.
abstract class CacheStore {
  Future<void> open();

  Future<CacheRecord?> read(String key);

  Future<void> write(CacheRecord record);

  Future<void> delete(String key);

  Future<void> deleteWhere({
    String? scope,
    String? pathPrefix,
    String? keyPrefix,
  });

  Future<List<CacheRecord>> readAll({String? scope, String? keyPrefix});

  Future<void> clear();

  Future<void> close();
}
