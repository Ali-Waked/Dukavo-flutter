import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/auth_destination.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final error =
        auth.errorKey != null ? context.tr(auth.errorKey!) : auth.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => context.go(RoutePaths.home),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text(context.tr('publicBackToSite')),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: AppLogo(size: 52, showWordmark: true),
                        ),
                        Row(
                          children: [
                            IconButton(
                              tooltip: context.tr('language'),
                              onPressed: () => ref
                                  .read(localeControllerProvider.notifier)
                                  .toggle(),
                              icon: const Icon(Icons.translate),
                            ),
                            IconButton(
                              tooltip: context.tr('theme'),
                              onPressed: () {
                                final controller =
                                    ref.read(themeControllerProvider.notifier);
                                final current =
                                    ref.read(themeControllerProvider);
                                controller.setMode(
                                  current == ThemeMode.dark
                                      ? ThemeMode.light
                                      : ThemeMode.dark,
                                );
                              },
                              icon: const Icon(Icons.contrast),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text(
                      context.tr('welcomeBack'),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('loginSubtitle'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (error != null && error.isNotEmpty) ...[
                      _ErrorBanner(message: error),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      controller: _email,
                      label: context.tr('email'),
                      hint: context.tr('emailHint'),
                      prefixIcon: Icons.alternate_email,
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
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _password,
                      label: context.tr('password'),
                      hint: context.tr('passwordHint'),
                      prefixIcon: Icons.lock_outline,
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
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: auth.isSubmitting
                            ? null
                            : () => context.push('/forgot-password'),
                        child: Text(context.tr('forgotPassword')),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: auth.isSubmitting
                          ? context.tr('signingIn')
                          : context.tr('signIn'),
                      loading: auth.isSubmitting,
                      expand: true,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          'Dukavo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          context.tr('appTagline'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
