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
  final _challengeFormKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _recoveryCode = TextEditingController();
  bool _useRecovery = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
    _recoveryCode.dispose();
    super.dispose();
  }

  void _goAfterSignIn() {
    final state = ref.read(authControllerProvider);
    final session = state.session;
    final redirect = sanitizeRedirect(widget.redirect);
    final target = switch (state.status) {
      AuthStatus.needsTenant => RoutePaths.setup,
      AuthStatus.platform => RoutePaths.platformDashboard,
      AuthStatus.authenticated => redirect ??
          (session?.user.needsOnboarding == true
              ? RoutePaths.welcome
              : homePathFor(ref.read(permissionsProvider))),
      AuthStatus.unknown || AuthStatus.unauthenticated => RoutePaths.home,
    };
    context.go(target);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final success = await ref.read(authControllerProvider.notifier).login(
          email: _email.text,
          password: _password.text,
        );
    if (!success || !mounted) return;
    _goAfterSignIn();
  }

  Future<void> _submitChallenge() async {
    if (!(_challengeFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final success =
        await ref.read(authControllerProvider.notifier).completeTwoFactor(
              code: _useRecovery ? null : _code.text,
              recoveryCode: _useRecovery ? _recoveryCode.text : null,
            );
    if (!success || !mounted) return;
    _goAfterSignIn();
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
                      context.tr(auth.awaitingTwoFactor
                          ? 'twoFactorTitle'
                          : 'welcomeBack'),
                      style: texts.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.9,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.tr(auth.awaitingTwoFactor
                          ? 'twoFactorSubtitle'
                          : 'loginSubtitle'),
                      style: texts.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (error != null && error.isNotEmpty) ...[
                      InfoBanner(
                        message: error,
                        tone: InfoBannerTone.danger,
                        icon: Icons.error_outline_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (auth.awaitingTwoFactor)
                      _ChallengeCard(
                        formKey: _challengeFormKey,
                        useRecovery: _useRecovery,
                        code: _code,
                        recoveryCode: _recoveryCode,
                        submitting: auth.isSubmitting,
                        onToggleMode: () {
                          setState(() => _useRecovery = !_useRecovery);
                        },
                        onSubmit: _submitChallenge,
                        onCancel: () {
                          ref
                              .read(authControllerProvider.notifier)
                              .cancelTwoFactor();
                        },
                      )
                    else
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
                    if (!auth.awaitingTwoFactor)
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

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.formKey,
    required this.useRecovery,
    required this.code,
    required this.recoveryCode,
    required this.submitting,
    required this.onToggleMode,
    required this.onSubmit,
    required this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final bool useRecovery;
  final TextEditingController code;
  final TextEditingController recoveryCode;
  final bool submitting;
  final VoidCallback onToggleMode;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!useRecovery) ...[
              Text(
                context.tr('twoFactorPrompt'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: code,
                label: context.tr('twoFactorCode'),
                hint: context.tr('twoFactorCodePlaceholder'),
                prefixIcon: Icons.shield_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                onSubmitted: (_) => onSubmit(),
                validator: (value) {
                  final digits = (value ?? '').trim();
                  if (digits.isEmpty) return context.tr('requiredField');
                  if (digits.length != 6) {
                    return context.tr('twoFactorCodeLength');
                  }
                  return null;
                },
              ),
            ] else ...[
              Text(
                context.tr('twoFactorRecoveryHint'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: recoveryCode,
                label: context.tr('twoFactorRecoveryCode'),
                prefixIcon: Icons.key_outlined,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? context.tr('requiredField')
                    : null,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: submitting
                  ? context.tr('verifying')
                  : context.tr('twoFactorVerify'),
              loading: submitting,
              expand: true,
              icon: Icons.verified_user_outlined,
              onPressed: submitting ? null : onSubmit,
            ),
            const SizedBox(height: AppSpacing.xxs),
            TextButton(
              onPressed: submitting ? null : onToggleMode,
              child: Text(
                context.tr(
                  useRecovery ? 'twoFactorUseCode' : 'twoFactorUseRecovery',
                ),
              ),
            ),
            TextButton(
              onPressed: submitting ? null : onCancel,
              child: Text(context.tr('cancel')),
            ),
          ],
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
