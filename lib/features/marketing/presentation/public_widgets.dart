import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/auth_destination.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../domain/marketing_models.dart';

/// The message a public screen shows when a read fails.
String publicErrorMessage(BuildContext context, Object error) {
  if (error is ApiException && error.message.trim().isNotEmpty) {
    return error.message;
  }
  return context.tr('errorGeneric');
}

/// Icon used for each capability the public feature catalogue exposes.
IconData publicFeatureIcon(String slug) {
  switch (slug) {
    case 'products':
      return Icons.inventory_2_outlined;
    case 'inventory':
      return Icons.warehouse_outlined;
    case 'orders':
      return Icons.receipt_long_outlined;
    case 'customers':
      return Icons.people_outline;
    case 'conversations':
      return Icons.chat_bubble_outline;
    case 'team':
      return Icons.groups_outlined;
    case 'whatsapp':
      return Icons.forum_outlined;
    case 'bundles':
      return Icons.layers_outlined;
    case 'recovery':
      return Icons.replay_outlined;
    case 'analytics':
      return Icons.insights_outlined;
    case 'automation':
      return Icons.bolt_outlined;
    case 'ai-copilot':
      return Icons.auto_awesome_outlined;
    default:
      return Icons.check_circle_outline;
  }
}

/// Sends the visitor to the right account destination for their current state.
void openPublicAccount(BuildContext context, WidgetRef ref) {
  final auth = ref.read(authControllerProvider);
  switch (auth.status) {
    case AuthStatus.unknown:
    case AuthStatus.unauthenticated:
      context.push(RoutePaths.login);
      return;
    case AuthStatus.needsTenant:
      context.go(RoutePaths.setup);
      return;
    case AuthStatus.platform:
      context.go(RoutePaths.platformDashboard);
      return;
    case AuthStatus.authenticated:
      context.go(homePathFor(ref.read(permissionsProvider)));
      return;
  }
}

/// Language, theme and account actions shared by every public app bar.
class PublicChromeActions extends ConsumerWidget {
  const PublicChromeActions({super.key, this.showAccount = true});

  final bool showAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final signedIn = auth.isAuthenticated;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: context.tr('language'),
          onPressed: () =>
              ref.read(localeControllerProvider.notifier).toggle(),
          icon: const Icon(Icons.translate),
        ),
        IconButton(
          tooltip: context.tr('theme'),
          onPressed: () {
            final controller = ref.read(themeControllerProvider.notifier);
            final mode = ref.read(themeControllerProvider);
            controller.setMode(
              mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
            );
          },
          icon: const Icon(Icons.contrast),
        ),
        if (showAccount)
          IconButton(
            tooltip: signedIn
                ? context.tr('publicOpenApp')
                : context.tr('signIn'),
            onPressed: () => openPublicAccount(context, ref),
            icon: Icon(
              signedIn
                  ? Icons.space_dashboard_outlined
                  : Icons.person_outline,
            ),
          ),
      ],
    );
  }
}

/// Full-screen chrome for public pages that are not one of the four tabs.
class PublicDetailScaffold extends StatelessWidget {
  const PublicDetailScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.embedded = false,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  /// Tabs already live inside [PublicShell]'s scaffold, so they render only the
  /// body while detail routes get their own bar and back button.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (embedded) return SafeArea(top: false, child: child);
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: title,
          child: const AppLogo(size: 26, showWordmark: true),
        ),
        actions: actions ?? const [PublicChromeActions()],
      ),
      body: SafeArea(top: false, child: child),
    );
  }
}

/// A centred, max-width scroll area for public prose and forms.
class PublicScrollView extends StatelessWidget {
  const PublicScrollView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 32),
    this.onRefresh,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ],
    );

    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}

/// The branded hero shared by the public landing pages.
class PublicHero extends StatelessWidget {
  const PublicHero({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    this.accent,
    this.primaryLabel,
    this.primaryIcon,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.ticks = const [],
    this.compact = false,
  });

