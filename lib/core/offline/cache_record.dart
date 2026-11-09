/// One persisted HTTP response.
///
/// [payload] is the raw JSON envelope the API returned, not a decoded model, so
/// the same cache can feed every repository without knowing its types.
class CacheRecord {
  const CacheRecord({
    required this.key,
    required this.scope,
    required this.path,
    required this.payload,
    required this.cachedAt,
    this.expiresAt,
  });

  final String key;
  final String scope;
  final String path;
  final String payload;
  final DateTime cachedAt;

  /// `null` means the entry never expires on its own. The saved session uses
  /// this so an offline start can still restore it; logout and a 401 clear it.
  final DateTime? expiresAt;

  bool isExpired(DateTime now) {
    final expiry = expiresAt;
    return expiry != null && !now.isBefore(expiry);
  }
}

/// A cache hit plus the metadata screens need to explain it.
class CachedResponse {
  const CachedResponse({
    required this.body,
    required this.cachedAt,
    required this.isStale,
  });

  final Map<String, dynamic> body;
  final DateTime cachedAt;
  final bool isStale;
}
