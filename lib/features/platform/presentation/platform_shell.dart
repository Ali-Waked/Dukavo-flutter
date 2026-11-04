import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';

class _PlatformDestination {
  const _PlatformDestination({
    required this.path,
    required this.labelKey,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;
}

/// The persistent chrome of the platform console.
///
/// The console deliberately has its own five tabs rather than reusing the
/// merchant shell: a platform operator is not inside a workspace, so the
/// merchant navigation (orders, products, conversations) would all answer 403.
class PlatformShell extends StatelessWidget {
  const PlatformShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const destinations = <_PlatformDestination>[
    _PlatformDestination(
      path: RoutePaths.platformDashboard,
      labelKey: 'overview',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard,
    ),
    _PlatformDestination(
      path: RoutePaths.platformTenants,
      labelKey: 'tenants',
      icon: Icons.business_outlined,
      selectedIcon: Icons.business,
    ),
    _PlatformDestination(
      path: RoutePaths.platformUsers,
      labelKey: 'platformUsers',
      icon: Icons.admin_panel_settings_outlined,
      selectedIcon: Icons.admin_panel_settings,
    ),
    _PlatformDestination(
      path: RoutePaths.platformMarketing,
      labelKey: 'marketing',
      icon: Icons.campaign_outlined,
      selectedIcon: Icons.campaign,
    ),
    _PlatformDestination(
      path: RoutePaths.platformMore,
      labelKey: 'more',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var selectedIndex = 0;
    for (var i = 0; i < destinations.length; i++) {
      final path = destinations[i].path;
      if (location == path ||
          location.startsWith('$path/') ||
          _belongsTo(location, path)) {
        selectedIndex = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index == selectedIndex) return;
          context.go(destinations[index].path);
        },
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: context.tr(destination.labelKey),
            ),
        ],
      ),
    );
  }

  /// Sub-pages that logically belong to a tab but do not share its prefix.
  bool _belongsTo(String location, String tab) {
    if (tab == RoutePaths.platformMarketing) {
      return location.startsWith(RoutePaths.platformPricing) ||
          location.startsWith(RoutePaths.platformFaq) ||
          location.startsWith(RoutePaths.platformContentPages) ||
          location.startsWith(RoutePaths.platformNewsletters) ||
          location.startsWith(RoutePaths.platformWaitlist) ||
          location.startsWith(RoutePaths.platformContact) ||
          location.startsWith(RoutePaths.platformSubscribers);
    }
    if (tab == RoutePaths.platformMore) {
      return location.startsWith(RoutePaths.platformRoles) ||
          location.startsWith(RoutePaths.platformAudit) ||
          location.startsWith(RoutePaths.platformSettings);
    }
    return false;
  }
}
