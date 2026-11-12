import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/permissions.dart';
import '../../core/resources/json_resource.dart';
import '../../core/resources/resource_screens.dart';
import '../../core/resources/resource_spec.dart';
import '../../core/widgets/app_widgets.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/ai_settings/presentation/ai_settings_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/tenant_screens.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/conversations/presentation/conversations_screen.dart';
import '../../features/customers/presentation/customer_crm_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/help/domain/help_models.dart';
import '../../features/help/presentation/support_screens.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/integrations/presentation/integrations_screen.dart';
import '../../features/marketing/presentation/public_screens.dart';
import '../../features/marketing/presentation/public_shell.dart';
import '../../features/merchant/presentation/inventory_intelligence_screen.dart';
import '../../features/merchant/presentation/inventory_transfer_screen.dart';
import '../../features/merchant/presentation/merchant_ai_screens.dart';
import '../../features/merchant/presentation/merchant_hubs.dart';
import '../../features/merchant/presentation/merchant_specs.dart';
import '../../features/merchant/presentation/profit_screen.dart';
import '../../features/merchant/presentation/recovery_screen.dart';
import '../../features/notifications/domain/notification_domain.dart';
import '../../features/notifications/presentation/notification_detail_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/payments/presentation/merchant_payments_screen.dart';
import '../../features/payments/presentation/payment_settings_screen.dart';
import '../../features/platform/presentation/platform_ai_admin_screen.dart';
import '../../features/platform/presentation/platform_dashboard_screen.dart';
import '../../features/platform/presentation/platform_integrations_screen.dart';
import '../../features/platform/presentation/platform_marketing_screen.dart';
import '../../features/platform/presentation/platform_notifications_screen.dart';
import '../../features/platform/presentation/platform_payments_screen.dart';
import '../../features/platform/presentation/platform_more_screen.dart';
import '../../features/platform/presentation/platform_shell.dart';
import '../../features/platform/presentation/platform_specs.dart';
import '../../features/platform_settings/presentation/platform_settings_features_screen.dart';
import '../../features/platform_settings/presentation/platform_settings_health_screen.dart';
import '../../features/platform_settings/presentation/platform_settings_history_screen.dart';
import '../../features/platform_settings/presentation/platform_settings_infrastructure_screen.dart';
import '../../features/platform_settings/presentation/platform_settings_screen.dart';
import '../../features/platform_settings/presentation/platform_settings_section_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import '../../features/products/presentation/product_form_screen.dart';
import '../../features/products/presentation/product_images_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/profile/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/security_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shipping/presentation/shipping_zones_screen.dart';
import '../../features/shop/application/shop_providers.dart';
import '../../features/shop/presentation/shop_cart_screen.dart';
import '../../features/shop/presentation/shop_checkout_screen.dart';
import '../../features/shop/presentation/shop_order_screen.dart';
import '../../features/shop/presentation/shop_product_screen.dart';
import '../../features/shop/presentation/shop_shell.dart';
import '../../features/shop/presentation/shop_track_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/shell/presentation/more_screen.dart';
import '../../features/shell/presentation/no_access_screen.dart';
import '../../features/storefront/presentation/storefront_settings_screen.dart';
import '../../features/translations/presentation/translation_assistant_screen.dart';
import '../../features/stores/presentation/store_currency_screen.dart';
import '../../features/team/presentation/role_permissions_screen.dart';
import '../../features/team/presentation/team_user_form_screen.dart';
import 'auth_destination.dart';
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

/// Marketing and public storefront pages are readable without a session.
bool _isPublicPath(String path) {
  const exact = <String>{
    RoutePaths.home,
    RoutePaths.publicFeatures,
    RoutePaths.publicPricing,
    RoutePaths.publicHowItWorks,
    RoutePaths.publicAbout,
    RoutePaths.publicFaq,
    RoutePaths.publicBlog,
    RoutePaths.publicContact,
    RoutePaths.waitlist,
    RoutePaths.register,
    RoutePaths.resetPassword,
  };
  if (exact.contains(path)) return true;
  if (path.startsWith('${RoutePaths.publicBlog}/')) return true;
  if (path.startsWith('/pages/')) return true;
  if (path == RoutePaths.site || path.startsWith('${RoutePaths.site}/')) {
    return true;
  }
  if (path == RoutePaths.shop || path.startsWith('${RoutePaths.shop}/')) {
    return true;
  }
  return false;
}

