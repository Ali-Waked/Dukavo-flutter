import 'package:sqflite/sqflite.dart';

import 'cache_record.dart';
import 'cache_store.dart';

/// SQLite-backed cache.
///
/// A single table keeps the whole offline surface auditable: one row per
/// response, with its scope, path and expiry. The database is never queried by
/// screens; [CacheManager] owns all key and invalidation rules.
class SqliteCacheStore implements CacheStore {
  SqliteCacheStore({this.databaseName = 'dukavo_offline_cache.db'});

  final String databaseName;

  static const _table = 'cache_entries';

  Database? _database;

  Database get _db {
    final db = _database;
    if (db == null) {
      throw StateError('SqliteCacheStore.open() must complete before use.');
    }
    return db;
  }

  @override
  Future<void> open() async {
    if (_database != null) return;

    final databasesPath = await getDatabasesPath();
    _database = await openDatabase(
      '$databasesPath/$databaseName',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            key TEXT PRIMARY KEY,
            scope TEXT NOT NULL,
            path TEXT NOT NULL,
            payload TEXT NOT NULL,
            cached_at INTEGER NOT NULL,
            expires_at INTEGER
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_cache_scope ON $_table (scope)',
        );
      },
    );

    // Reclaim rows that outlived their stale window without making start-up
    // wait for a full vacuum.
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.delete(
      _table,
      where: 'expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: <Object>[now],
    );
  }

  @override
  Future<CacheRecord?> read(String key) async {
    final rows = await _db.query(
      _table,
      where: 'key = ?',
      whereArgs: <Object>[key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<void> write(CacheRecord record) async {
    await _db.insert(
      _table,
      _toRow(record),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String key) async {
    await _db.delete(_table, where: 'key = ?', whereArgs: <Object>[key]);
  }

  @override
  Future<void> deleteWhere({
    String? scope,
    String? pathPrefix,
    String? keyPrefix,
  }) async {
    final clauses = <String>[];
    final args = <Object>[];
    if (scope != null) {
      clauses.add('scope = ?');
      args.add(scope);
    }
    if (pathPrefix != null) {
      clauses.add('path LIKE ?');
      args.add('${_escapeLike(pathPrefix)}%');
    }
    if (keyPrefix != null) {
      clauses.add('key LIKE ?');
      args.add('${_escapeLike(keyPrefix)}%');
    }
    if (clauses.isEmpty) {
      await clear();
      return;
    }
    await _db.delete(
      _table,
      where: clauses.join(' AND '),
      whereArgs: args,
    );
  }

  @override
  Future<List<CacheRecord>> readAll({
    String? scope,
    String? keyPrefix,
  }) async {
    final clauses = <String>[];
    final args = <Object>[];
    if (scope != null) {
      clauses.add('scope = ?');
      args.add(scope);
    }
    if (keyPrefix != null) {
      clauses.add('key LIKE ?');
      args.add('${_escapeLike(keyPrefix)}%');
    }
    final rows = await _db.query(
      _table,
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'cached_at ASC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> clear() async {
    await _db.delete(_table);
  }

  @override
  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }

  Map<String, Object?> _toRow(CacheRecord record) {
    return <String, Object?>{
      'key': record.key,
      'scope': record.scope,
      'path': record.path,
      'payload': record.payload,
      'cached_at': record.cachedAt.millisecondsSinceEpoch,
      'expires_at': record.expiresAt?.millisecondsSinceEpoch,
    };
  }

  CacheRecord _fromRow(Map<String, Object?> row) {
    final expires = row['expires_at'];
    return CacheRecord(
      key: '${row['key']}',
      scope: '${row['scope']}',
      path: '${row['path']}',
      payload: '${row['payload']}',
      cachedAt: DateTime.fromMillisecondsSinceEpoch(
        row['cached_at'] as int? ?? 0,
      ),
      expiresAt:
          expires is int ? DateTime.fromMillisecondsSinceEpoch(expires) : null,
    );
  }

  String _escapeLike(String value) {
    return value.replaceAll(r'\', r'\\').replaceAll('%', r'\%');
  }
}
