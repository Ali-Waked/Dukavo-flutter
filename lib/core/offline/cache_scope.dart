/// The identity a cached response belongs to.
///
/// Cached data must never leak between accounts, workspaces or platform
/// consoles. Every entry is stored under one of these scopes, and the scope is
/// part of the storage key rather than a filter applied afterwards.
enum CacheAudience {
  /// Marketing pages and public storefronts. Shared by every visitor because
  /// the payload is already public.
  public,

  /// The signed-in person: `/me`, profile, notifications and their devices.
  account,

  /// A merchant workspace. Account and tenant are both required so two
  /// memberships of the same account never share rows.
  merchant,

  /// The Dukavo operator console.
  platform,

  /// The single saved copy of the current `/me` response. It has no tenant so
  /// it can be read before the workspace is known.
  session,
}

class CacheScope {
  const CacheScope({
    required this.audience,
    this.accountId,
    this.tenantSlug,
  });

  final CacheAudience audience;
  final int? accountId;
  final String? tenantSlug;

  static const public = CacheScope(audience: CacheAudience.public);
  static const session = CacheScope(audience: CacheAudience.session);

  factory CacheScope.account(int accountId) {
    return CacheScope(audience: CacheAudience.account, accountId: accountId);
  }

  factory CacheScope.platform(int accountId) {
    return CacheScope(audience: CacheAudience.platform, accountId: accountId);
  }

  factory CacheScope.merchant({
    required int accountId,
    required String tenantSlug,
  }) {
    return CacheScope(
      audience: CacheAudience.merchant,
      accountId: accountId,
      tenantSlug: tenantSlug,
    );
  }

  /// The scope an authenticated session should read and write.
  ///
  /// A platform operator with an active merchant workspace gets the merchant
  /// scope; the operator console's own calls are re-scoped per path by
  /// [scopeForPath].
  factory CacheScope.forSession({
    required int accountId,
    required bool isPlatform,
    String? tenantSlug,
  }) {
    final slug = tenantSlug?.trim() ?? '';
    if (slug.isNotEmpty) {
      return CacheScope.merchant(accountId: accountId, tenantSlug: slug);
    }
    if (isPlatform) return CacheScope.platform(accountId);
    return CacheScope.account(accountId);
  }

  bool get isPublic => audience == CacheAudience.public;
  bool get isSession => audience == CacheAudience.session;

  /// A stable, opaque storage key. It contains no personally identifying text
  /// beyond the numeric account id and the tenant slug already sent as a
  /// header.
  String get key {
    switch (audience) {
      case CacheAudience.public:
        return 'public';
      case CacheAudience.session:
        return 'session';
      case CacheAudience.account:
        return 'account:${accountId ?? 0}';
      case CacheAudience.platform:
        return 'platform:${accountId ?? 0}';
      case CacheAudience.merchant:
        return 'merchant:${accountId ?? 0}:${tenantSlug ?? ''}';
    }
  }

  /// Public payloads are shared, but the session cache is not account data.
  bool get isAccountScoped =>
      audience == CacheAudience.account ||
      audience == CacheAudience.merchant ||
      audience == CacheAudience.platform;

  @override
  bool operator ==(Object other) =>
      other is CacheScope &&
      other.audience == audience &&
      other.accountId == accountId &&
      other.tenantSlug == tenantSlug;

  @override
  int get hashCode => Object.hash(audience, accountId, tenantSlug);

  @override
  String toString() => 'CacheScope($key)';
}

/// Resolve the audience of a request path within the current identity.
///
/// `/public/**` is always shared. Everything else inherits the signed-in
/// scope, with platform and merchant routes narrowing to their own audience so
/// a platform operator who also belongs to a workspace cannot read one
/// console's list from the other's cache.
CacheScope? scopeForPath(String path, CacheScope current) {
  if (path.startsWith('/public/') || path == '/currencies') {
    return CacheScope.public;
  }
  if (path.startsWith('/auth/') ||
      path.startsWith('/onboarding/') ||
      path.startsWith('/sanctum/')) {
    return null;
  }

  // The session snapshot is saved explicitly by the auth repository so it can
  // be read before a tenant is chosen.
  if (path == '/me') return null;

  if (current.isPublic || current.isSession) return current;

  if (path.startsWith('/platform/')) {
    return CacheScope.platform(current.accountId ?? 0);
  }

  if (path.startsWith('/tenant/')) {
    final slug = current.tenantSlug;
    if (slug == null || slug.isEmpty) {
      return CacheScope.account(current.accountId ?? 0);
    }
    return CacheScope.merchant(
      accountId: current.accountId ?? 0,
      tenantSlug: slug,
    );
  }

  return CacheScope.account(current.accountId ?? 0);
}
