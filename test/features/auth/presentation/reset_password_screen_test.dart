import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/auth/domain/auth_domain.dart';
import 'package:dukavo_mobile/features/auth/presentation/reset_password_screen.dart';
import 'package:dukavo_mobile/core/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

class _FakeAuthRepository implements AuthRepository {
  String? email;
  String? token;
  String? password;
  String? passwordConfirmation;

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    this.email = email;
    this.token = token;
    this.password = password;
    this.passwordConfirmation = passwordConfirmation;
  }

  @override
  Future<Session?> restoreSession() => throw UnimplementedError();

  @override
  Future<Session> login({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<void> clearLocalSession() => throw UnimplementedError();

  @override
  Future<Session> switchTenant(String slug) => throw UnimplementedError();

  @override
  Future<Session> provisionTenant({
    required String name,
    String? storeName,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> forgotPassword(String email) => throw UnimplementedError();
}

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('explains an incomplete reset link', (tester) async {
    await pumpTestApp(tester, const ResetPasswordScreen());

    expect(
      find.text('This reset link is incomplete. Request a new one.'),
      findsOneWidget,
    );
  });

  testWidgets('submits the token, email and matching passwords',
      (tester) async {
    final repository = _FakeAuthRepository();

    await pumpTestApp(
      tester,
      const ResetPasswordScreen(token: 'tok-123', email: 'sara@example.com'),
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));

    await tester.enterText(fields.at(2), 'new-secret-1');
    await tester.enterText(fields.at(3), 'new-secret-1');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(repository.email, 'sara@example.com');
    expect(repository.token, 'tok-123');
    expect(repository.password, 'new-secret-1');
    expect(repository.passwordConfirmation, 'new-secret-1');
    expect(find.text('Password updated'), findsOneWidget);
  });

  testWidgets('rejects mismatched passwords before calling the API',
      (tester) async {
    final repository = _FakeAuthRepository();

    await pumpTestApp(
      tester,
      const ResetPasswordScreen(token: 'tok-123', email: 'sara@example.com'),
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), 'new-secret-1');
    await tester.enterText(fields.at(3), 'different-secret');
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(find.text('The passwords do not match.'), findsOneWidget);
    expect(repository.password, isNull);
  });
}
