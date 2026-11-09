import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'cache_policy.dart';
import 'cache_record.dart';
import 'cache_scope.dart';
import 'cache_store.dart';

/// The one place that knows how to key, expire and invalidate cached reads.
///
/// Repositories and screens keep talking to [ApiClient]; this class sits under
/// it so no feature has to learn about SQLite or TTLs.
class CacheManager extends ChangeNotifier {
  CacheManager(this._store, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final CacheStore _store;
  final DateTime Function() _clock;

  CacheScope _scope = CacheScope.public;
  String _language = 'en';
  bool _opened = false;

  CacheScope get scope => _scope;
  String get language => _language;

  /// The last time any response was written, for diagnostics and the sync
  /// banner. Not persisted: the per-row timestamp is the source of truth.
  DateTime? get lastWriteAt => _lastWriteAt;
  DateTime? _lastWriteAt;

  Future<void> open() async {
    if (_opened) return;
    await _store.open();
    _opened = true;
  }

  void setScope(CacheScope next) {
    if (next == _scope) return;
    _scope = next;
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    final next = languageCode == 'ar' ? 'ar' : 'en';
    if (next == _language) return;
    _language = next;
  }

  /* ----------------------------------------------------------------- reads */

  Future<CachedResponse?> read(
    String path, {
    Map<String, dynamic>? query,
    String method = 'GET',
    CacheScope? scopeOverride,
  }) async {
    final policy = CachePolicy.forPath(method, path);
    if (!policy.cacheable) return null;

    final scope = scopeOverride ?? scopeForPath(path, _scope);
    if (scope == null || scope.isSession) return null;

    CacheRecord? record;
    try {
      record = await _store.read(
        _key(method: method, path: path, query: query, scope: scope),
      );
    } catch (_) {
      return null;
    }
    if (record == null) return null;

    final now = _clock();
    if (record.isExpired(now)) {
      await _safeDelete(record.key);
      return null;
    }

    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(record.payload);
      if (decoded is Map) body = Map<String, dynamic>.from(decoded);
    } on FormatException {
      body = null;
    }
    if (body == null) {
      await _safeDelete(record.key);
      return null;
    }

    return CachedResponse(
      body: body,
      cachedAt: record.cachedAt,
      isStale: now.difference(record.cachedAt) > policy.ttl,
    );
  }

  /* ---------------------------------------------------------------- writes */

  Future<void> write(
    String path,
    Map<String, dynamic> envelope, {
    Map<String, dynamic>? query,
    String method = 'GET',
    CacheScope? scopeOverride,
  }) async {
    final policy = CachePolicy.forPath(method, path);
    if (!policy.cacheable) return;

    final scope = scopeOverride ?? scopeForPath(path, _scope);
    if (scope == null || scope.isSession) return;

    final now = _clock();
    final record = CacheRecord(
      key: _key(method: method, path: path, query: query, scope: scope),
      scope: scope.key,
      path: path,
      payload: jsonEncode(envelope),
      cachedAt: now,
      expiresAt: now.add(policy.ttl + policy.maxStale),
    );

    try {
      await _store.write(record);
      _lastWriteAt = now;
    } catch (_) {
      // A cache write must never fail a request that already succeeded.
    }
  }

  /// Remove cached reads that a successful mutation has invalidated.
  Future<void> invalidateMutation(String method, String path) async {
    final upper = method.toUpperCase();
    if (upper == 'GET' || upper == 'HEAD') return;

    final scope = scopeForPath(path, _scope);
    if (scope == null || scope.isPublic || scope.isSession) return;

    final prefix = _resourceRoot(path);
    if (prefix == null) return;

    try {
      await _store.deleteWhere(scope: scope.key, pathPrefix: prefix);
    } catch (_) {
      // Best effort: a storage failure is not a reason to fail the mutation.
    }
    notifyListeners();
  }

  /* --------------------------------------------------------------- session */

  static const _sessionKey = 'session:me:v1';

  /// Save the raw `/me` envelope so an offline start can rebuild the session
  /// without guessing a workspace slug or permissions.
  Future<void> saveSession(Map<String, dynamic> raw) async {
    try {
      await _store.write(
        CacheRecord(
          key: _sessionKey,
          scope: CacheScope.session.key,
          path: '/me',
          payload: jsonEncode(raw),
          cachedAt: _clock(),
          // A session is valid until the token is cleared or the server
          // rejects it with 401.
          expiresAt: null,
        ),
      );
    } catch (_) {
      // Offline start is a convenience; a storage failure must not break
      // login or restoration.
    }
  }

  Future<Map<String, dynamic>?> readSession() async {
    try {
      final record = await _store.read(_sessionKey);
      if (record == null) return null;
      final decoded = jsonDecode(record.payload);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> clearSession() => _safeDelete(_sessionKey);

  /* ---------------------------------------------------------------- scopes */

  Future<void> clearScope(CacheScope scope) async {
    try {
      await _store.deleteWhere(scope: scope.key);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await _store.clear();
    } catch (_) {}
  }

  /* --------------------------------------------------------------- helpers */

  String _key({
    required String method,
    required String path,
    required CacheScope scope,
    Map<String, dynamic>? query,
  }) {
    final entries = <String>[];
    if (query != null) {
      for (final entry in query.entries) {
        final value = entry.value;
        if (value == null) continue;
        entries.add('${entry.key}=$value');
      }
    }
    entries.sort();
    final queryString = entries.isEmpty ? '' : '?${entries.join('&')}';
    return 'http:${scope.key}:$_language:'
        '${method.toUpperCase()}:$path$queryString';
  }

  String? _resourceRoot(String path) {
    final segments = path.split('/').where((part) => part.isNotEmpty).toList();
    if (segments.isEmpty) return null;
    if (segments.first == 'public' || segments.first == 'auth') return null;
    if (segments.length == 1) return '/${segments.first}';
    return '/${segments[0]}/${segments[1]}';
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _store.delete(key);
    } catch (_) {}
  }
}
