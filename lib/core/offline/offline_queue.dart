import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import 'cache_record.dart';
import 'cache_store.dart';

/// A mutation that is safe to replay after the connection returns.
class OfflineMutation {
  const OfflineMutation({
    required this.id,
    required this.method,
    required this.path,
    required this.createdAt,
    this.body,
    this.csrf = false,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final bool csrf;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  OfflineMutation copyWith({
    int? attempts,
    String? lastError,
  }) {
    return OfflineMutation(
      id: id,
      method: method,
      path: path,
      body: body,
      csrf: csrf,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'method': method,
      'path': path,
      'body': body,
      'csrf': csrf,
      'created_at': createdAt.toIso8601String(),
      'attempts': attempts,
      'last_error': lastError,
    };
  }

  static OfflineMutation? fromJson(Map<String, dynamic> json) {
    final id = '${json['id'] ?? ''}';
    final method = '${json['method'] ?? ''}';
    final path = '${json['path'] ?? ''}';
    if (id.isEmpty || method.isEmpty || path.isEmpty) return null;
    final rawBody = json['body'];
    return OfflineMutation(
      id: id,
      method: method,
      path: path,
      body: rawBody is Map ? Map<String, dynamic>.from(rawBody) : null,
      csrf: json['csrf'] == true,
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
      attempts: json['attempts'] is int ? json['attempts'] as int : 0,
      lastError: json['last_error'] as String?,
    );
  }
}

/// The allow-list of mutations that may be replayed offline.
///
/// This deliberately contains only idempotent read-state changes. Orders,
/// payments, inventory adjustments, WhatsApp sends, permissions and anything
/// that moves money or stock stay online-only and are rejected while offline.
class OfflineSafety {
  const OfflineSafety._();

  static final List<RegExp> _safePaths = <RegExp>[
    RegExp(r'^/notifications/read-all$'),
    RegExp(r'^/notifications/[^/]+/(read|unread)$'),
    RegExp(r'^/tenant/conversations/\d+/read$'),
  ];

  static bool isSafe(String method, String path) {
    final verb = method.toUpperCase();
    if (verb != 'POST' && verb != 'PATCH' && verb != 'PUT') return false;
    return _safePaths.any((pattern) => pattern.hasMatch(path));
  }
}

/// A durable, account-scoped queue for [OfflineSafety]-approved mutations.
class OfflineMutationQueue extends ChangeNotifier {
  OfflineMutationQueue(
    this._store, {
    DateTime Function()? clock,
    this.keyPrefix = 'offline-queue:',
  }) : _clock = clock ?? DateTime.now;

  final CacheStore _store;
  final DateTime Function() _clock;
  final String keyPrefix;

  final List<OfflineMutation> _pending = <OfflineMutation>[];
  final List<String> _failures = <String>[];
  String _scopeKey = 'public';
  bool _loaded = false;
  Future<void>? _loading;
  bool _flushing = false;

  String get scopeKey => _scopeKey;
  String get _prefix => '$keyPrefix$_scopeKey:';

  List<OfflineMutation> get pending => List.unmodifiable(_pending);
  int get length => _pending.length;
  bool get isEmpty => _pending.isEmpty;
  bool get isNotEmpty => _pending.isNotEmpty;
  List<String> get failures => List.unmodifiable(_failures);

  /// Queue entries belong to one account/tenant, so switching workspaces never
  /// replays a read-state change against the wrong identity.
  void setScope(String key) {
    final next = key.trim().isEmpty ? 'public' : key.trim();
    if (next == _scopeKey) return;
    _scopeKey = next;
    _loaded = false;
    _pending.clear();
    _failures.clear();
    notifyListeners();
    unawaited(load());
  }

  Future<void> load() {
    if (_loaded) return _loading ?? Future<void>.value();
    _loaded = true;
    return _loading = _readPending().whenComplete(() {
      _loading = null;
    });
  }

  Future<void> _readPending() async {
    try {
      final records = await _store.readAll(keyPrefix: _prefix);
      _pending
        ..clear()
        ..addAll(
          records.map((record) {
            try {
              final decoded = jsonDecode(record.payload);
              if (decoded is Map) {
                return OfflineMutation.fromJson(
                  Map<String, dynamic>.from(decoded),
                );
              }
            } catch (_) {}
            return null;
          }).whereType<OfflineMutation>(),
        );
      _pending.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      notifyListeners();
    } catch (_) {
      // An unreadable queue is empty rather than fatal.
    }
  }

  Future<OfflineMutation> enqueue({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool csrf = false,
  }) async {
    if (!OfflineSafety.isSafe(method, path)) {
      throw ArgumentError.value(
        path,
        'path',
        'This mutation is online-only and cannot be queued.',
      );
    }
    await load();

    final now = _clock();
    final mutation = OfflineMutation(
      id: '${now.microsecondsSinceEpoch}-${_pending.length}',
      method: method.toUpperCase(),
      path: path,
      body: body,
      csrf: csrf,
      createdAt: now,
    );
    _pending.add(mutation);
    await _persist(mutation);
    notifyListeners();
    return mutation;
  }

  /// Replay in order. Stops at the first transport failure so the rest of the
  /// queue keeps its original order; permanent 4xx failures are dropped and
  /// surfaced through [failures].
  Future<void> flush({
    required Future<void> Function(OfflineMutation mutation) execute,
    required bool Function() isOnline,
  }) async {
    if (_flushing) return;
    await load();
    if (_pending.isEmpty || !isOnline()) return;

    _flushing = true;
    try {
      final remaining = <OfflineMutation>[];
      for (var index = 0; index < _pending.length; index++) {
        final mutation = _pending[index];
        if (!isOnline()) {
          remaining.addAll(_pending.skip(index));
          break;
        }
        try {
          await execute(mutation);
          await _remove(mutation);
        } on ApiException catch (error) {
          if (error.isNetworkError) {
            remaining.addAll(_pending.skip(index));
            break;
          }
          if (error.statusCode >= 400 &&
              error.statusCode < 500 &&
              error.statusCode != 429) {
            // The server will never accept this mutation. Drop it so one bad
            // item cannot block the whole queue.
            _failures.add(error.message);
            await _remove(mutation);
            continue;
          }
          final retried = mutation.copyWith(
            attempts: mutation.attempts + 1,
            lastError: error.message,
          );
          remaining.add(retried);
          await _persist(retried);
        } catch (error) {
          final retried = mutation.copyWith(
            attempts: mutation.attempts + 1,
            lastError: '$error',
          );
          remaining.add(retried);
          await _persist(retried);
        }
      }

      _pending
        ..clear()
        ..addAll(remaining);
      notifyListeners();
    } finally {
      _flushing = false;
    }
  }

  Future<void> clear() async {
    try {
      await _store.deleteWhere(keyPrefix: _prefix);
    } catch (_) {}
    _pending.clear();
    _failures.clear();
    notifyListeners();
  }

  Future<void> _persist(OfflineMutation mutation) async {
    try {
      await _store.write(
        CacheRecord(
          key: '$_prefix${mutation.id}',
          scope: 'queue',
          path: mutation.path,
          payload: jsonEncode(mutation.toJson()),
          cachedAt: mutation.createdAt,
          expiresAt: null,
        ),
      );
    } catch (_) {}
  }

  Future<void> _remove(OfflineMutation mutation) async {
    try {
      await _store.delete('$_prefix${mutation.id}');
    } catch (_) {}
  }
}
