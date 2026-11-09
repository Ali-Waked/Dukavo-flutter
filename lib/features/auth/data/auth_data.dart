import 'dart:math';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/offline/cache_manager.dart';
import '../../../core/offline/cache_scope.dart';
import '../../../core/offline/offline_queue.dart';
import '../../../core/storage/app_preferences.dart';
import '../../../core/storage/secure_token_store.dart';
import '../domain/auth_domain.dart';

/* ------------------------------------------------------------------ models */

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.phone,
    this.locale,
    this.preferredCurrency = 'USD',
    this.preferredCurrencyName = '',
    this.preferredCurrencySymbol = '',
    this.preferredCurrencyDecimals = 2,
    this.avatarUrl,
    this.emailVerifiedAt,
    this.lastLoginAt,
    this.isPlatformUser = false,
    this.isSuperAdmin = false,
  });

  final int id;
  final String name;
  final String email;
  final String status;
  final String? phone;
  final String? locale;
  final String preferredCurrency;
  final String preferredCurrencyName;
  final String preferredCurrencySymbol;
  final int preferredCurrencyDecimals;
  final String? avatarUrl;
  final String? emailVerifiedAt;
  final String? lastLoginAt;
  final bool isPlatformUser;
  final bool isSuperAdmin;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: asInt(json['id']),
      name: asString(json['name']) ?? '',
      email: asString(json['email']) ?? '',
      status: asString(json['status']) ?? 'active',
      phone: asString(json['phone']),
      locale: asString(json['locale']),
      preferredCurrency: asString(json['preferred_currency']) ?? 'USD',
      preferredCurrencyName: asString(json['preferred_currency_name']) ?? '',
      preferredCurrencySymbol:
          asString(json['preferred_currency_symbol']) ?? '',
      preferredCurrencyDecimals:
          asInt(json['preferred_currency_decimals'], fallback: 2),
      avatarUrl: asString(json['avatar_url']),
      emailVerifiedAt: asString(json['email_verified_at']),
      lastLoginAt: asString(json['last_login_at']),
      isPlatformUser: asBool(json['is_platform_user']),
      isSuperAdmin: asBool(json['is_super_admin']),
    );
  }

  AuthUser toEntity() => AuthUser(
        id: id,
        name: name,
        email: email,
        status: status,
        phone: phone,
        locale: locale,
        preferredCurrency: preferredCurrency,
        preferredCurrencyName: preferredCurrencyName,
        preferredCurrencySymbol: preferredCurrencySymbol,
        preferredCurrencyDecimals: preferredCurrencyDecimals,
        avatarUrl: avatarUrl,
        emailVerifiedAt: emailVerifiedAt,
        lastLoginAt: lastLoginAt,
        isPlatformUser: isPlatformUser,
        isSuperAdmin: isSuperAdmin,
      );
}

class ActiveTenantModel {
  const ActiveTenantModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.currency,
    required this.timezone,
    this.locale,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String slug;
  final String status;
  final String currency;
  final String timezone;
  final String? locale;
  final bool isActive;

  factory ActiveTenantModel.fromJson(Map<String, dynamic> json) {
    return ActiveTenantModel(
      id: asInt(json['id']),
      name: asString(json['name']) ?? '',
      slug: asString(json['slug']) ?? '',
      status: asString(json['status']) ?? 'active',
      currency: asString(json['currency']) ?? 'USD',
      timezone: asString(json['timezone']) ?? 'UTC',
      locale: asString(json['locale']),
      isActive: json['is_active'] == null ? true : asBool(json['is_active']),
    );
  }

  ActiveTenant toEntity() => ActiveTenant(
        id: id,
        name: name,
        slug: slug,
        status: status,
        currency: currency,
        timezone: timezone,
        locale: locale,
        isActive: isActive,
      );
}