  final String badge;
  final String title;
  final String subtitle;
  final String? accent;
  final String? primaryLabel;
  final IconData? primaryIcon;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final List<String> ticks;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final titleStyle = (compact
            ? theme.textTheme.headlineMedium
            : wide
                ? theme.textTheme.displaySmall
                : theme.textTheme.headlineMedium)
        ?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      height: 1.08,
      letterSpacing: wide ? -1.2 : -0.6,
    );

    final accentIndex =
        accent == null ? -1 : title.indexOf(accent!);

    final titleSpan = accentIndex < 0
        ? TextSpan(text: title)
        : TextSpan(
            children: [
              TextSpan(text: title.substring(0, accentIndex)),
              TextSpan(
                text: accent,
                style: const TextStyle(color: AppColors.accent),
              ),
              TextSpan(text: title.substring(accentIndex + accent!.length)),
            ],
          );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 22 : 28),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -70,
            end: -50,
            child: _Orb(
              size: 200,
              color: AppColors.accent.withValues(alpha: 0.18),
            ),
          ),
          PositionedDirectional(
            bottom: -90,
            start: -60,
            child: _Orb(
              size: 230,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 20 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          badge,
                          style:
                              theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 16 : 20),
                Text.rich(titleSpan, style: titleStyle),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.55,
                  ),
                ),
                if (primaryLabel != null || secondaryLabel != null) ...[
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (primaryLabel != null)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryDark,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 13,
                            ),
                          ),
                          onPressed: onPrimary,
                          icon: Icon(
                            primaryIcon ?? Icons.arrow_forward,
                            size: 18,
                          ),
                          label: Text(primaryLabel!),
                        ),
                      if (secondaryLabel != null)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 13,
                            ),
                          ),
                          onPressed: onSecondary,
                          child: Text(secondaryLabel!),
                        ),
                    ],
                  ),
                ],
                if (ticks.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    children: [
                      for (final tick in ticks)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tick,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// A section title with an optional "view all" style action.
class PublicSectionHeader extends StatelessWidget {
  const PublicSectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// A quiet card that explains a product or policy constraint.
class PublicNoteCard extends StatelessWidget {
  const PublicNoteCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.tint(scheme.primary),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: scheme.primary, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PublicErrorCard extends StatelessWidget {
  const PublicErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, color: scheme.onErrorContainer),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(context.tr('retry')),
          ),
        ],
      ),
    );
  }
}

