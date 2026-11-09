import 'cache_record.dart';
import 'cache_store.dart';

/// A deterministic in-memory cache used by tests and as a fallback when the
/// platform cannot open SQLite (for example a desktop build).
class MemoryCacheStore implements CacheStore {
  final Map<String, CacheRecord> _entries = <String, CacheRecord>{};

  @override
  Future<void> open() async {}

  @override
  Future<CacheRecord?> read(String key) async => _entries[key];

  @override
  Future<void> write(CacheRecord record) async {
    _entries[record.key] = record;
  }

  @override
  Future<void> delete(String key) async {
    _entries.remove(key);
  }

  @override
  Future<void> deleteWhere({
    String? scope,
    String? pathPrefix,
    String? keyPrefix,
  }) async {
    _entries.removeWhere((key, record) {
      if (scope != null && record.scope != scope) return false;
      if (pathPrefix != null && !record.path.startsWith(pathPrefix)) {
        return false;
      }
      if (keyPrefix != null && !key.startsWith(keyPrefix)) return false;
      return true;
    });
  }

  @override
  Future<List<CacheRecord>> readAll({
    String? scope,
    String? keyPrefix,
  }) async {
    final records = _entries.values.where((record) {
      if (scope != null && record.scope != scope) return false;
      if (keyPrefix != null && !record.key.startsWith(keyPrefix)) return false;
      return true;
    }).toList();
    records.sort((a, b) => a.cachedAt.compareTo(b.cachedAt));
    return records;
  }

  @override
  Future<void> clear() async {
    _entries.clear();
  }

  @override
  Future<void> close() async {}

  /// Test helpers.
  int get length => _entries.length;

  CacheRecord? operator [](String key) => _entries[key];
}