class TenantModel {
  const TenantModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.currency,
    required this.timezone,
    this.statusLabel,
    this.contactEmail,
    this.phone,
    this.locale,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String slug;
  final String status;
  final String currency;
  final String timezone;
  final String? statusLabel;
  final String? contactEmail;
  final String? phone;
  final String? locale;
  final bool isActive;

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: asInt(json['id']),
      name: asString(json['name']) ?? '',
      slug: asString(json['slug']) ?? '',
      status: asString(json['status']) ?? 'active',
      currency: asString(json['currency']) ?? 'USD',
      timezone: asString(json['timezone']) ?? 'UTC',
      statusLabel: asString(json['status_label']),
      contactEmail: asString(json['contact_email']),
      phone: asString(json['phone']),
      locale: asString(json['locale']),
      isActive: json['is_active'] == null ? true : asBool(json['is_active']),
    );
  }

  TenantMembership toEntity() => TenantMembership(
        id: id,
        name: name,
        slug: slug,
        status: status,
        currency: currency,
        timezone: timezone,
        statusLabel: statusLabel,
        contactEmail: contactEmail,
        phone: phone,
        locale: locale,
        isActive: isActive,
      );
}

class TenantRolesModel {
  const TenantRolesModel({
    required this.tenantId,
    required this.slug,
    required this.roles,
    required this.permissions,
  });

  final int tenantId;
  final String slug;
  final List<String> roles;
  final List<String> permissions;

  factory TenantRolesModel.fromJson(Map<String, dynamic> json) {
    return TenantRolesModel(
      tenantId: asInt(json['tenant_id']),
      slug: asString(json['slug']) ?? '',
      roles: asStringList(json['roles']),
      permissions: asStringList(json['permissions']),
    );
  }

  TenantRoles toEntity() => TenantRoles(
        tenantId: tenantId,
        slug: slug,
        roles: roles,
        permissions: permissions,
      );
}

class SessionModel {
  const SessionModel({
    required this.user,
    required this.tenants,
    required this.roles,
    required this.permissions,
    required this.permissionCatalogue,
    this.activeTenant,
  });

  final AuthUserModel user;
  final ActiveTenantModel? activeTenant;
  final List<TenantModel> tenants;
  final List<TenantRolesModel> roles;
  final List<String> permissions;
  final Map<String, List<String>> permissionCatalogue;

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final rawTenants = json['tenants'];
    final rawRoles = json['roles'];
    final rawCatalogue = json['permission_catalogue'];

    final catalogue = <String, List<String>>{};
    if (rawCatalogue is Map) {
      rawCatalogue.forEach((key, value) {
        if (value is List) {
          catalogue['$key'] = value.map((entry) => '$entry').toList();
        }
      });
    }

    return SessionModel(
      user: AuthUserModel.fromJson(
        rawUser is Map ? Map<String, dynamic>.from(rawUser) : const {},
      ),
      activeTenant: json['active_tenant'] is Map
          ? ActiveTenantModel.fromJson(
              Map<String, dynamic>.from(json['active_tenant'] as Map),
            )
          : null,
      tenants: rawTenants is List
          ? rawTenants
              .whereType<Map>()
              .map((entry) =>
                  TenantModel.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
      roles: rawRoles is List
          ? rawRoles
              .whereType<Map>()
              .map((entry) =>
                  TenantRolesModel.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const [],
      permissions: asStringList(json['permissions']),
      permissionCatalogue: catalogue,
    );
  }

  Session toEntity() => Session(
        user: user.toEntity(),
        activeTenant: activeTenant?.toEntity(),
        tenants: tenants.map((tenant) => tenant.toEntity()).toList(),
        roles: roles.map((entry) => entry.toEntity()).toList(),
        permissions: permissions,
        permissionCatalogue: permissionCatalogue,
      );
}

/* ------------------------------------------------------------- data source */

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiClient _api;

