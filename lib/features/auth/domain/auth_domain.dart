import '../../../core/auth/permissions.dart';

/// The signed-in person, as `GET /me` describes them.
class AuthUser {
  const AuthUser({
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

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }
}

/// The tenant the current request acts inside.
class ActiveTenant {
  const ActiveTenant({
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
}

/// A workspace the user may switch into.
class TenantMembership {
  const TenantMembership({
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

  ActiveTenant toActive() => ActiveTenant(
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

/// Roles and permissions held in one tenant.
class TenantRoles {
  const TenantRoles({
    required this.tenantId,
    required this.slug,
    required this.roles,
    required this.permissions,
  });

  final int tenantId;
  final String slug;
  final List<String> roles;
  final List<String> permissions;
}

/// Everything the app needs to boot, in one object.
class Session {
  const Session({
    required this.user,
    required this.tenants,
    required this.roles,
    required this.permissions,
    required this.permissionCatalogue,
    this.activeTenant,
  });

  final AuthUser user;
  final ActiveTenant? activeTenant;
  final List<TenantMembership> tenants;
  final List<TenantRoles> roles;
  final List<String> permissions;
  final Map<String, List<String>> permissionCatalogue;

  Permissions get permissionSet => Permissions(permissions.toSet());

  bool get hasTenant => activeTenant != null;

  /// Whether this account may enter the Dukavo platform console.
  bool get isPlatformUser => user.isPlatformUser || user.isSuperAdmin;

  /// A platform operator signed in without a merchant workspace.
  ///
  /// These accounts are fully authenticated: they must land in the platform
  /// console, not the "create a workspace" onboarding screen.
  bool get isPlatformOnly => !hasTenant && isPlatformUser;

  String get currency =>
      activeTenant?.currency ??
      (tenants.isEmpty ? 'USD' : tenants.first.currency);

  String get timezone =>
      activeTenant?.timezone ??
      (tenants.isEmpty ? 'UTC' : tenants.first.timezone);

  TenantRoles? rolesForSlug(String slug) {
    for (final entry in roles) {
      if (entry.slug == slug) return entry;
    }
    return null;
  }

  TenantMembership? membershipForSlug(String slug) {
    for (final tenant in tenants) {
      if (tenant.slug == slug) return tenant;
    }
    return null;
  }
}

/// The credential exchange response.
class LoginResult {
  const LoginResult({
    required this.token,
    required this.tokenType,
    this.userId,
    this.userName,
    this.userEmail,
  });

  final String token;
  final String tokenType;
  final int? userId;
  final String? userName;
  final String? userEmail;
}

/// A workspace created during onboarding.
class ProvisionedTenant {
  const ProvisionedTenant({
    required this.id,
    required this.name,
    required this.slug,
  });

  final int id;
  final String name;
  final String slug;
}

/// The domain contract. Implementations live in the data layer; the controller
/// and UI only ever see this interface.
abstract class AuthRepository {
  Future<Session?> restoreSession();

  Future<Session> login({required String email, required String password});

  Future<void> logout();

  Future<void> clearLocalSession();

  Future<Session> switchTenant(String slug);

  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  });

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  });
}
