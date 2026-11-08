/// Every path the mobile client uses, relative to `/api/v1`.
///
/// Keeping them in one file makes an endpoint audit a single read, and makes a
/// backend rename a compile-time-visible change rather than a runtime 404.
class ApiPaths {
  const ApiPaths._();

  // Auth & boot
  static const login = '/auth/login';
  static const logout = '/auth/logout';
  static const me = '/me';
  static const permissions = '/permissions';
  static const currencyCatalogue = '/currencies';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const emailVerificationNotification =
      '/auth/email/verification-notification';
  static const onboardingTenant = '/onboarding/tenant';

  // Profile
  static const profile = '/profile';
  static const profileAvatar = '/profile/avatar';
  static const profilePassword = '/profile/password';
  static const profileSessions = '/profile/sessions';
  static String profileSession(String token) => '/profile/sessions/$token';
  static const profileNotifications = '/profile/notifications';
  static const profileNotificationChannels = '/profile/notifications/channels';

  // Notifications
  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';
  static const notificationsReadAll = '/notifications/read-all';

  // Tenant
  static const dashboard = '/tenant/dashboard';
  static const dashboardRevenue = '/tenant/dashboard/revenue';
  static const dashboardTopProducts = '/tenant/dashboard/top-products';
  static const dashboardDeadStock = '/tenant/dashboard/dead-stock';
  static const analytics = '/tenant/analytics';

  static const stores = '/tenant/stores';
  static const workspaceSettings = '/tenant/settings';

  // Store-scoped storefront, delivery and payment configuration.
  static String storeStorefront(int storeId) =>
      '/tenant/stores/$storeId/storefront';
  static String storeShippingZones(int storeId) =>
      '/tenant/stores/$storeId/shipping-zones';
  static String storeShippingZone(int storeId, int zoneId) =>
      '/tenant/stores/$storeId/shipping-zones/$zoneId';
  static String storePayments(int storeId) =>
      '/tenant/stores/$storeId/payments';

  static const categories = '/tenant/categories';
  static const categoryTree = '/tenant/categories/tree';
  static const categorySlugAvailability =
      '/tenant/categories/slug-availability';

  static const products = '/tenant/products';
  static const productSlugAvailability = '/tenant/products/slug-availability';

  static String product(String slug) => '/tenant/products/$slug';

  static const orders = '/tenant/orders';
  static String order(String orderNumber) => '/tenant/orders/$orderNumber';
  static String orderById(int id) => '/tenant/orders/$id';
  static String orderTransitions(int id) => '/tenant/orders/$id/transitions';
  static String orderTransition(int id) => '/tenant/orders/$id/transition';

  static const customers = '/tenant/customers';
  static String customer(int id) => '/tenant/customers/$id';

  static const inventory = '/tenant/inventory';
  static const inventoryLowStock = '/tenant/inventory/low-stock';
  static const inventoryAdjust = '/tenant/inventory/adjust';
  static const inventoryReceive = '/tenant/inventory/receive';
  static String inventoryMovements(int inventoryId) =>
      '/tenant/inventory/$inventoryId/movements';

  static const conversations = '/tenant/conversations';
  static const conversationsSummary = '/tenant/conversations/summary';
  static const conversationsAssignees = '/tenant/conversations/assignees';
  static String conversation(int id) => '/tenant/conversations/$id';
  static String conversationMessages(int id) =>
      '/tenant/conversations/$id/messages';
  static String conversationNotes(int id) => '/tenant/conversations/$id/notes';
  static String conversationTemplates(int id) =>
      '/tenant/conversations/$id/templates';
  static String conversationRead(int id) => '/tenant/conversations/$id/read';
  static String conversationAssign(int id) =>
      '/tenant/conversations/$id/assign';

  // Platform administration (no tenant context).
  static const platformDashboard = '/platform/dashboard';
  static const platformTenants = '/platform/tenants';
  static String platformTenant(int id) => '/platform/tenants/$id';
  static String platformTenantMembers(int id) =>
      '/platform/tenants/$id/members';
  static String platformTenantSuspend(int id) =>
      '/platform/tenants/$id/suspend';
  static String platformTenantActivate(int id) =>
      '/platform/tenants/$id/activate';

  static const platformUsers = '/platform/users';
  static String platformUser(int id) => '/platform/users/$id';
  static String platformUserRole(int userId, int roleId) =>
      '/platform/users/$userId/roles/$roleId';

