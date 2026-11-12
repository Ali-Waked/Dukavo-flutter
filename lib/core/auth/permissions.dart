/// Permission slugs, mirroring `App\Support\PermissionRegistry` on the server.
///
/// The server is authoritative; this list exists so navigation and buttons can
/// hide what the caller cannot use. A hidden button is a courtesy, never a
/// security boundary.
class PermissionSlugs {
  const PermissionSlugs._();

  static const productsView = 'products.view';
  static const productsCreate = 'products.create';
  static const productsUpdate = 'products.update';
  static const productsDelete = 'products.delete';

  static const categoriesView = 'categories.view';
  static const categoriesManage = 'categories.manage';

  static const inventoryView = 'inventory.view';
  static const inventoryManage = 'inventory.manage';

  static const ordersView = 'orders.view';
  static const ordersCreate = 'orders.create';
  static const ordersUpdate = 'orders.update';
  static const ordersDelete = 'orders.delete';

  static const customersView = 'customers.view';
  static const customersCreate = 'customers.create';
  static const customersUpdate = 'customers.update';
  static const customersDelete = 'customers.delete';

  static const conversationsView = 'conversations.view';
  static const conversationsReply = 'conversations.reply';
  static const conversationsAssign = 'conversations.assign';

  static const dashboardView = 'dashboard.view';
  static const profitView = 'profit.view';
  static const settingsView = 'settings.view';
  static const settingsManage = 'settings.manage';
  static const storesView = 'stores.view';
  static const storesManage = 'stores.manage';
  static const storefrontView = 'storefront.view';
  static const storefrontManage = 'storefront.manage';
  static const shippingView = 'shipping.view';
  static const shippingManage = 'shipping.manage';
  static const paymentsView = 'payments.view';
  static const paymentsManage = 'payments.manage';
  static const paymentsRefund = 'payments.refund';
  static const usersView = 'users.view';
  static const usersManage = 'users.manage';
  static const rolesView = 'roles.view';
  static const rolesManage = 'roles.manage';
  static const whatsappView = 'whatsapp.view';
  static const whatsappManage = 'whatsapp.manage';
  static const integrationsView = 'integrations.view';
  static const integrationsManage = 'integrations.manage';
  static const aiUse = 'ai.use';
  static const aiApprove = 'ai.approve';
  static const aiSettingsView = 'ai_settings.view';
  static const aiSettingsManage = 'ai_settings.manage';
  static const translationsView = 'translations.view';
  static const translationsGenerate = 'translations.generate';
  static const translationsReview = 'translations.review';
  static const auditView = 'audit.view';
  static const recoveryView = 'recovery.view';
  static const recoveryManage = 'recovery.manage';
  static const automationView = 'automation.view';
  static const automationManage = 'automation.manage';
  static const profitExport = 'profit.export';

  static const notificationsView = 'notifications.view';
  static const notificationsManage = 'notifications.manage';

  static const platformPaymentsView = 'platform_payments.view';
  static const platformPaymentsManage = 'platform_payments.manage';
  static const integrationsAdminView = 'integrations_admin.view';
  static const integrationsAdminManage = 'integrations_admin.manage';
  static const aiAdminView = 'ai_admin.view';
  static const aiAdminManage = 'ai_admin.manage';
  static const aiAdminRotate = 'ai_admin.rotate';

  static const platformSettingsView = 'platform_settings.view';
  static const platformSettingsUpdate = 'platform_settings.update';
  static const platformSettingsSecrets = 'platform_settings.secrets';
  static const platformSettingsTest = 'platform_settings.test';
  static const platformFeaturesView = 'platform_features.view';
  static const platformFeaturesManage = 'platform_features.manage';
  static const platformSecurityView = 'platform_security.view';
  static const platformSecurityManage = 'platform_security.manage';
}

/// An immutable view over the permissions returned by `GET /me`.
class Permissions {
  const Permissions(this.values);

  const Permissions.empty() : values = const <String>{};

  final Set<String> values;

  bool can(String slug) => values.contains(slug);

  bool any(Iterable<String> slugs) => slugs.any(can);