/// Screens that belong to the person, not to a workspace or the platform.
bool _isPersonalPath(String path) {
  return path.startsWith(RoutePaths.profile) ||
      path.startsWith(RoutePaths.security) ||
      path.startsWith(RoutePaths.welcome) ||
      path.startsWith(RoutePaths.settings) ||
      path.startsWith(RoutePaths.notifications) ||
      // The Help Center is readable by every signed-in role: merchants read
      // the merchant tier, platform operators read everything.
      path.startsWith(RoutePaths.support);
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
  if (path.startsWith(RoutePaths.storefront)) {
    return permissions.canViewStorefront ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.shippingZones)) {
    return permissions.canViewShipping ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.paymentSettings)) {
    return permissions.canViewPayments ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.paymentConnections) ||
      path.startsWith('/payments/history')) {
    return permissions.canViewPayments ? null : RoutePaths.noAccess;
  }

  // Merchant workspace additions.
  if (path.startsWith(RoutePaths.team)) {
    return permissions.canViewUsers || permissions.canViewRoles
        ? null
        : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.audit)) {
    return permissions.canViewAudit ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.bundles)) {
    return permissions.canViewProducts ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.whatsapp)) {
    return permissions.canViewWhatsapp ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.integrations)) {
    return permissions.canViewIntegrations ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.aiActions) ||
      path.startsWith(RoutePaths.aiCopilot) ||
      path.startsWith(RoutePaths.aiInsights)) {
    return permissions.canUseAi ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.automations)) {
    return permissions.canViewAutomation ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.recovery)) {
    return permissions.canViewRecovery ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.profit)) {
    return permissions.canViewProfit ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.stores)) {
    return permissions.canViewStores ? null : RoutePaths.noAccess;
  }
  if (path.startsWith(RoutePaths.inventoryIntelligence)) {
    return permissions.canViewInventory ? null : RoutePaths.noAccess;
  }
  if (path.startsWith('${RoutePaths.products}/') && path.endsWith('/images')) {
    return permissions.canManageProducts ? null : RoutePaths.noAccess;
  }

  // Notifications, profile, settings and the overflow menu are personal to the
  // signed-in account and available to every role.
  return null;
}

/// Builds the login URL that remembers where the visitor was going.
String _loginLocation(GoRouterState state) {
  return Uri(
    path: RoutePaths.login,
    queryParameters: <String, String>{'redirect': state.uri.toString()},
  ).toString();
}

String? _redirect(Ref ref, GoRouterState state) {
  final auth = ref.read(authControllerProvider);
  final status = auth.status;
  final session = auth.session;
  final path = state.uri.path;

  final onSplash = path == RoutePaths.splash;
  final onAuth = path == RoutePaths.login ||
      path == RoutePaths.forgotPassword ||
      path == RoutePaths.register;
  final onSetup = path == RoutePaths.setup;
  final onVerify = path == RoutePaths.verifyEmail;
  final public = _isPublicPath(path);

  // The splash owns its own timed exit. It waits for both the animation and the
  // auth bootstrap, then navigates to the destination that state allows. If the
  // router redirected here as soon as the token resolved, the brand animation
  // would be cut off after a few frames.
  if (onSplash) return null;

  switch (status) {
    case AuthStatus.unknown:
      return public ? null : RoutePaths.splash;

    case AuthStatus.unauthenticated:
      if (onVerify) return _loginLocation(state);
      return onAuth || public ? null : _loginLocation(state);

    case AuthStatus.needsTenant:
      return onSetup || public ? null : RoutePaths.setup;

    case AuthStatus.platform:
      if (onAuth || onSetup) return RoutePaths.platformDashboard;
      if (public || onVerify || path == RoutePaths.noAccess) return null;
      if (path.startsWith(RoutePaths.platform)) {
        return path == RoutePaths.platform
            ? RoutePaths.platformDashboard
            : null;
      }
      if (_isPersonalPath(path)) return null;
      return RoutePaths.platformDashboard;

    case AuthStatus.authenticated:
      final permissions = ref.read(permissionsProvider);
      final canUsePlatform = session?.canUsePlatform ?? false;
      if (onSetup) return homePathFor(permissions, platformMode: false);
      if (onAuth) {
        return sanitizeRedirect(state.uri.queryParameters['redirect']) ??
            homePathFor(permissions, platformMode: false);
      }
      if (onVerify || public || path == RoutePaths.noAccess) return null;
      if (path.startsWith(RoutePaths.platform)) {
        if (!canUsePlatform) return RoutePaths.noAccess;
        // A platform route only renders in the platform context. While a
        // merchant workspace is active the switcher must move the account
        // there first, so platform requests never carry a tenant header.
        if (session?.hasTenant ?? false) return homePathFor(permissions);
        return path == RoutePaths.platform
            ? RoutePaths.platformDashboard
            : null;
      }
      return _permissionRedirect(permissions, path);
  }
}

