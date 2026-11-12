import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/core/storage/app_preferences.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:dukavo_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/test_app.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Session?> restoreSession() async => null;

  @override
  Future<LoginOutcome> login(
      {required String email, required String password}) {
    throw UnimplementedError('Login is not exercised by this widget test.');
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
  Future<Session> switchTenant(String slug) {
    throw UnimplementedError();
  }

  @override
  Future<Session> enterPlatformMode() {
    throw UnimplementedError();
  }

  @override
  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  }) {
    throw UnimplementedError();
  }

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

class _TestAuthController extends AuthController {
  _TestAuthController() : super(_FakeAuthRepository(), autoBootstrap: false);

  void emit(AuthState next) => state = next;
}

void main() {
  late AppPreferences preferences;
  late _TestAuthController controller;

  setUpAll(() async {
    await preloadLocalizations();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = AppPreferences(await SharedPreferences.getInstance());
    controller = _TestAuthController();
  });

  Future<void> pumpLogin(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) {
    return pumpTestApp(
      tester,
      const LoginScreen(),
      locale: locale,
      overrides: [
        appPreferencesProvider.overrideWithValue(preferences),
        authControllerProvider.overrideWith((ref) => controller),
      ],
    );
  }

  testWidgets('renders the sign-in form', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('validates the empty form before calling the API',
      (tester) async {
    await pumpLogin(tester);

    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required.'), findsNWidgets(2));
  });

  testWidgets('rejects a short password', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'owner@dukavo.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'short',
    );

    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Use at least 8 characters.'), findsOneWidget);
  });

  testWidgets('shows the server error banner from the controller',
      (tester) async {
    controller.emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        errorKey: 'invalidCredentials',
      ),
    );

    await pumpLogin(tester);

    expect(
      find.text('The email or password is incorrect.'),
      findsOneWidget,
    );
  });

  testWidgets('renders in Arabic when the locale is Arabic', (tester) async {
    await pumpLogin(tester, locale: const Locale('ar'));

    expect(find.text('مرحبًا بعودتك'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}