  bool get canViewDashboard => can(PermissionSlugs.dashboardView);
  bool get canViewProducts => can(PermissionSlugs.productsView);
  bool get canManageProducts => can(PermissionSlugs.productsUpdate);
  bool get canCreateProducts => can(PermissionSlugs.productsCreate);
  bool get canViewCategories => can(PermissionSlugs.categoriesView);
  bool get canManageCategories => can(PermissionSlugs.categoriesManage);
  bool get canViewOrders => can(PermissionSlugs.ordersView);
  bool get canCreateOrders => can(PermissionSlugs.ordersCreate);
  bool get canUpdateOrders => can(PermissionSlugs.ordersUpdate);
  bool get canViewCustomers => can(PermissionSlugs.customersView);
  bool get canCreateCustomers => can(PermissionSlugs.customersCreate);
  bool get canUpdateCustomers => can(PermissionSlugs.customersUpdate);
  bool get canDeleteCustomers => can(PermissionSlugs.customersDelete);
  bool get canViewInventory => can(PermissionSlugs.inventoryView);
  bool get canManageInventory => can(PermissionSlugs.inventoryManage);
  bool get canViewConversations => can(PermissionSlugs.conversationsView);
  bool get canReplyConversations => can(PermissionSlugs.conversationsReply);
  bool get canAssignConversations => can(PermissionSlugs.conversationsAssign);
  bool get canViewSettings => can(PermissionSlugs.settingsView);
  bool get canManageSettings => can(PermissionSlugs.settingsManage);
  bool get canViewAnalytics => can(PermissionSlugs.dashboardView);
  bool get canViewStores => can(PermissionSlugs.storesView);
  bool get canManageStores => can(PermissionSlugs.storesManage);
  bool get canViewStorefront => can(PermissionSlugs.storefrontView);
  bool get canManageStorefront => can(PermissionSlugs.storefrontManage);
  bool get canViewShipping => can(PermissionSlugs.shippingView);
  bool get canManageShipping => can(PermissionSlugs.shippingManage);
  bool get canViewPayments => can(PermissionSlugs.paymentsView);
  bool get canManagePayments => can(PermissionSlugs.paymentsManage);
  bool get canRefundPayments => can(PermissionSlugs.paymentsRefund);
  bool get canViewUsers => can(PermissionSlugs.usersView);
  bool get canManageUsers => can(PermissionSlugs.usersManage);
  bool get canViewRoles => can(PermissionSlugs.rolesView);
  bool get canManageRoles => can(PermissionSlugs.rolesManage);
  bool get canUseAi => can(PermissionSlugs.aiUse);
  bool get canApproveAi => can(PermissionSlugs.aiApprove);
  bool get canViewAiSettings => can(PermissionSlugs.aiSettingsView);
  bool get canManageAiSettings => can(PermissionSlugs.aiSettingsManage);
  bool get canViewTranslations => can(PermissionSlugs.translationsView);
  bool get canGenerateTranslations => can(PermissionSlugs.translationsGenerate);
  bool get canReviewTranslations => can(PermissionSlugs.translationsReview);
  bool get canViewAudit => can(PermissionSlugs.auditView);
  bool get canViewRecovery => can(PermissionSlugs.recoveryView);
  bool get canManageRecovery => can(PermissionSlugs.recoveryManage);
  bool get canViewAutomation => can(PermissionSlugs.automationView);
  bool get canManageAutomation => can(PermissionSlugs.automationManage);
  bool get canViewProfit => can(PermissionSlugs.profitView);
  bool get canExportProfit => can(PermissionSlugs.profitExport);
  bool get canViewWhatsapp => can(PermissionSlugs.whatsappView);
  bool get canManageWhatsapp => can(PermissionSlugs.whatsappManage);
  bool get canViewIntegrations => can(PermissionSlugs.integrationsView);
  bool get canManageIntegrations => can(PermissionSlugs.integrationsManage);
  bool get canViewNotifications => can(PermissionSlugs.notificationsView);
  bool get canManageNotifications => can(PermissionSlugs.notificationsManage);
  bool get canViewPlatformPayments => can(PermissionSlugs.platformPaymentsView);
  bool get canManagePlatformPayments => can(PermissionSlugs.platformPaymentsManage);
  bool get canViewPlatformIntegrations =>
      can(PermissionSlugs.integrationsAdminView);
  bool get canManagePlatformIntegrations =>
      can(PermissionSlugs.integrationsAdminManage);
  bool get canViewAiAdmin => can(PermissionSlugs.aiAdminView);
  bool get canManageAiAdmin => can(PermissionSlugs.aiAdminManage);
  bool get canRotateAiCredentials => can(PermissionSlugs.aiAdminRotate);

  bool get canViewPlatformSettings =>
      any(const [
        PermissionSlugs.platformSettingsView,
        PermissionSlugs.platformSecurityView,
        PermissionSlugs.platformFeaturesView,
      ]);
  bool get canViewPlatformConfiguration =>
      can(PermissionSlugs.platformSettingsView);
  bool get canManagePlatformSettings =>
      can(PermissionSlugs.platformSettingsUpdate);
  bool get canManagePlatformSecrets =>
      can(PermissionSlugs.platformSettingsSecrets);
  bool get canTestPlatformIntegrations =>
      can(PermissionSlugs.platformSettingsTest);
  bool get canViewPlatformFeatures =>
      any(const [
        PermissionSlugs.platformFeaturesView,
        PermissionSlugs.platformSettingsView,
      ]);
  bool get canManagePlatformFeatures =>
      can(PermissionSlugs.platformFeaturesManage);
  bool get canViewPlatformSecurity =>
      any(const [
        PermissionSlugs.platformSecurityView,
        PermissionSlugs.platformSettingsView,
      ]);
  bool get canManagePlatformSecurity =>
      can(PermissionSlugs.platformSecurityManage);
}