class PublicLoadingCard extends StatelessWidget {
  const PublicLoadingCard({super.key, this.height = 180});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

/// The final call to action before a page's footer.
class PublicCtaBand extends StatelessWidget {
  const PublicCtaBand({
    super.key,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -50,
            end: -30,
            child: _Orb(
              size: 140,
              color: AppColors.accent.withValues(alpha: 0.22),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                ),
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Public footer with product, resource, company and legal links.
class PublicFooter extends ConsumerWidget {
  const PublicFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mode = ref.watch(themeControllerProvider);
    final locale = ref.watch(effectiveLocaleProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 18),
          const AppLogo(size: 34, showWordmark: true),
          const SizedBox(height: 10),
          Text(
            context.tr('publicFooterTagline'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 520;
              final groups = <Widget>[
                _FooterGroup(
                  title: context.tr('publicFooterProduct'),
                  links: [
                    _FooterLink(
                      context.tr('publicNavFeatures'),
                      RoutePaths.publicFeatures,
                    ),
                    _FooterLink(
                      context.tr('publicNavPricing'),
                      RoutePaths.publicPricing,
                    ),
                    _FooterLink(
                      context.tr('publicNavHowItWorks'),
                      RoutePaths.publicHowItWorks,
                    ),
                  ],
                ),
                _FooterGroup(
                  title: context.tr('publicFooterResources'),
                  links: [
                    _FooterLink(
                      context.tr('publicNavFaq'),
                      RoutePaths.publicFaq,
                    ),
                    _FooterLink(
                      context.tr('publicNavBlog'),
                      RoutePaths.publicBlog,
                    ),
                    _FooterLink(
                      context.tr('publicNavContact'),
                      RoutePaths.publicContact,
                    ),
                  ],
                ),
                _FooterGroup(
                  title: context.tr('publicFooterCompany'),
                  links: [
                    _FooterLink(
                      context.tr('publicNavAbout'),
                      RoutePaths.publicAbout,
                    ),
                    _FooterLink(
                      context.tr('register'),
                      RoutePaths.register,
                    ),
                    _FooterLink(
                      context.tr('joinWaitlist'),
                      RoutePaths.waitlist,
                    ),
                  ],
                ),
                _FooterGroup(
                  title: context.tr('publicFooterLegal'),
                  links: [
                    _FooterLink(
                      context.tr('termsOfService'),
                      RoutePaths.publicPage('terms'),
                    ),
                    _FooterLink(
                      context.tr('privacyPolicy'),
                      RoutePaths.publicPage('privacy'),
                    ),
                  ],
                ),
              ];

              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final group in groups) ...[
                      group,
                      const SizedBox(height: 18),
                    ],
                  ],
                );
              }
              return Wrap(
                spacing: 48,
                runSpacing: 24,
                children: groups,
              );
            },
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () =>
                    ref.read(localeControllerProvider.notifier).toggle(),
                icon: const Icon(Icons.translate, size: 17),
                label: Text(
                  locale.languageCode == 'ar'
                      ? context.tr('english')
                      : context.tr('arabic'),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  final controller =
                      ref.read(themeControllerProvider.notifier);
                  controller.setMode(
                    mode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  );
                },
                icon: const Icon(Icons.contrast, size: 17),
                label: Text(
                  mode == ThemeMode.dark
                      ? context.tr('light')
                      : context.tr('dark'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'publicCopyright',
              args: {'year': DateTime.now().year},
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FooterGroup extends StatelessWidget {
  const _FooterGroup({required this.title, required this.links});

  final String title;
  final List<_FooterLink> links;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          for (final link in links)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => context.push(link.path),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  link.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FooterLink {
  const _FooterLink(this.label, this.path);

  final String label;
  final String path;
}

/// The card used for an API capability on Features and Home.
class PublicFeatureCard extends StatelessWidget {
  const PublicFeatureCard({
    super.key,
    required this.feature,
    this.showStatus = true,
  });

  final MarketingFeature feature;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final available = feature.isAvailable;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: available
                      ? AppColors.tint(scheme.primary)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  publicFeatureIcon(feature.slug),
                  color: available ? scheme.primary : scheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const Spacer(),
              if (showStatus)
                StatusChip(
                  status: available ? 'active' : 'coming_soon',
                  label: available
                      ? context.tr('publicFeaturesAvailable')
                      : context.tr('comingSoon'),
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feature.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feature.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A pricing plan exactly as the public API describes it.
class PublicPlanCard extends StatelessWidget {
  const PublicPlanCard({super.key, required this.plan});

  final PricingPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final price = plan.price;
    final priceLabel = price == null
        ? context.tr('pricingComingSoon')
        : price == 0
            ? context.tr('free')
            : Formatters.currency(price, plan.currency);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: plan.highlighted ? scheme.primary : scheme.outlineVariant,
          width: plan.highlighted ? 1.8 : 1,
        ),
        boxShadow: plan.highlighted
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (plan.highlighted)
                StatusChip(
                  status: 'active',
                  label: context.tr('recommended'),
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            priceLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (price != null && price > 0)
            Text(
              plan.billingIntervalLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              plan.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final feature in plan.features)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 17,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(feature, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
          ],
          if (plan.limits.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final limit in plan.limits)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.remove,
                      size: 17,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        limit,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: plan.purchaseAvailable
                ? context.tr('getStarted')
                : context.tr('joinWaitlist'),
            expand: true,
            onPressed: () => context.push(
              plan.purchaseAvailable
                  ? RoutePaths.register
                  : RoutePaths.waitlist,
            ),
          ),
        ],
      ),
    );
  }
}

/// Blog/newsletter card. [featured] gives the newest article a cover image.
class PublicArticleCard extends StatelessWidget {
  const PublicArticleCard({
    super.key,
    required this.article,
    this.featured = false,
  });

  final Newsletter article;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final direction =
        article.isArabic ? TextDirection.rtl : Directionality.of(context);

    final meta = [
      if (article.publishedAt != null) Formatters.date(article.publishedAt),
      context.tr('readingMinutes', args: {'count': article.readingMinutes}),
    ].join(' · ');

    return Directionality(
      textDirection: direction,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.push(RoutePaths.publicArticle(article.slug)),
          child: featured
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _Cover(
                        url: article.coverImageUrl,
                        iconSize: 34,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.excerpt,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            meta,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: _Cover(
                            url: article.coverImageUrl,
                            iconSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meta,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.iconSize});

  final String? url;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = Container(
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(
        Icons.newspaper_outlined,
        size: iconSize,
        color: scheme.onPrimaryContainer,
      ),
    );

    if (url == null || url!.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (context, value) => fallback,
      errorWidget: (context, value, error) => fallback,
    );
  }
}
