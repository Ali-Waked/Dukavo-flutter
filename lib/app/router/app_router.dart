import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/permissions.dart';
import '../../core/widgets/app_widgets.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/tenant_screens.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/conversations/presentation/conversations_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import '../../features/products/presentation/product_form_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/shell/presentation/more_screen.dart';
import '../../features/shell/presentation/no_access_screen.dart';
import 'route_paths.dart';

/// A [Listenable] that fires whenever the auth status changes.
///
/// GoRouter only needs to re-evaluate its redirect when the *status* changes,
/// not on every keystroke or list update, so this deliberately ignores state
/// changes that cannot affect navigation.
class _AuthStatusListenable extends ChangeNotifier {
  _AuthStatusListenable(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }
}

/// The first screen a signed-in user may actually open.
///
/// A role without `dashboard.view` must not land on a screen that would answer
/// 403, so the landing page is the first destination the server's permission
/// list allows.
String homePathFor(Permissions permissions) {
  if (permissions.canViewDashboard) return RoutePaths.dashboard;
  if (permissions.canViewOrders) return RoutePaths.orders;
  if (permissions.canViewProducts) return RoutePaths.products;
  if (permissions.canViewConversations) return RoutePaths.conversations;
  return RoutePaths.more;
}

String? _permissionRedirect(Permissions permissions, String path) {
  // Creation and edit screens require a narrower permission than their list.
  if (path == RoutePaths.createOrder) {
    return permissions.canCreateOrders ? null : RoutePaths.noAccess;
  }
  if (path == RoutePaths.createProduct) {
    return permissions.canCreateProducts ? null : RoutePaths.noAccess;
  }
  if (path.startsWith('${RoutePaths.products}/') && path.endsWith('/edit')) {
    return permissions.canManageProducts ? null : RoutePaths.noAccess;
  }
  if (path == RoutePaths.createCustomer) {
    return permissions.canCreateCustomers ? null : RoutePaths.noAccess;
  }
  if (path.startsWith('${RoutePaths.customers}/') && path.endsWith('/edit')) {
    return permissions.canUpdateCustomers ? null : RoutePaths.noAccess;
  }

  if (path.startsWith(RoutePaths.dashboard)) {
    return permissions.canViewDashboard ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.orders)) {
    return permissions.canViewOrders ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.products)) {
    return permissions.canViewProducts ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.categories)) {
    return permissions.canViewCategories ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.customers)) {
    return permissions.canViewCustomers ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.inventory)) {
    return permissions.canViewInventory ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.conversations)) {
    return permissions.canViewConversations ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.analytics)) {
    return permissions.canViewAnalytics ? null : RoutePaths.noAccess;
  }

  // Notifications, profile, settings and the overflow menu are personal to the
  // signed-in account and available to every role.
  return null;
}

String? _redirect(Ref ref, GoRouterState state) {
  final status = ref.read(authControllerProvider).status;
  final path = state.uri.path;

  final onSplash = path == RoutePaths.splash;
  final onAuth =
      path == RoutePaths.login || path == RoutePaths.forgotPassword;
  final onSetup = path == RoutePaths.setup;

  switch (status) {
    case AuthStatus.unknown:
      return onSplash ? null : RoutePaths.splash;

    case AuthStatus.unauthenticated:
      return onAuth ? null : RoutePaths.login;

    case AuthStatus.needsTenant:
      return onSetup ? null : RoutePaths.setup;

    case AuthStatus.authenticated:
      final permissions = ref.read(permissionsProvider);
      if (onSplash || onAuth || onSetup) {
        return homePathFor(permissions);
      }
      if (path == RoutePaths.noAccess) return null;
      return _permissionRedirect(permissions, path);
  }
}

List<RouteBase> _routes() {
  return [
    GoRoute(
      path: '/',
      redirect: (context, state) => RoutePaths.splash,
    ),
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RoutePaths.setup,
      builder: (context, state) => const TenantSetupScreen(),
    ),
    GoRoute(
      path: RoutePaths.noAccess,
      builder: (context, state) => const NoAccessScreen(),
    ),

    /*
     * Primary tabs. The shell keeps the bottom navigation visible; every other
     * screen is a sibling of the shell so it takes the whole viewport and owns
     * its own app bar.
     */
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: RoutePaths.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RoutePaths.orders,
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: RoutePaths.products,
          builder: (context, state) => const ProductsScreen(),
        ),
        GoRoute(
          path: RoutePaths.conversations,
          builder: (context, state) => const ConversationsScreen(),
        ),
        GoRoute(
          path: RoutePaths.more,
          builder: (context, state) => const MoreScreen(),
        ),
      ],
    ),

    // Orders. The literal "new" route must precede the parameterised one.
    GoRoute(
      path: RoutePaths.createOrder,
      builder: (context, state) => const OrderFormScreen(),
    ),
    GoRoute(
      path: '/orders/:orderNumber',
      builder: (context, state) => OrderDetailScreen(
        orderNumber: state.pathParameters['orderNumber'] ?? '',
      ),
    ),

    // Catalogue.
    GoRoute(
      path: RoutePaths.createProduct,
      builder: (context, state) => const ProductFormScreen(),
    ),
    GoRoute(
      path: '/products/:slug/edit',
      builder: (context, state) => ProductFormScreen(
        slug: state.pathParameters['slug'],
      ),
    ),
    GoRoute(
      path: '/products/:slug',
      builder: (context, state) => ProductDetailScreen(
        slug: state.pathParameters['slug'] ?? '',
      ),
    ),
    GoRoute(
      path: RoutePaths.categories,
      builder: (context, state) => const CategoriesScreen(),
    ),

    // Customers.
    GoRoute(
      path: RoutePaths.createCustomer,
      builder: (context, state) => const CustomerFormScreen(),
    ),
    GoRoute(
      path: '/customers/:id/edit',
      builder: (context, state) => CustomerFormScreen(
        id: int.tryParse(state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/customers/:id',
      builder: (context, state) => CustomerDetailScreen(
        id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
      ),
    ),

    // Inventory, inbox, notifications, analytics and account screens.
    GoRoute(
      path: RoutePaths.inventory,
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
      path: '/conversations/:id',
      builder: (context, state) => ConversationThreadScreen(
        id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
      ),
    ),
    GoRoute(
      path: RoutePaths.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: RoutePaths.analytics,
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: RoutePaths.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RoutePaths.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ];
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthStatusListenable(ref);
  final router = GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: listenable,
    redirect: (context, state) => _redirect(ref, state),
    routes: _routes(),
    errorBuilder: (context, state) => _RouteErrorScreen(
      message: state.error?.toString() ?? '',
    ),
  );

  ref.onDispose(() {
    listenable.dispose();
    router.dispose();
  });

  return router;
});

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ErrorView(
        message: message.isEmpty ? 'This page could not be opened.' : message,
        onRetry: () => context.go('/'),
      ),
    );
  }
}
