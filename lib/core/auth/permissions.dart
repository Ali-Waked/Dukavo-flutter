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
  static const usersView = 'users.view';
  static const usersManage = 'users.manage';
  static const rolesView = 'roles.view';
  static const rolesManage = 'roles.manage';
  static const whatsappView = 'whatsapp.view';
  static const whatsappManage = 'whatsapp.manage';
  static const aiUse = 'ai.use';
  static const aiApprove = 'ai.approve';
  static const auditView = 'audit.view';
  static const recoveryView = 'recovery.view';
  static const recoveryManage = 'recovery.manage';
  static const automationView = 'automation.view';
  static const automationManage = 'automation.manage';
  static const profitExport = 'profit.export';
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
  bool get canViewUsers => can(PermissionSlugs.usersView);
  bool get canManageUsers => can(PermissionSlugs.usersManage);
  bool get canViewRoles => can(PermissionSlugs.rolesView);
  bool get canManageRoles => can(PermissionSlugs.rolesManage);
  bool get canUseAi => can(PermissionSlugs.aiUse);
  bool get canApproveAi => can(PermissionSlugs.aiApprove);
  bool get canViewAudit => can(PermissionSlugs.auditView);
  bool get canViewRecovery => can(PermissionSlugs.recoveryView);
  bool get canManageRecovery => can(PermissionSlugs.recoveryManage);
  bool get canViewAutomation => can(PermissionSlugs.automationView);
  bool get canManageAutomation => can(PermissionSlugs.automationManage);
  bool get canViewProfit => can(PermissionSlugs.profitView);
  bool get canExportProfit => can(PermissionSlugs.profitExport);
  bool get canViewWhatsapp => can(PermissionSlugs.whatsappView);
  bool get canManageWhatsapp => can(PermissionSlugs.whatsappManage);
}
