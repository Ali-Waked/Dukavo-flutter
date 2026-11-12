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
    this.isPlatformOperator = false,
    this.isSuperAdmin = false,
    this.preferencesInitializedAt,
    this.twoFactorEnabled = false,
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

  /// Confirmed by the backend's platform route gate: the account holds one of
  /// the two operator roles (super admin or Dukavo admin).
  ///
  /// [isPlatformUser] is deliberately broader — any platform-scoped role makes
  /// it true — so it must never decide whether the console is reachable.
  final bool isPlatformOperator;
  final bool isSuperAdmin;
  final String? preferencesInitializedAt;
  final bool twoFactorEnabled;

  bool get needsOnboarding => preferencesInitializedAt == null;

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
  ///
  /// This mirrors the backend's `platform` middleware exactly: only the two
  /// system operator roles pass. A null-tenant role assignment alone is not
  /// enough, and the client never infers the capability from a name or email.
  bool get canUsePlatform => user.isPlatformOperator;

  /// Whether the account holds at least one merchant workspace.
  bool get hasMerchantAccess => tenants.isNotEmpty;

  /// Whether this account holds any platform-scoped role.
  ///
  /// Kept separate from [canUsePlatform]: it describes the account, while
  /// [canUsePlatform] describes what the platform API will actually allow.
  bool get isPlatformUser => user.isPlatformUser || user.isSuperAdmin;

  /// A platform operator currently outside any merchant workspace.
  ///
  /// This is the platform console context. A platform operator who deliberately
  /// opened a workspace is in merchant mode and keeps that workspace's tools.
  bool get isPlatformMode => !hasTenant && canUsePlatform;

  /// A platform operator with no merchant workspace at all.
  ///
  /// These accounts are fully authenticated: they must land in the platform
  /// console, not the "create a workspace" onboarding screen.
  bool get isPlatformOnly => canUsePlatform && !hasMerchantAccess;

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

/// The second step of a sign-in, before any session token exists.
class TwoFactorChallenge {
  const TwoFactorChallenge({
    required this.challengeToken,
    this.expiresAt,
    this.methods = const <String>['totp', 'recovery_code'],
  });

  final String challengeToken;
  final String? expiresAt;
  final List<String> methods;
}

/// Either a completed session or the challenge that must be answered first.
///
/// A password-only response never carries a token for a two-factor account, so
/// the app cannot accidentally treat the first step as signed in.
class LoginOutcome {
  const LoginOutcome.session(Session this.session) : challenge = null;
  const LoginOutcome.challenge(TwoFactorChallenge this.challenge) : session = null;

  final Session? session;
  final TwoFactorChallenge? challenge;

  bool get requiresTwoFactor => challenge != null;
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

  Future<LoginOutcome> login({required String email, required String password});

  /// Exchange a short-lived challenge for a real session after the second step.
  Future<Session> completeTwoFactor({
    required String challengeToken,
    String? code,
    String? recoveryCode,
  });

  Future<void> logout();

  Future<void> clearLocalSession();

  Future<Session> switchTenant(String slug);

  /// Leave the active merchant workspace and return to the platform console.
  ///
  /// Only a platform operator has a console to return to; the caller checks
  /// [Session.canUsePlatform] before offering the action.
  Future<Session> enterPlatformMode();

  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  });

  Future<void> forgotPassword(String email);

  /// Ask the server to resend the email-verification link.
  ///
  /// Fortify guards this endpoint with the session guard, so a bearer-token
  /// client can be refused. That refusal is surfaced to the caller instead of
  /// being hidden behind a fabricated success.
  Future<void> resendVerificationEmail();

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  });
}