  Future<LoginResult> login(String email, String password) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.login,
      body: {'email': email, 'password': password},
      csrf: true,
      decode: _asMap,
    );

    final token = asString(data['token']);
    if (token == null || token.isEmpty) {
      throw ApiException(
        'The server did not return a sign-in token.',
        statusCode: 500,
      );
    }

    final rawUser = data['user'];
    final user = rawUser is Map ? Map<String, dynamic>.from(rawUser) : null;

    return LoginResult(
      token: token,
      tokenType: asString(data['token_type']) ?? 'Bearer',
      userId: user == null ? null : asInt(user['id']),
      userName: user == null ? null : asString(user['name']),
      userEmail: user == null ? null : asString(user['email']),
    );
  }

  Future<Session> me() async {
    final data = await meRaw();
    return SessionModel.fromJson(data).toEntity();
  }

  /// The raw `/me` envelope, saved so an offline start can restore the session.
  Future<Map<String, dynamic>> meRaw() {
    return _api.get<Map<String, dynamic>>(
      ApiPaths.me,
      decode: _asMap,
    );
  }

  Future<void> logout() => _api.postVoid(ApiPaths.logout, csrf: true);

  Future<ProvisionedTenant> provisionTenant({
    required String name,
    String? storeName,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.onboardingTenant,
      body: {
        'name': name,
        if (storeName != null && storeName.trim().isNotEmpty)
          'store_name': storeName.trim(),
      },
      headers: {'Idempotency-Key': _idempotencyKey()},
      csrf: true,
      decode: _asMap,
    );

    return ProvisionedTenant(
      id: asInt(data['id']),
      name: asString(data['name']) ?? name,
      slug: asString(data['slug']) ?? '',
    );
  }

  Future<void> forgotPassword(String email) {
    return _api.postVoid(
      ApiPaths.forgotPassword,
      body: {'email': email},
      csrf: true,
    );
  }

  Future<void> resendVerificationEmail() {
    return _api.postVoid(
      ApiPaths.emailVerificationNotification,
      csrf: true,
    );
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) {
    return _api.postVoid(
      ApiPaths.resetPassword,
      body: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      csrf: true,
    );
  }

  String _idempotencyKey() {
    final random = Random.secure().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}-$random';
  }
}

