import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:flutter_test/flutter_test.dart';

class _RestoreOnlyRepository implements AuthRepository {
  _RestoreOnlyRepository(this.session);

  final Session? session;

  @override
  Future<Session?> restoreSession() async => session;

  @override
  Future<LoginOutcome> login(
      {required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<Session> completeTwoFactor({
    required String challengeToken,
    String? code,
    String? recoveryCode,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> clearLocalSession() async {}

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<Session> switchTenant(String slug) => throw UnimplementedError();

  @override
  Future<Session> enterPlatformMode() => throw UnimplementedError();

  @override
  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {}
}

Session _session({
  bool operator = false,
  bool withTenant = false,
}) {
  const tenant = ActiveTenant(
    id: 1,
    name: 'Dukavo Retail',
    slug: 'dukavo-retail',
    status: 'active',
    currency: 'USD',
    timezone: 'UTC',
  );
  return Session(
    user: AuthUser(
      id: 1,
      name: 'Sara Hassan',
      email: 'sara@dukavo.com',
      status: 'active',
      isPlatformUser: operator,
      isPlatformOperator: operator,
    ),
    activeTenant: withTenant ? tenant : null,
    tenants: const <TenantMembership>[],
    roles: const <TenantRoles>[],
    permissions: const <String>[],
    permissionCatalogue: const <String, List<String>>{},
  );
}

Future<AuthState> _restored(Session session) async {
  final controller = AuthController(
    _RestoreOnlyRepository(session),
    autoBootstrap: false,
  );
  addTearDown(controller.dispose);
  await controller.bootstrap();
  return controller.state;
}

void main() {
  test('restoring an operator without a workspace opens platform context',
      () async {
    final state = await _restored(_session(operator: true));

    expect(state.status, AuthStatus.platform);
    expect(state.isPlatformMode, isTrue);
    expect(state.isAuthenticated, isTrue);
  });

  test('restoring an operator inside a workspace opens merchant context',
      () async {
    final state = await _restored(_session(operator: true, withTenant: true));

    expect(state.status, AuthStatus.authenticated);
    expect(state.isPlatformMode, isFalse);
  });

  test('restoring a merchant without a workspace asks for onboarding',
      () async {
    final state = await _restored(_session());

    expect(state.status, AuthStatus.needsTenant);
    expect(state.isAuthenticated, isFalse);
  });
}
