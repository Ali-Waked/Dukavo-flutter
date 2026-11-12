import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/auth_controller.dart';

/// Completes a password reset with the token from the reset email.
///
/// The web reset page and this screen call the same Fortify endpoint. The token
/// and email arrive as query parameters so a deep link can open the form
/// directly; both remain editable in case the link is pasted by hand.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.token = '', this.email = ''});

  final String token;
  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.email);
  late final _token = TextEditingController(text: widget.token);
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _submitting = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: _email.text.trim(),
            token: _token.text.trim(),
            password: _password.text,
            passwordConfirmation: _confirmation.text,
          );
      if (!mounted) return;
      setState(() {
        _done = true;
        _submitting = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.tr('errorGeneric');
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_done) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('resetPassword'))),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: context.dukavo.success
                              .withValues(alpha: context.isDark ? 0.18 : 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 36,
                          color: context.dukavo.success,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        context.tr('passwordResetSuccess'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.tr('passwordResetSuccessMessage'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.dukavo.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: context.tr('backToLogin'),
                        icon: Icons.login,
                        expand: true,
                        onPressed: () => context.go(RoutePaths.login),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final incomplete =
        widget.token.trim().isEmpty || widget.email.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('resetPassword'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.tr('resetPassword'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr('resetPasswordSubtitle'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.dukavo.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          if (incomplete) ...[
                            const SizedBox(height: AppSpacing.md),
                            StatusBanner(
                              message: context.tr('resetTokenMissing'),
                              tone: StatusBannerTone.warning,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _email,
                            label: context.tr('email'),
                            hint: context.tr('emailHint'),
                            prefixIcon: Icons.alternate_email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              if (Validators.email(value) != null) {
                                return context.tr('invalidEmail');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _token,
                            label: context.tr('resetToken'),
                            prefixIcon: Icons.key_outlined,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? context.tr('requiredField')
                                    : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _password,
                            label: context.tr('newPassword'),
                            hint: context.tr('passwordHint'),
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.tr('requiredField');
                              }
                              if (value.length < 8) {
                                return context.tr('passwordTooShort');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _confirmation,
                            label: context.tr('confirmPassword'),
                            prefixIcon: Icons.lock_reset,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            validator: (value) => value != _password.text
                                ? context.tr('passwordMismatch')
                                : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            StatusBanner(
                              message: _error!,
                              tone: StatusBannerTone.error,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            label: context.tr('resetPassword'),
                            icon: Icons.check,
                            expand: true,
                            loading: _submitting,
                            onPressed: _submitting ? null : _submit,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () => context.go(RoutePaths.forgotPassword),
                            child: Text(context.tr('forgotPassword')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
