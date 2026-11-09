import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/auth_destination.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.redirect});

  /// Sanitised by the router. After a successful sign-in the user returns here
  /// when their role allows it, instead of always landing on the dashboard.
  final String? redirect;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final success = await ref.read(authControllerProvider.notifier).login(
          email: _email.text,
          password: _password.text,
        );
    if (!success || !mounted) return;

    final target = switch (ref.read(authControllerProvider).status) {
      AuthStatus.needsTenant => RoutePaths.setup,
      AuthStatus.platform => RoutePaths.platformDashboard,
      AuthStatus.authenticated => sanitizeRedirect(widget.redirect) ??
          homePathFor(ref.read(permissionsProvider)),
      AuthStatus.unknown || AuthStatus.unauthenticated => RoutePaths.home,
    };
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final colors = context.dukavo;
    final texts = context.texts;

    final error =
        auth.errorKey != null ? context.tr(auth.errorKey!) : auth.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => context.go(RoutePaths.home),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text(context.tr('publicBackToSite')),
                        ),
                        const Spacer(),
                        _QuietAction(
                          tooltip: context.tr('language'),
                          icon: Icons.translate_rounded,
                          onPressed: () => ref
                              .read(localeControllerProvider.notifier)
                              .toggle(),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _QuietAction(
                          tooltip: context.tr('theme'),
                          icon: Icons.contrast_rounded,
                          onPressed: () {
                            final controller =
                                ref.read(themeControllerProvider.notifier);
                            final current = ref.read(themeControllerProvider);
                            controller.setMode(
                              current == ThemeMode.dark
                                  ? ThemeMode.light
                                  : ThemeMode.dark,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppLogo(size: 46, showWordmark: true),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      context.tr('welcomeBack'),
                      style: texts.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.9,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.tr('loginSubtitle'),
                      style: texts.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (error != null && error.isNotEmpty) ...[
                      InfoBanner(
                        message: error,
                        tone: InfoBannerTone.danger,
                        icon: Icons.error_outline_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _email,
                            label: context.tr('email'),
                            hint: context.tr('emailHint'),
                            prefixIcon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              final required = Validators.required(value);
                              if (required != null) {
                                return context.tr('requiredField');
                              }
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value!.trim())) {
                                return context.tr('invalidEmail');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _password,
                            label: context.tr('password'),
                            hint: context.tr('passwordHint'),
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) => _submit(),
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
                          const SizedBox(height: AppSpacing.xxs),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: auth.isSubmitting
                                  ? null
                                  : () => context.push('/forgot-password'),
                              child: Text(context.tr('forgotPassword')),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppButton(
                            label: auth.isSubmitting
                                ? context.tr('signingIn')
                                : context.tr('signIn'),
                            loading: auth.isSubmitting,
                            expand: true,
                            icon: Icons.login_rounded,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        TextButton(
                          onPressed: auth.isSubmitting
                              ? null
                              : () => context.push(RoutePaths.register),
                          child: Text(context.tr('register')),
                        ),
                        TextButton(
                          onPressed: auth.isSubmitting
                              ? null
                              : () => context.push(RoutePaths.waitlist),
                          child: Text(context.tr('joinWaitlist')),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          'Dukavo',
                          style: texts.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          context.tr('appTagline'),
                          textAlign: TextAlign.center,
                          style: texts.bodySmall?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
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

class _QuietAction extends StatelessWidget {
  const _QuietAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.dukavo.surfaceLow,
        shape: BoxShape.circle,
        border: Border.all(color: context.dukavo.border),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
      ),
    );
  }
}