/* ------------------------------------------------------------- repository */

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SecureTokenStore tokenStore,
    required AppPreferences preferences,
    required ApiClient apiClient,
    CacheManager? cache,
    OfflineMutationQueue? queue,
  })  : _remote = remote,
        _tokenStore = tokenStore,
        _preferences = preferences,
        _apiClient = apiClient,
        _cache = cache,
        _queue = queue;

  final AuthRemoteDataSource _remote;
  final SecureTokenStore _tokenStore;
  final AppPreferences _preferences;
  final ApiClient _apiClient;
  final CacheManager? _cache;
  final OfflineMutationQueue? _queue;

  @override
  Future<Session?> restoreSession() async {
    if (_tokenStore.token == null || _tokenStore.token!.isEmpty) {
      _applyScope(null);
      return null;
    }

    final storedSlug = _preferences.tenantSlug;
    _apiClient.setTenantSlug(storedSlug);

    // Restore the last known identity before the network call so the scope is
    // correct even when the connection never answers.
    final cachedRaw = await _cache?.readSession();
    Session? cachedSession;
    if (cachedRaw != null) {
      try {
        cachedSession = SessionModel.fromJson(cachedRaw).toEntity();
        _applyScope(cachedSession);
        _apiClient.setTenantSlug(
          cachedSession.activeTenant?.slug ?? storedSlug,
        );
      } catch (_) {
        cachedSession = null;
      }
    }

    try {
      final snapshot = await _loadNetworkSession(storedSlug);
      await _remember(snapshot);
      return snapshot.session;
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await clearLocalSession();
        return null;
      }
      // A network failure is not a logout. The token is still the credential,
      // and the saved `/me` snapshot carries the same permissions the server
      // issued on the last successful start.
      if (error.isNetworkError && cachedSession != null) {
        return cachedSession;
      }
      rethrow;
    }
  }

  @override
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    final result = await _remote.login(email.trim(), password);
    await _tokenStore.save(result.token);

    try {
      final snapshot = await _loadNetworkSession(_preferences.tenantSlug);
      if (snapshot.session.activeTenant == null) {
        await _preferences.setTenantSlug(null);
        _apiClient.setTenantSlug(null);
      }
      await _remember(snapshot);
      return snapshot.session;
    } catch (_) {
      await _tokenStore.clear();
      await _cache?.clearSession();
      rethrow;
    }
  }

  @override
  Future<Session> switchTenant(String slug) async {
    final snapshot = await _activate(slug);
    await _remember(snapshot);
    return snapshot.session;
  }

  Future<_SessionSnapshot> _activate(String slug) async {
    await _preferences.setTenantSlug(slug);
    _apiClient.setTenantSlug(slug);
    final raw = await _remote.meRaw();
    return _SessionSnapshot(
      SessionModel.fromJson(raw).toEntity(),
      raw,
    );
  }

  Future<_SessionSnapshot> _loadNetworkSession(String? preferredSlug) async {
    var raw = await _remote.meRaw();
    var session = SessionModel.fromJson(raw).toEntity();
    if (session.activeTenant == null && session.tenants.isNotEmpty) {
      final slug = _chooseTenant(session, preferredSlug);
      if (slug != null) {
        final activated = await _activate(slug);
        raw = activated.raw;
        session = activated.session;
      }
    }
    return _SessionSnapshot(session, raw);
  }

  Future<void> _remember(_SessionSnapshot snapshot) async {
    await _cache?.saveSession(snapshot.raw);
    _applyScope(snapshot.session);
  }

  /// Point the cache and queue at the identity that just became active.
  void _applyScope(Session? session) {
    if (session == null) {
      _cache?.setScope(CacheScope.public);
      _queue?.setScope(CacheScope.public.key);
      return;
    }
    final scope = CacheScope.forSession(
      accountId: session.user.id,
      isPlatform: session.isPlatformUser,
      tenantSlug: session.activeTenant?.slug,
    );
    _cache?.setScope(scope);
    _queue?.setScope(scope.key);
  }

  @override
  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  }) async {
    final tenant =
        await _remote.provisionTenant(name: name, storeName: storeName);
    final slug = tenant.slug.isNotEmpty ? tenant.slug : null;
    final _SessionSnapshot snapshot;
    if (slug != null) {
      snapshot = await _activate(slug);
    } else {
      final raw = await _remote.meRaw();
      snapshot = _SessionSnapshot(
        SessionModel.fromJson(raw).toEntity(),
        raw,
      );
    }
    await _remember(snapshot);
    return snapshot.session;
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } finally {
      await clearLocalSession();
    }
  }

  @override
  Future<void> clearLocalSession() async {
    final scope = _cache?.scope;
    if (scope != null && !scope.isPublic) {
      await _cache?.clearScope(scope);
    }
    await _queue?.clear();
    await _cache?.clearSession();
    await _tokenStore.clear();
    await _preferences.setTenantSlug(null);
    _apiClient.setTenantSlug(null);
    _applyScope(null);
  }

  @override
  Future<void> forgotPassword(String email) {
    return _remote.forgotPassword(email.trim());
  }

  @override
  Future<void> resendVerificationEmail() {
    return _remote.resendVerificationEmail();
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) {
    return _remote.resetPassword(
      email: email.trim(),
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  String? _chooseTenant(Session session, String? preferredSlug) {
    if (session.tenants.isEmpty) return null;
    if (preferredSlug != null && preferredSlug.isNotEmpty) {
      final preferred = session.membershipForSlug(preferredSlug);
      if (preferred != null) return preferred.slug;
    }
    if (session.activeTenant != null) return session.activeTenant!.slug;
    return session.tenants.first.slug;
  }
}

/* ----------------------------------------------------------------- helpers */

class _SessionSnapshot {
  const _SessionSnapshot(this.session, this.raw);

  final Session session;
  final Map<String, dynamic> raw;
}

Map<String, dynamic> _asMap(Object? data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  return const <String, dynamic>{};
}

int asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

String? asString(Object? value) {
  if (value == null) return null;
  final text = '$value'.trim();
  return text.isEmpty ? null : text;
}

bool asBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    return value == '1' || value.toLowerCase() == 'true';
  }
  return fallback;
}

List<String> asStringList(Object? value) {
  if (value is List) {
    return value.map((entry) => '$entry').toList();
  }
  return const <String>[];
}
