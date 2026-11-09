/// How long a response may be served and how long it may survive a network
/// failure.
class CachePolicy {
  const CachePolicy({
    required this.ttl,
    required this.maxStale,
    this.cacheable = true,
  });

  /// Freshness window for online reads. A response older than this is
  /// re-fetched when the network is available.
  final Duration ttl;

  /// How long an expired entry may still be shown while offline. After this the
  /// cache reports a real "no saved data" error instead of ancient data.
  final Duration maxStale;

  final bool cacheable;

  static const never = CachePolicy(
    ttl: Duration.zero,
    maxStale: Duration.zero,
    cacheable: false,
  );

  static const publicContent = CachePolicy(
    ttl: Duration(minutes: 30),
    maxStale: Duration(days: 7),
  );

  static const catalogue = CachePolicy(
    ttl: Duration(minutes: 5),
    maxStale: Duration(days: 3),
  );

  static const dashboard = CachePolicy(
    ttl: Duration(minutes: 5),
    maxStale: Duration(days: 1),
  );

  static const conversation = CachePolicy(
    ttl: Duration(seconds: 45),
    maxStale: Duration(hours: 6),
  );

  static const notification = CachePolicy(
    ttl: Duration(minutes: 1),
    maxStale: Duration(days: 1),
  );

  static const platformData = CachePolicy(
    ttl: Duration(minutes: 5),
    maxStale: Duration(days: 1),
  );

  static const profile = CachePolicy(
    ttl: Duration(minutes: 10),
    maxStale: Duration(days: 2),
  );

  static const reference = CachePolicy(
    ttl: Duration(hours: 12),
    maxStale: Duration(days: 7),
  );

  /// Resolve the policy for a read. Returning [never] keeps volatile or
  /// sensitive endpoints out of storage entirely.
  static CachePolicy forPath(String method, String path) {
    if (method.toUpperCase() != 'GET') return never;

    // Never persist credentials, availability probes, exports or AI output.
    if (path.startsWith('/auth/') ||
        path.startsWith('/onboarding/') ||
        path.startsWith('/sanctum/') ||
        path == '/me' ||
        path.contains('availability') ||
        path.contains('/ai/') ||
        path.contains('/export') ||
        path.contains('/sessions') ||
        path.contains('/devices') ||
        path.contains('/preview') ||
        path.contains('/slug-availability')) {
      return never;
    }

    if (path.startsWith('/public/') || path == '/currencies') {
      return publicContent;
    }
    if (path.startsWith('/notifications')) return notification;
    if (path.contains('/conversations')) return conversation;
    if (path.startsWith('/profile')) return profile;
    if (path.startsWith('/platform/')) return platformData;
    if (path.contains('/dashboard') ||
        path.contains('/analytics') ||
        path.contains('/profit') ||
        path.contains('/intelligence') ||
        path.contains('/recovery-opportunities')) {
      return dashboard;
    }
    if (path.startsWith('/tenant/')) return catalogue;
    return profile;
  }
}
