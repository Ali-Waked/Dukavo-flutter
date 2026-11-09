import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/application/notification_controller.dart';

/// One navigation destination, gated by a permission the server enforces.
class _Destination {
  const _Destination({
    required this.path,
    required this.labelKey,
    required this.icon,
    required this.selectedIcon,
    this.visible = true,
    this.badge = 0,
  });

  final String path;
  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;
  final bool visible;
  final int badge;
}

/// The persistent chrome around the main workspaces plus "More".
///
/// Destinations are built from the permissions returned by `/me`, so a user
/// never sees a tab whose every screen would answer 403. The server remains the
/// authority; hiding is a courtesy, not a boundary.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    final unread = ref.watch(notificationUnreadProvider);

    final destinations = <_Destination>[
      _Destination(
        path: RoutePaths.dashboard,
        labelKey: 'dashboard',
        icon: Icons.space_dashboard_outlined,
        selectedIcon: Icons.space_dashboard,
        visible: permissions.canViewDashboard,
      ),
      _Destination(
        path: RoutePaths.orders,
        labelKey: 'orders',
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        visible: permissions.canViewOrders,
      ),
      _Destination(
        path: RoutePaths.products,
        labelKey: 'products',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        visible: permissions.canViewProducts,
      ),
      _Destination(
        path: RoutePaths.conversations,
        labelKey: 'conversations',
        icon: Icons.chat_bubble_outline,
        selectedIcon: Icons.chat_bubble,
        visible: permissions.canViewConversations,
      ),
      _Destination(
        path: RoutePaths.more,
        labelKey: 'more',
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view,
        badge: unread,
      ),
    ].where((destination) => destination.visible).toList();

    var selectedIndex = 0;
    for (var i = 0; i < destinations.length; i++) {
      if (location == destinations[i].path ||
          location.startsWith('${destinations[i].path}/')) {
        selectedIndex = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index == selectedIndex) return;
          context.go(destinations[index].path);
        },
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: _maybeBadged(destination.icon, destination.badge),
              selectedIcon: _maybeBadged(
                destination.selectedIcon,
                destination.badge,
              ),
              label: context.tr(destination.labelKey),
            ),
        ],
      ),
    );
  }

  Widget _maybeBadged(IconData icon, int count) {
    if (count <= 0) return Icon(icon);
    return Badge(
      label: Text(count > 99 ? '99+' : '$count'),
      child: Icon(icon),
    );
  }
}
