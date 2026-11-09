import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../marketing/presentation/public_widgets.dart';

/// Registration is invite-only: the backend deliberately has no public
/// sign-up endpoint. This page explains the real path in instead of rendering
/// a form that could never succeed.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = <(String, String)>[
      (
        context.tr('publicRegisterStepOneTitle'),
        context.tr('publicRegisterStepOneBody'),
      ),
      (
        context.tr('publicRegisterStepTwoTitle'),
        context.tr('publicRegisterStepTwoBody'),
      ),
      (
        context.tr('publicRegisterStepThreeTitle'),
        context.tr('publicRegisterStepThreeBody'),
      ),
    ];

    return PublicDetailScaffold(
      title: context.tr('register'),
      child: PublicScrollView(
        children: [
          PublicHero(
            compact: true,
            badge: context.tr('publicRegisterBadge'),
            title: context.tr('publicRegisterTitle'),
            subtitle: context.tr('publicRegisterSubtitle'),
            primaryLabel: context.tr('joinWaitlist'),
            primaryIcon: Icons.hourglass_empty,
            onPrimary: () => context.push(RoutePaths.waitlist),
            secondaryLabel: context.tr('signIn'),
            onSecondary: () => context.push(RoutePaths.login),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var index = 0; index < steps.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        '${index + 1}',
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[index].$1,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            steps[index].$2,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  height: 1.55,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          PublicNoteCard(
            icon: Icons.lock_outline,
            title: context.tr('publicRegisterNoteTitle'),
            body: context.tr('publicRegisterNoteBody'),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: context.tr('joinWaitlist'),
            icon: Icons.hourglass_empty,
            expand: true,
            onPressed: () => context.push(RoutePaths.waitlist),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: context.tr('publicRegisterHaveAccount'),
            icon: Icons.login,
            variant: AppButtonVariant.outlined,
            expand: true,
            onPressed: () => context.push(RoutePaths.login),
          ),
          const PublicFooter(),
        ],
      ),
    );
  }
}
