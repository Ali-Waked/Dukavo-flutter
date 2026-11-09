import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/auth_destination.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/auth_controller.dart';

/// Email verification for accounts created from an invitation.
///
/// The backend exposes Fortify's resend endpoint, but it is guarded by the web
/// session while the mobile client holds a bearer token. This screen therefore
/// reports the server's own answer instead of pretending the mail was sent.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _sending = false;
  bool _sent = false;

  Future<void> _resend() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _sent = false;
    });
    try {
      await ref.read(authControllerProvider.notifier).resendVerificationEmail();
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
      AppSnack.show(context, context.tr('publicVerifySent'));
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnack.show(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnack.show(context, context.tr('errorGeneric'), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    final verified = auth.session?.user.emailVerifiedAt != null;
    final email = auth.session?.user.email;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('publicVerifyTitle'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: verified
                            ? context.dukavo.success.withValues(
                                alpha: context.isDark ? 0.18 : 0.10,
                              )
                            : context.dukavo.surfaceHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        verified
                            ? Icons.verified_rounded
                            : Icons.mark_email_unread_outlined,
                        size: 34,
                        color: verified
                            ? context.dukavo.success
                            : context.dukavo.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    verified
                        ? context.tr('publicVerifyVerifiedTitle')
                        : context.tr('publicVerifyPendingTitle'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    verified
                        ? context.tr('publicVerifyVerifiedBody')
                        : context.tr('publicVerifyPendingBody'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.dukavo.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  if (email != null && email.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (!verified)
                    AppButton(
                      label: _sent
                          ? context.tr('publicVerifyResendAgain')
                          : context.tr('publicVerifyResend'),
                      icon: Icons.outgoing_mail,
                      expand: true,
                      loading: _sending,
                      onPressed: _resend,
                    ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: context.tr('publicOpenApp'),
                    icon: Icons.space_dashboard_outlined,
                    variant: AppButtonVariant.outlined,
                    expand: true,
                    onPressed: () {
                      final status = ref.read(authControllerProvider).status;
                      context.go(
                        status == AuthStatus.platform
                            ? RoutePaths.platformDashboard
                            : status == AuthStatus.authenticated
                                ? homePathFor(ref.read(permissionsProvider))
                                : RoutePaths.home,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.tr('publicVerifySessionNote'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: context.dukavo.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