  static const platformRoles = '/platform/roles';
  static String platformRole(int id) => '/platform/roles/$id';
  static String platformRolePermissions(int id) =>
      '/platform/roles/$id/permissions';

  static const platformAuditLogs = '/platform/audit-logs';
  static const platformAuditActions = '/platform/audit-logs/actions';
  static String platformAuditLog(int id) => '/platform/audit-logs/$id';

  static const platformPricingPlans = '/platform/pricing-plans';
  static String platformPricingPlan(int id) => '/platform/pricing-plans/$id';

  static const platformFaqEntries = '/platform/faq-entries';
  static String platformFaqEntry(int id) => '/platform/faq-entries/$id';

  static const platformContentPages = '/platform/content-pages';
  static String platformContentPage(int id) => '/platform/content-pages/$id';

  static const platformWaitlist = '/platform/waitlist-entries';
  static String platformWaitlistEntry(int id) =>
      '/platform/waitlist-entries/$id';

  static const platformContactMessages = '/platform/contact-messages';
  static String platformContactMessage(int id) =>
      '/platform/contact-messages/$id';

  static const platformNewsletterSubscribers =
      '/platform/newsletter-subscribers';
  static String platformNewsletterSubscriber(int id) =>
      '/platform/newsletter-subscribers/$id';

  static const platformNewsletters = '/platform/newsletters';
  static const platformNewsletterSlugAvailability =
      '/platform/newsletters/slug-availability';
  static const platformNewsletterContentImages =
      '/platform/newsletters/content-images';
  static String platformNewsletter(int id) => '/platform/newsletters/$id';

  static const platformAiAvailability = '/platform/ai/availability';
  static const platformAiInsights = '/platform/ai/insights';
  static const platformAiNewsletterContent = '/platform/ai/newsletter-content';

  // Tenant team, roles and audit.
  static const users = '/tenant/users';
  static String user(int id) => '/tenant/users/$id';
  static const roles = '/tenant/roles';
  static String role(int id) => '/tenant/roles/$id';
  static String rolePermissions(int id) => '/tenant/roles/$id/permissions';
  static String roleAssign(int id) => '/tenant/roles/$id/assign';
  static String roleRevoke(int id) => '/tenant/roles/$id/revoke';
  static const auditLogs = '/tenant/audit-logs';
  static const auditActions = '/tenant/audit-logs/actions';
  static String auditLog(int id) => '/tenant/audit-logs/$id';

  // Catalogue extras.
  static String productImages(String slug) => '/tenant/products/$slug/images';
  static String productImagesReorder(String slug) =>
      '/tenant/products/$slug/images/reorder';
  static String productImage(String slug, int id) =>
      '/tenant/products/$slug/images/$id';

  static const bundles = '/tenant/bundles';
  static const bundleRecommendations = '/tenant/bundles/recommendations';
  static const bundleExplain = '/tenant/bundles/recommendations/explain';
  static String bundle(int id) => '/tenant/bundles/$id';
  static String bundlePreview(int id) => '/tenant/bundles/$id/preview';

  // Inventory intelligence and transfers.
  static const inventoryIntelligence = '/tenant/inventory/intelligence';
  static const inventoryIntelligenceExport =
      '/tenant/inventory/intelligence/export';
  static String inventoryIntelligenceItem(int id) =>
      '/tenant/inventory/$id/intelligence';
  static const inventoryTransfers = '/tenant/inventory/transfers';

  // Customer CRM.
  static String customerCrmOverview(int id) =>
      '/tenant/customers/$id/crm/overview';
  static String customerCrmTimeline(int id) =>
      '/tenant/customers/$id/crm/timeline';
  static String customerCrmSummary(int id) =>
      '/tenant/customers/$id/crm/summary';
  static String customerCrmSummaryRefresh(int id) =>
      '/tenant/customers/$id/crm/summary/refresh';
  static String customerMemories(int id) => '/tenant/customers/$id/memories';
  static String customerMemory(int id, int memoryId) =>
      '/tenant/customers/$id/memories/$memoryId';