/// The resource the list handed over as `extra`, if any.
///
/// Tapping a row passes the already-loaded payload so a detail screen paints
/// immediately; a deep link arrives without it and fetches by id instead.
JsonResource? _initialResource(GoRouterState state) {
  final extra = state.extra;
  return extra is JsonResource ? extra : null;
}

ResourceDetailScreen _resourceDetail(
  ResourceSpec spec,
  GoRouterState state,
  int id,
) {
  return ResourceDetailScreen(
    spec: spec,
    id: id,
    initial: _initialResource(state),
  );
}

ResourceFormScreen _resourceForm(
  ResourceSpec spec,
  GoRouterState state, {
  int? id,
}) {
  return ResourceFormScreen(
    spec: spec,
    id: id,
    initial: _initialResource(state),
  );
}

int _idOf(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

List<RouteBase> _routes() {
  return [
    GoRoute(
      path: '/',
      redirect: (context, state) => RoutePaths.splash,
    ),
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const DukavoSplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => LoginScreen(
        redirect: sanitizeRedirect(state.uri.queryParameters['redirect']),
      ),
    ),
    GoRoute(
      path: RoutePaths.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RoutePaths.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RoutePaths.resetPassword,
      builder: (context, state) => ResetPasswordScreen(
        token: state.uri.queryParameters['token'] ?? '',
        email: state.uri.queryParameters['email'] ?? '',
      ),
    ),
    GoRoute(
      path: RoutePaths.verifyEmail,
      builder: (context, state) => const VerifyEmailScreen(),
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
      path: '/products/:slug/images',
      builder: (context, state) => ProductImagesScreen(
        slug: state.pathParameters['slug'] ?? '',
      ),
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

    // AI translation review. The surface and entity are validated by the server;
    // this route only carries the target record.
    GoRoute(
      path: '/translations/:surface/:entity/:id',
      builder: (context, state) {
        final surface = state.pathParameters['surface'] ?? '';
        return TranslationAssistantScreen(
          surface: surface == 'platform' ? 'platform' : 'tenant',
          entity: state.pathParameters['entity'] ?? '',
          recordId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        );
      },
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
      path: '/customers/:id/crm',
      builder: (context, state) => CustomerCrmScreen(
        id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
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
      path: '/notifications/:id',
      builder: (context, state) => NotificationDetailScreen(
        id: state.pathParameters['id'] ?? '',
        initial: state.extra is AppNotification
            ? state.extra! as AppNotification
            : null,
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
      path: RoutePaths.storefront,
      builder: (context, state) => const StorefrontSettingsScreen(),
    ),
    GoRoute(
      path: RoutePaths.shippingZones,
      builder: (context, state) => const ShippingZonesScreen(),
    ),
    GoRoute(
      path: RoutePaths.paymentSettings,
      builder: (context, state) => const PaymentSettingsScreen(),
    ),
    GoRoute(
      path: RoutePaths.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RoutePaths.security,
      builder: (context, state) => const SecurityScreen(),
    ),
    GoRoute(
      path: RoutePaths.welcome,
      builder: (context, state) => const PreferencesOnboardingPage(),
    ),
    GoRoute(
      path: RoutePaths.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    // The Help Center: readable by every signed-in account, widened to the
    // reader's tier. `?q=` pre-fills the search for contextual deep links.
    GoRoute(
      path: RoutePaths.support,
      builder: (context, state) => SupportScreen(
        initialQuery: state.uri.queryParameters['q'],
      ),
    ),
    GoRoute(
      path: '/support/categories/:slug',
      builder: (context, state) => SupportCategoryScreen(
        slug: state.pathParameters['slug'] ?? '',
        category:
            state.extra is HelpCategory ? state.extra! as HelpCategory : null,
      ),
    ),
    GoRoute(
      path: '/support/articles/:slug',
      builder: (context, state) => SupportArticleScreen(
        slug: state.pathParameters['slug'] ?? '',
      ),
    ),

    /*
     * Merchant additions: team and governance, growth tools, automation,
     * recovery, profit and multi-store management. These live outside the tab
     * shell so their own app bars and back buttons own the screen.
     */
    GoRoute(
      path: RoutePaths.team,
      builder: (context, state) => const MerchantTeamHubScreen(),
    ),
    GoRoute(
      path: RoutePaths.teamMembers,
      builder: (context, state) => ResourceListScreen(spec: tenantUserSpec),
    ),
    GoRoute(
      path: RoutePaths.teamRoles,
      builder: (context, state) => ResourceListScreen(spec: tenantRoleSpec),
    ),
    GoRoute(
      path: RoutePaths.audit,
      builder: (context, state) => ResourceListScreen(spec: tenantAuditSpec),
    ),
    GoRoute(
      path: RoutePaths.createUser,
      builder: (context, state) => const TeamUserFormScreen(),
    ),
    GoRoute(
      path: '/team/users/:id/edit',
      builder: (context, state) => TeamUserFormScreen(id: _idOf(state)),
    ),
    GoRoute(
      path: '/team/users/:id',
      builder: (context, state) => _resourceDetail(
        tenantUserSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.createRole,
      builder: (context, state) => const RolePermissionsScreen(),
    ),
    GoRoute(
      path: '/team/roles/:id/edit',
      builder: (context, state) => RolePermissionsScreen(id: _idOf(state)),
    ),
    GoRoute(
      path: '/team/roles/:id',
      builder: (context, state) => RolePermissionsScreen(id: _idOf(state)),
    ),
    GoRoute(
      path: '/audit/:id',
      builder: (context, state) => _resourceDetail(
        tenantAuditSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.bundles,
      builder: (context, state) => ResourceListScreen(spec: bundleSpec),
    ),
    GoRoute(
      path: RoutePaths.createBundle,
      builder: (context, state) => _resourceForm(bundleSpec, state),
    ),
    GoRoute(
      path: '/bundles/:id/edit',
      builder: (context, state) =>
          _resourceForm(bundleSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/bundles/:id',
      builder: (context, state) => _resourceDetail(
        bundleSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.whatsapp,
      builder: (context, state) => ResourceListScreen(spec: whatsappSpec),
    ),
    GoRoute(
      path: RoutePaths.createWhatsapp,
      builder: (context, state) => _resourceForm(whatsappSpec, state),
    ),
    GoRoute(
      path: '/whatsapp/:id/edit',
      builder: (context, state) =>
          _resourceForm(whatsappSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/whatsapp/:id',
      builder: (context, state) => _resourceDetail(
        whatsappSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.aiActions,
      builder: (context, state) => ResourceListScreen(spec: aiActionSpec),
    ),
    GoRoute(
      path: '/ai-actions/:id',
      builder: (context, state) => _resourceDetail(
        aiActionSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.aiSettings,
      builder: (context, state) => const AiSettingsScreen(),
    ),
    GoRoute(
      path: RoutePaths.integrations,
      builder: (context, state) => const IntegrationsScreen(),
    ),
    GoRoute(
      path: RoutePaths.automations,
      builder: (context, state) => const MerchantAutomationHubScreen(),
    ),
    GoRoute(
      path: RoutePaths.automationRules,
      builder: (context, state) => ResourceListScreen(spec: automationRuleSpec),
    ),
    GoRoute(
      path: RoutePaths.automationRuns,
      builder: (context, state) => ResourceListScreen(spec: automationRunSpec),
    ),
    GoRoute(
      path: RoutePaths.automationTasks,
      builder: (context, state) => ResourceListScreen(spec: automationTaskSpec),
    ),
    GoRoute(
      path: RoutePaths.createAutomation,
      builder: (context, state) => _resourceForm(automationRuleSpec, state),
    ),
    GoRoute(
      path: '/automations/rules/:id/edit',
      builder: (context, state) =>
          _resourceForm(automationRuleSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/automations/rules/:id',
      builder: (context, state) => _resourceDetail(
        automationRuleSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: '/automations/runs/:id',
      builder: (context, state) => _resourceDetail(
        automationRunSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: '/automations/tasks/:id',
      builder: (context, state) => _resourceDetail(
        automationTaskSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.automationTemplates,
      builder: (context, state) =>
          ResourceListScreen(spec: automationTemplateSpec),
    ),
    GoRoute(
      path: '/automations/templates/:id',
      builder: (context, state) => _resourceDetail(
        automationTemplateSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.automationInstallations,
      builder: (context, state) =>
          ResourceListScreen(spec: automationInstallationSpec),
    ),
    GoRoute(
      path: '/automations/installations/:id',
      builder: (context, state) => _resourceDetail(
        automationInstallationSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.aiCopilot,
      builder: (context, state) => const MerchantCopilotScreen(),
    ),
    GoRoute(
      path: RoutePaths.aiInsights,
      builder: (context, state) => const MerchantInsightsScreen(),
    ),
    GoRoute(
      path: RoutePaths.inventoryTransfer,
      builder: (context, state) => const InventoryTransferScreen(),
    ),
    GoRoute(
      path: RoutePaths.paymentConnections,
      builder: (context, state) => const MerchantPaymentsScreen(),
    ),
    GoRoute(
      path: RoutePaths.paymentHistory,
      builder: (context, state) => const MerchantPaymentsScreen(),
    ),
    GoRoute(
      path: RoutePaths.recovery,
      builder: (context, state) => const RecoveryScreen(),
    ),
    GoRoute(
      path: '/recovery/:id',
      builder: (context, state) => _resourceDetail(
        recoverySpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.profit,
      builder: (context, state) => const ProfitScreen(),
    ),
    GoRoute(
      path: RoutePaths.stores,
      builder: (context, state) => ResourceListScreen(spec: storeSpec),
    ),
    GoRoute(
      path: RoutePaths.createStore,
      builder: (context, state) => _resourceForm(storeSpec, state),
    ),
    GoRoute(
      path: '/stores/:id/edit',
      builder: (context, state) =>
          _resourceForm(storeSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/stores/:id',
      builder: (context, state) => _resourceDetail(
        storeSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: '/stores/:id/currency',
      builder: (context, state) => StoreCurrencyScreen(storeId: _idOf(state)),
    ),
    GoRoute(
      path: RoutePaths.inventoryIntelligence,
      builder: (context, state) => const InventoryIntelligenceScreen(),
    ),

    /*
     * Platform console. Its five primary tabs share one shell; the rest are
     * siblings so a detail or editor takes the full screen.
     */
    ShellRoute(
      builder: (context, state, child) =>
          PlatformShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: RoutePaths.platformDashboard,
          builder: (context, state) => const PlatformDashboardScreen(),
        ),
        GoRoute(
          path: RoutePaths.platformTenants,
          builder: (context, state) =>
              ResourceListScreen(spec: platformTenantSpec),
        ),
        GoRoute(
          path: RoutePaths.platformUsers,
          builder: (context, state) =>
              ResourceListScreen(spec: platformUserSpec),
        ),
        GoRoute(
          path: RoutePaths.platformMarketing,
          builder: (context, state) => const PlatformMarketingScreen(),
        ),
        GoRoute(
          path: RoutePaths.platformMore,
          builder: (context, state) => const PlatformMoreScreen(),
        ),
        GoRoute(
          path: RoutePaths.platformSettings,
          builder: (context, state) => const PlatformSettingsScreen(),
        ),
      ],
    ),
    /*
     * Settings sections are full-screen editors. They sit outside the shell so
     * the save bar owns the bottom edge and a long form gets the whole height.
     */
    GoRoute(
      path: RoutePaths.platformSettingsFeatures,
      builder: (context, state) => const PlatformSettingsFeaturesScreen(),
    ),
    GoRoute(
      path: RoutePaths.platformSettingsHealth,
      builder: (context, state) => const PlatformSettingsHealthScreen(),
    ),
    GoRoute(
      path: RoutePaths.platformSettingsHistory,
      builder: (context, state) => const PlatformSettingsHistoryScreen(),
    ),
    GoRoute(
      path: RoutePaths.platformSettingsInfrastructure,
      builder: (context, state) =>
          const PlatformSettingsInfrastructureScreen(),
    ),
    GoRoute(
      path: '/platform/settings/:category',
      builder: (context, state) => PlatformSettingsSectionScreen(
        category: state.pathParameters['category'] ?? 'general',
      ),
    ),
    GoRoute(
      path: RoutePaths.platformCreateTenant,
      builder: (context, state) => _resourceForm(platformTenantFormSpec, state),
    ),
    GoRoute(
      path: '/platform/tenants/:id/edit',
      builder: (context, state) =>
          _resourceForm(platformTenantFormSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/platform/tenants/:id',
      builder: (context, state) => _resourceDetail(
        platformTenantSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformCreateUser,
      builder: (context, state) => const TeamUserFormScreen(platform: true),
    ),
    GoRoute(
      path: '/platform/users/:id/edit',
      builder: (context, state) =>
          TeamUserFormScreen(id: _idOf(state), platform: true),
    ),
    GoRoute(
      path: '/platform/users/:id',
      builder: (context, state) => _resourceDetail(
        platformUserSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformRoles,
      builder: (context, state) => ResourceListScreen(spec: platformRoleSpec),
    ),
    GoRoute(
      path: RoutePaths.platformCreateRole,
      builder: (context, state) => const RolePermissionsScreen(platform: true),
    ),
    GoRoute(
      path: '/platform/roles/:id/edit',
      builder: (context, state) =>
          RolePermissionsScreen(id: _idOf(state), platform: true),
    ),
    GoRoute(
      path: '/platform/roles/:id',
      builder: (context, state) =>
          RolePermissionsScreen(id: _idOf(state), platform: true),
    ),
    GoRoute(
      path: RoutePaths.platformAudit,
      builder: (context, state) => ResourceListScreen(spec: platformAuditSpec),
    ),
    GoRoute(
      path: '/platform/audit/:id',
      builder: (context, state) => _resourceDetail(
        platformAuditSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformPricing,
      builder: (context, state) =>
          ResourceListScreen(spec: platformPricingSpec),
    ),
    GoRoute(
      path: RoutePaths.platformCreatePricing,
      builder: (context, state) => _resourceForm(platformPricingSpec, state),
    ),
    GoRoute(
      path: '/platform/pricing/:id/edit',
      builder: (context, state) =>
          _resourceForm(platformPricingSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/platform/pricing/:id',
      builder: (context, state) => _resourceDetail(
        platformPricingSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformFaq,
      builder: (context, state) => ResourceListScreen(spec: platformFaqSpec),
    ),
    GoRoute(
      path: RoutePaths.platformCreateFaq,
      builder: (context, state) => _resourceForm(platformFaqFormSpec, state),
    ),
    GoRoute(
      path: '/platform/faq/:id/edit',
      builder: (context, state) =>
          _resourceForm(platformFaqFormSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/platform/faq/:id',
      builder: (context, state) => _resourceDetail(
        platformFaqSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformContentPages,
      builder: (context, state) =>
          ResourceListScreen(spec: platformContentPageSpec),
    ),
    GoRoute(
      path: '/platform/content-pages/:id/edit',
      builder: (context, state) =>
          _resourceForm(platformContentPageSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/platform/content-pages/:id',
      builder: (context, state) => _resourceDetail(
        platformContentPageSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformWaitlist,
      builder: (context, state) =>
          ResourceListScreen(spec: platformWaitlistSpec),
    ),
    GoRoute(
      path: '/platform/waitlist/:id/edit',
      builder: (context, state) =>
          _resourceForm(platformWaitlistSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/platform/waitlist/:id',
      builder: (context, state) => _resourceDetail(
        platformWaitlistSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformContact,
      builder: (context, state) =>
          ResourceListScreen(spec: platformContactSpec),
    ),
    GoRoute(
      path: '/platform/contact/:id/edit',
      builder: (context, state) =>
          _resourceForm(platformContactSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/platform/contact/:id',
      builder: (context, state) => _resourceDetail(
        platformContactSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformSubscribers,
      builder: (context, state) =>
          ResourceListScreen(spec: platformSubscriberSpec),
    ),
    GoRoute(
      path: '/platform/subscribers/:id/edit',
      builder: (context, state) =>
          _resourceForm(platformSubscriberSpec, state, id: _idOf(state)),
    ),
    GoRoute(
      path: '/platform/subscribers/:id',
      builder: (context, state) => _resourceDetail(
        platformSubscriberSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformNewsletters,
      builder: (context, state) =>
          ResourceListScreen(spec: platformNewsletterSpec),
    ),
    GoRoute(
      path: RoutePaths.platformCreateNewsletter,
      builder: (context, state) =>
          _resourceForm(platformNewsletterFormSpec, state),
    ),
    GoRoute(
      path: '/platform/newsletters/:id/edit',
      builder: (context, state) => _resourceForm(
        platformNewsletterFormSpec,
        state,
        id: _idOf(state),
      ),
    ),
    GoRoute(
      path: '/platform/newsletters/:id',
      builder: (context, state) => _resourceDetail(
        platformNewsletterSpec,
        state,
        _idOf(state),
      ),
    ),
    GoRoute(
      path: RoutePaths.platformAiAdmin,
      builder: (context, state) => const PlatformAiAdminScreen(),
    ),
    GoRoute(
      path: RoutePaths.platformPayments,
      builder: (context, state) => const PlatformPaymentsScreen(),
    ),
    GoRoute(
      path: RoutePaths.platformIntegrations,
      builder: (context, state) => const PlatformIntegrationsScreen(),
    ),
    GoRoute(
      path: RoutePaths.platformNotifications,
      builder: (context, state) => const PlatformNotificationsScreen(),
    ),
    GoRoute(
      path: RoutePaths.platformAutomationTemplates,
      builder: (context, state) =>
          ResourceListScreen(spec: platformAutomationTemplateSpec),
    ),
    GoRoute(
      path: RoutePaths.platformCreateAutomationTemplate,
      builder: (context, state) =>
          _resourceForm(platformAutomationTemplateSpec, state),
    ),
    GoRoute(
      path: '/platform/automation-templates/:id/edit',
      builder: (context, state) => _resourceForm(
        platformAutomationTemplateSpec,
        state,
        id: _idOf(state),
      ),
    ),
    GoRoute(
      path: '/platform/automation-templates/:id',
      builder: (context, state) => _resourceDetail(
        platformAutomationTemplateSpec,
        state,
        _idOf(state),
      ),
    ),

    /*
     * The public experience. Readable with or without a session. Four primary
     * tabs share the bottom navigation; long-form pages stand alone so they can
     * scroll without a persistent bar.
     */
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          PublicShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const PublicHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.publicFeatures,
              builder: (context, state) => const PublicFeaturesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.publicPricing,
              builder: (context, state) => const PublicPricingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.publicAbout,
              builder: (context, state) => const PublicAboutScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.publicHowItWorks,
      builder: (context, state) => const PublicHowItWorksScreen(),
    ),
    GoRoute(
      path: RoutePaths.publicFaq,
      builder: (context, state) => const PublicFaqScreen(),
    ),
    GoRoute(
      path: RoutePaths.publicBlog,
      builder: (context, state) => const PublicBlogScreen(),
    ),
    GoRoute(
      path: '/blog/:slug',
      builder: (context, state) => PublicBlogArticleScreen(
        slug: state.pathParameters['slug'] ?? '',
      ),
    ),
    GoRoute(
      path: RoutePaths.publicContact,
      builder: (context, state) => const PublicContactScreen(),
    ),
    GoRoute(
      path: RoutePaths.waitlist,
      builder: (context, state) => const PublicWaitlistScreen(),
    ),
    GoRoute(
      path: RoutePaths.publicPage(':key'),
      builder: (context, state) => PublicContentPageScreen(
        pageKey: state.pathParameters['key'] ?? '',
      ),
    ),

    /*
     * Legacy marketing links. The merchant overflow menu and older shop links
     * still point at the legacy site paths, so redirect them instead of
     * breaking the link.
     */
    GoRoute(
      path: RoutePaths.site,
      redirect: (context, state) => RoutePaths.home,
    ),
    GoRoute(
      path: RoutePaths.siteFeatures,
      redirect: (context, state) => RoutePaths.publicFeatures,
    ),
    GoRoute(
      path: RoutePaths.sitePricing,
      redirect: (context, state) => RoutePaths.publicPricing,
    ),
    GoRoute(
      path: RoutePaths.siteFaq,
      redirect: (context, state) => RoutePaths.publicFaq,
    ),
    GoRoute(
      path: RoutePaths.siteNewsletter,
      redirect: (context, state) => RoutePaths.publicBlog,
    ),
    GoRoute(
      path: RoutePaths.siteContact,
      redirect: (context, state) => RoutePaths.publicContact,
    ),
    GoRoute(
      path: RoutePaths.siteWaitlist,
      redirect: (context, state) => RoutePaths.waitlist,
    ),
    GoRoute(
      path: '/site/page/:key',
      redirect: (context, state) =>
          RoutePaths.publicPage(state.pathParameters['key'] ?? ''),
    ),
    GoRoute(
      path: '/site/newsletter/:slug',
      redirect: (context, state) =>
          RoutePaths.publicArticle(state.pathParameters['slug'] ?? ''),
    ),

    /*
     * Public storefronts. `/shop` without a store has no public directory to
     * read, so it explains how a shop link is shaped instead of guessing one.
     */
    GoRoute(
      path: RoutePaths.shop,
      builder: (context, state) => const ShopLandingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShopShell(
        shop: ShopRef(
          state.pathParameters['tenant'] ?? '',
          state.pathParameters['store'] ?? '',
        ),
        location: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/shop/:tenant/:store',
          builder: (context, state) => ShopHomeScreen(
            shop: ShopRef(
              state.pathParameters['tenant'] ?? '',
              state.pathParameters['store'] ?? '',
            ),
          ),
        ),
        GoRoute(
          path: '/shop/:tenant/:store/cart',
          builder: (context, state) => ShopCartScreen(
            shop: ShopRef(
              state.pathParameters['tenant'] ?? '',
              state.pathParameters['store'] ?? '',
            ),
          ),
        ),
        GoRoute(
          path: '/shop/:tenant/:store/track',
          builder: (context, state) => ShopTrackScreen(
            shop: ShopRef(
              state.pathParameters['tenant'] ?? '',
              state.pathParameters['store'] ?? '',
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/shop/:tenant/:store/checkout',
      builder: (context, state) => ShopCheckoutScreen(
        shop: ShopRef(
          state.pathParameters['tenant'] ?? '',
          state.pathParameters['store'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/shop/:tenant/:store/p/:slug',
      builder: (context, state) => ShopProductScreen(
        shop: ShopRef(
          state.pathParameters['tenant'] ?? '',
          state.pathParameters['store'] ?? '',
        ),
        slug: state.pathParameters['slug'] ?? '',
      ),
    ),
    GoRoute(
      path: '/shop/:tenant/:store/order/:token',
      builder: (context, state) => ShopOrderScreen(
        shop: ShopRef(
          state.pathParameters['tenant'] ?? '',
          state.pathParameters['store'] ?? '',
        ),
        token: state.pathParameters['token'] ?? '',
      ),
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
