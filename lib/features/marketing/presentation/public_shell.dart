import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import 'public_widgets.dart';

/// The chrome shared by the four public tabs.
///
/// The bottom bar mirrors the web's primary navigation. "More" is not a
/// destination: it opens a sheet so the public stack stays intact and the
/// merchant `/more` route keeps its own meaning.
class PublicShell extends ConsumerWidget {
  const PublicShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(size: 26, showWordmark: true),
        actions: const [PublicChromeActions()],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          if (index == 4) {
            showPublicMoreSheet(context, ref);
            return;
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: context.tr('publicNavHome'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: context.tr('publicNavFeatures'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.sell_outlined),
            selectedIcon: const Icon(Icons.sell),
            label: context.tr('publicNavPricing'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            label: context.tr('publicNavAbout'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: context.tr('publicNavMore'),
          ),
        ],
      ),
    );
  }
}

/// Opens the public overflow sheet.
Future<void> showPublicMoreSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => _PublicMoreSheet(
      onNavigate: (path) {
        Navigator.of(sheetContext).pop();
        context.push(path);
      },
      onAccount: () {
        Navigator.of(sheetContext).pop();
        openPublicAccount(context, ref);
      },
    ),
  );
}

class _PublicMoreSheet extends ConsumerWidget {
  const _PublicMoreSheet({
    required this.onNavigate,
    required this.onAccount,
  });

  final ValueChanged<String> onNavigate;
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final auth = ref.watch(authControllerProvider);
    final mode = ref.watch(themeControllerProvider);
    final locale = ref.watch(effectiveLocaleProvider);
    final signedIn = auth.isAuthenticated;

    final modeLabel = switch (mode) {
      ThemeMode.light => context.tr('light'),
      ThemeMode.dark => context.tr('dark'),
      ThemeMode.system => context.tr('system'),
    };

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              const AppLogo(size: 34, showWordmark: true),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.tint(scheme.primary),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.tr('appTagline'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SheetLabel(context.tr('publicMenuExplore')),
          _SheetGroup(
            children: [
              _SheetTile(
                icon: Icons.route_outlined,
                label: context.tr('publicNavHowItWorks'),
                onTap: () => onNavigate(RoutePaths.publicHowItWorks),
              ),
              _SheetTile(
                icon: Icons.help_outline,
                label: context.tr('publicNavFaq'),
                onTap: () => onNavigate(RoutePaths.publicFaq),
              ),
              _SheetTile(
                icon: Icons.newspaper_outlined,
                label: context.tr('publicNavBlog'),
                onTap: () => onNavigate(RoutePaths.publicBlog),
              ),
              _SheetTile(
                icon: Icons.mail_outline,
                label: context.tr('publicNavContact'),
                onTap: () => onNavigate(RoutePaths.publicContact),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SheetLabel(context.tr('publicMenuAccount')),
          _SheetGroup(
            children: [
              _SheetTile(
                icon: signedIn
                    ? Icons.space_dashboard_outlined
                    : Icons.login_outlined,
                label: signedIn
                    ? context.tr('publicOpenApp')
                    : context.tr('signIn'),
                subtitle: signedIn
                    ? context.tr('publicMenuOpenAppHint')
                    : context.tr('publicMenuSignInHint'),
                onTap: onAccount,
              ),
              if (!signedIn)
                _SheetTile(
                  icon: Icons.person_add_alt_outlined,
                  label: context.tr('register'),
                  subtitle: context.tr('publicLoginInviteOnly'),
                  onTap: () => onNavigate(RoutePaths.register),
                ),
              _SheetTile(
                icon: Icons.hourglass_empty,
                label: context.tr('joinWaitlist'),
                onTap: () => onNavigate(RoutePaths.waitlist),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SheetLabel(context.tr('publicMenuPreferences')),
          _SheetGroup(
            children: [
              _SheetTile(
                icon: Icons.translate,
                label: context.tr('language'),
                trailing: locale.languageCode == 'ar'
                    ? context.tr('arabic')
                    : context.tr('english'),
                onTap: () =>
                    ref.read(localeControllerProvider.notifier).toggle(),
              ),
              _SheetTile(
                icon: Icons.contrast,
                label: context.tr('theme'),
                trailing: modeLabel,
                onTap: () {
                  final controller =
                      ref.read(themeControllerProvider.notifier);
                  controller.setMode(
                    switch (mode) {
                      ThemeMode.light => ThemeMode.dark,
                      ThemeMode.dark => ThemeMode.system,
                      ThemeMode.system => ThemeMode.light,
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SheetLabel(context.tr('publicMenuLegal')),
          _SheetGroup(
            children: [
              _SheetTile(
                icon: Icons.description_outlined,
                label: context.tr('termsOfService'),
                onTap: () =>
                    onNavigate(RoutePaths.publicPage('terms')),
              ),
              _SheetTile(
                icon: Icons.privacy_tip_outlined,
                label: context.tr('privacyPolicy'),
                onTap: () =>
                    onNavigate(RoutePaths.publicPage('privacy')),
              ),
              _SheetTile(
                icon: Icons.storefront_outlined,
                label: context.tr('browseShop'),
                onTap: () => onNavigate(RoutePaths.shop),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Dukavo 1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SheetGroup extends StatelessWidget {
  const _SheetGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing == null
          ? const Icon(Icons.chevron_right)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailing!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            ),
      onTap: onTap,
    );
  }
}