  // Lost-sale recovery.
  static const recoverySummary = '/tenant/recovery-opportunities/summary';
  static const recoveryOpportunities = '/tenant/recovery-opportunities';
  static String recoveryOpportunity(int id) =>
      '/tenant/recovery-opportunities/$id';
  static String recoveryAiDraft(int id) =>
      '/tenant/recovery-opportunities/$id/ai-draft';
  static String recoveryContact(int id) =>
      '/tenant/recovery-opportunities/$id/contact';
  static String recoveryAssign(int id) =>
      '/tenant/recovery-opportunities/$id/assign';
  static String recoverySnooze(int id) =>
      '/tenant/recovery-opportunities/$id/snooze';
  static String recoveryDismiss(int id) =>
      '/tenant/recovery-opportunities/$id/dismiss';
  static String recoveryDoNotContact(int id) =>
      '/tenant/recovery-opportunities/$id/do-not-contact';

  // WhatsApp channel accounts.
  static const whatsappAccounts = '/tenant/whatsapp-accounts';
  static const whatsappConfiguration =
      '/tenant/whatsapp-accounts/configuration';
  static String whatsappAccount(int id) => '/tenant/whatsapp-accounts/$id';
  static String whatsappVerify(int id) =>
      '/tenant/whatsapp-accounts/$id/verify';
  static String whatsappDisconnect(int id) =>
      '/tenant/whatsapp-accounts/$id/disconnect';

  // Reporting.
  static const profit = '/tenant/profit';
  static const profitExport = '/tenant/profit/export';

  // AI assistance and human-approved actions.
  static const aiAvailability = '/tenant/ai/availability';
  static const aiInsights = '/tenant/ai/insights';
  static const aiMerchantCopilot = '/tenant/ai/merchant-copilot';
  static const aiActionTypes = '/tenant/ai/action-types';
  static const aiActions = '/tenant/ai/actions';
  static String aiAction(int id) => '/tenant/ai/actions/$id';
  static String aiActionSubmit(int id) => '/tenant/ai/actions/$id/submit';
  static String aiActionApprove(int id) => '/tenant/ai/actions/$id/approve';
  static String aiActionReject(int id) => '/tenant/ai/actions/$id/reject';
  static String aiActionExecute(int id) => '/tenant/ai/actions/$id/execute';

  // Automation rules, runs and the human task queue.
  static const automationMeta = '/tenant/automation/meta';
  static const automationRules = '/tenant/automation/rules';
  static String automationRule(int id) => '/tenant/automation/rules/$id';
  static const automationRuns = '/tenant/automation/runs';
  static String automationRun(int id) => '/tenant/automation/runs/$id';
  static const automationTasks = '/tenant/automation/tasks';
  static String automationTask(int id) => '/tenant/automation/tasks/$id';

  // Store currency conversion.
  static const currencies = '/tenant/currencies';
  static String storeCurrency(int storeId) =>
      '/tenant/stores/$storeId/currency';
  static String storeCurrencyPreview(int storeId) =>
      '/tenant/stores/$storeId/currency/preview';

  // Public marketing.
  static const publicFeatures = '/public/features';
  static const publicPricing = '/public/pricing';
  static const publicFaq = '/public/faq';
  static String publicPage(String key) => '/public/pages/$key';
  static const publicNewsletters = '/public/newsletters';
  static String publicNewsletter(String slug) => '/public/newsletters/$slug';
  static const publicWaitlist = '/public/waitlist';
  static const publicContact = '/public/contact';
  static const publicNewsletterSubscribe = '/public/newsletter/subscribe';
  static const publicNewsletterUnsubscribe = '/public/newsletter/unsubscribe';

  // Public storefront.
  static String publicStorefront(String tenantSlug, String storeSlug) =>
      '/public/storefront/$tenantSlug/$storeSlug';
  static String publicStorefrontCategories(String tenant, String store) =>
      '/public/storefront/$tenant/$store/categories';
  static String publicStorefrontProducts(String tenant, String store) =>
      '/public/storefront/$tenant/$store/products';
  static String publicStorefrontProduct(
          String tenant, String store, String slug) =>
      '/public/storefront/$tenant/$store/products/$slug';
  static String publicStorefrontShipping(String tenant, String store) =>
      '/public/storefront/$tenant/$store/shipping-zones';
  static String publicStorefrontPayments(String tenant, String store) =>
      '/public/storefront/$tenant/$store/payment-methods';
  static String publicStorefrontCheckout(String tenant, String store) =>
      '/public/storefront/$tenant/$store/checkout';
  static String publicStorefrontOrder(
          String tenant, String store, String token) =>
      '/public/storefront/$tenant/$store/orders/$token';
}
