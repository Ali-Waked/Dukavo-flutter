import 'dart:math';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
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
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.me,
      decode: _asMap,
    );
    return SessionModel.fromJson(data).toEntity();
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
  })  : _remote = remote,
        _tokenStore = tokenStore,
        _preferences = preferences,
        _apiClient = apiClient;

  final AuthRemoteDataSource _remote;
  final SecureTokenStore _tokenStore;
  final AppPreferences _preferences;
  final ApiClient _apiClient;

  @override
  Future<Session?> restoreSession() async {
    if (_tokenStore.token == null || _tokenStore.token!.isEmpty) {
      return null;
    }

    final storedSlug = _preferences.tenantSlug;
    _apiClient.setTenantSlug(storedSlug);

    try {
      var session = await _remote.me();
      if (session.activeTenant == null && session.tenants.isNotEmpty) {
        final slug = _chooseTenant(session, storedSlug);
        if (slug != null) {
          session = await _activate(slug);
        }
      }
      return session;
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await clearLocalSession();
        return null;
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
      var session = await _remote.me();
      final slug = _chooseTenant(session, _preferences.tenantSlug);
      if (slug != null) {
        session = await _activate(slug);
      } else {
        await _preferences.setTenantSlug(null);
        _apiClient.setTenantSlug(null);
      }
      return session;
    } catch (_) {
      await _tokenStore.clear();
      rethrow;
    }
  }

  @override
  Future<Session> switchTenant(String slug) {
    return _activate(slug);
  }

  Future<Session> _activate(String slug) async {
    await _preferences.setTenantSlug(slug);
    _apiClient.setTenantSlug(slug);
    return _remote.me();
  }

  @override
  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  }) async {
    final tenant = await _remote.provisionTenant(name: name, storeName: storeName);
    final slug = tenant.slug.isNotEmpty ? tenant.slug : null;
    if (slug != null) {
      return _activate(slug);
    }
    return _remote.me();
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
    await _tokenStore.clear();
    await _preferences.setTenantSlug(null);
    _apiClient.setTenantSlug(null);
  }

  @override
  Future<void> forgotPassword(String email) {
    return _remote.forgotPassword(email.trim());
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
