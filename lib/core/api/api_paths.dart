/// Every path the mobile client uses, relative to `/api/v1`.
///
/// Keeping them in one file makes an endpoint audit a single read, and makes a
/// backend rename a compile-time-visible change rather than a runtime 404.
class ApiPaths {
  const ApiPaths._();

  // Auth & boot
  static const login = '/auth/login';
  static const twoFactorChallenge = '/auth/two-factor-challenge';
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
  static const profileOverview = '/profile/overview';
  static const profileOnboarding = '/profile/onboarding';
  static const profileOnboardingSkip = '/profile/onboarding/skip';
  static const profileCountries = '/profile/locations/countries';
  static String profileCities(String iso2) =>
      '/profile/locations/countries/$iso2/cities';
  static const profileTimezones = '/profile/locations/timezones';
  static const profileSecurityActivity = '/profile/security/activity';
  static const profileTwoFactor = '/profile/two-factor';
  static const profileTwoFactorSetup = '/profile/two-factor/setup';
  static const profileTwoFactorConfirm = '/profile/two-factor/confirm';
  static const profileTwoFactorRecoveryCodes =
      '/profile/two-factor/recovery-codes';
  static const profileAvatar = '/profile/avatar';
  static const profilePassword = '/profile/password';
  static const profileSessions = '/profile/sessions';
  static String profileSession(String token) => '/profile/sessions/$token';
  static const profileNotifications = '/profile/notifications';
  static const profileNotificationChannels = '/profile/notifications/channels';

  // Push installations owned by the signed-in account.
  static const profileDevices = '/profile/devices';
  static const profileDevicesUnregister = '/profile/devices/unregister';
  static String profileDevice(int id) => '/profile/devices/$id';

  // Notifications
  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';
  static const notificationsReadAll = '/notifications/read-all';
  static String notification(String id) => '/notifications/$id';

  // Help Center, readable by every signed-in account and widened to the
  // reader's tier: merchants also see merchant-only guides, platform
  // operators see everything.
  static const helpCategories = '/help/categories';
  static const helpArticles = '/help/articles';
  static String helpArticle(String slug) => '/help/articles/$slug';
  static const helpSearch = '/help/search';
  static String helpArticleFeedback(String slug) =>
      '/help/articles/$slug/feedback';

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

  // Platform AI infrastructure administration. Credentials are write-only and
  // every read is masked by the server.
  static const platformAiAdminOverview = '/platform/ai/admin/overview';
  static const platformAiAdminSettings = '/platform/ai/admin/settings';
  static const platformAiAdminUsage = '/platform/ai/admin/usage';
  static const platformAiAdminActivity = '/platform/ai/admin/activity-logs';
  static const platformAiAdminActivityCategories =
      '/platform/ai/admin/activity-logs/categories';
  static const platformAiAdminProviders = '/platform/ai/admin/providers';
  static const platformAiAdminProviderCatalog =
      '/platform/ai/admin/providers/catalog';
  static String platformAiAdminProvider(int id) =>
      '/platform/ai/admin/providers/$id';
  static String platformAiAdminProviderCredentials(int id) =>
      '/platform/ai/admin/providers/$id/credentials';
  static String platformAiAdminProviderCredential(int providerId, int id) =>
      '/platform/ai/admin/providers/$providerId/credentials/$id';
  static String platformAiAdminProviderModels(int id) =>
      '/platform/ai/admin/providers/$id/models';
  static String platformAiAdminProviderTest(int id) =>
      '/platform/ai/admin/providers/$id/test-connection';
  static const platformAiAdminTasks = '/platform/ai/admin/tasks';
  static const platformAiAdminTasksSeed = '/platform/ai/admin/tasks/seed';
  static String platformAiAdminTask(int id) => '/platform/ai/admin/tasks/$id';
  static String platformAiAdminTaskRoutes(int id) =>
      '/platform/ai/admin/tasks/$id/routes';
  static const platformAiAdminPrompts = '/platform/ai/admin/prompts';
  static String platformAiAdminPrompt(int id) =>
      '/platform/ai/admin/prompts/$id';
  static String platformAiAdminPromptVersions(int id) =>
      '/platform/ai/admin/prompts/$id/versions';
  static String platformAiAdminPromptVersionActivate(int id, int version) =>
      '/platform/ai/admin/prompts/$id/versions/$version/activate';
  static String platformAiAdminModel(int id) => '/platform/ai/admin/models/$id';

  // Platform payment catalogue administration.
  static const platformPaymentCountries = '/platform/payments/countries';
  static String platformPaymentCountry(String code) =>
      '/platform/payments/countries/$code';
  static const platformPaymentProviders = '/platform/payments/providers';
  static String platformPaymentProvider(String code) =>
      '/platform/payments/providers/$code';
  static String platformPaymentProviderCountries(String code) =>
      '/platform/payments/providers/$code/countries';
  static String platformPaymentProviderCountry(String code, int coverage) =>
      '/platform/payments/providers/$code/countries/$coverage';
  static String platformPaymentProviderMethods(String code) =>
      '/platform/payments/providers/$code/methods';
  static String platformPaymentProviderMethod(String code, int method) =>
      '/platform/payments/providers/$code/methods/$method';
  static const platformPaymentMethods = '/platform/payments/methods';
  static String platformPaymentMethod(int id) =>
      '/platform/payments/methods/$id';
  static const platformPaymentWebhookEvents =
      '/platform/payments/webhook-events';
  static String platformPaymentWebhookEvent(int id) =>
      '/platform/payments/webhook-events/$id';

  // Platform omnichannel integration health.
  static const platformIntegrations = '/platform/integrations';
  static String platformIntegration(String channel) =>
      '/platform/integrations/$channel';
  static String platformIntegrationRecheck(String channel) =>
      '/platform/integrations/$channel/recheck';

  // Platform notifications: campaigns, email templates and delivery attempts.
  static const platformNotificationCampaigns =
      '/platform/notification-campaigns';
  static String platformNotificationCampaign(int id) =>
      '/platform/notification-campaigns/$id';
  static String platformNotificationCampaignSchedule(int id) =>
      '/platform/notification-campaigns/$id/schedule';
  static String platformNotificationCampaignPublish(int id) =>
      '/platform/notification-campaigns/$id/publish';
  static String platformNotificationCampaignCancel(int id) =>
      '/platform/notification-campaigns/$id/cancel';
  static String platformNotificationCampaignRecipients(int id) =>
      '/platform/notification-campaigns/$id/recipients';
  static String platformNotificationCampaignStats(int id) =>
      '/platform/notification-campaigns/$id/stats';
  static const platformNotificationCampaignPreview =
      '/platform/notification-campaigns/preview';
  static const platformNotificationCampaignAudience =
      '/platform/notification-campaigns/audience-count';
  static const platformEmailTemplates = '/platform/email-templates';
  static String platformEmailTemplate(String key) =>
      '/platform/email-templates/$key';
  static String platformEmailTemplateRestore(String key) =>
      '/platform/email-templates/$key/restore';
  static String platformEmailTemplatePreview(String key) =>
      '/platform/email-templates/$key/preview';
  static String platformEmailTemplateTest(String key) =>
      '/platform/email-templates/$key/test';
  static const platformNotificationDeliveries =
      '/platform/notification-deliveries';
  static String platformNotificationDelivery(int id) =>
      '/platform/notification-deliveries/$id';
  static String platformNotificationDeliveryRetry(int id) =>
      '/platform/notification-deliveries/$id/retry';

  // Platform automation templates.
  static const platformAutomationTemplates = '/platform/automation-templates';
  static const platformAutomationTemplatesMeta =
      '/platform/automation-templates/meta';
  static String platformAutomationTemplate(int id) =>
      '/platform/automation-templates/$id';
  static String platformAutomationTemplatePublish(int id) =>
      '/platform/automation-templates/$id/publish';
  static String platformAutomationTemplateArchive(int id) =>
      '/platform/automation-templates/$id/archive';
  static String platformAutomationTemplateRestore(int id) =>
      '/platform/automation-templates/$id/restore';
  static String platformAutomationTemplateVersions(int id) =>
      '/platform/automation-templates/$id/versions';

  // Centralised platform configuration. Secrets are never returned: a read
  // carries `configured` and a last-four hint only.
  static const platformSettings = '/platform/settings';
  static const platformSettingsSystem = '/platform/settings/system';
  static const platformSettingsHistory = '/platform/settings/history';
  static const platformSettingsHealth = '/platform/settings/health';
  static const platformSettingsFeatures = '/platform/settings/features';
  static String platformSettingsSection(String category) =>
      '/platform/settings/$category';
  static String platformSettingsFeature(String flag) =>
      '/platform/settings/features/$flag';
  static String platformSettingsHealthCheck(String integration) =>
      '/platform/settings/health/$integration';

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

  // AI translation review. The surface selects the merchant or platform half of
  // the same review ledger; the server resolves the record inside that surface.
  static String translations(String surface) =>
      surface == 'platform' ? '/platform/translations' : '/tenant/translations';
  static String translationEntities(String surface) =>
      '${translations(surface)}/entities';
  static String translationUsage(String surface) =>
      '${translations(surface)}/usage';
  static String translationOverview(
    String surface,
    String entity,
    int id,
  ) =>
      '${translations(surface)}/$entity/$id';
  static String translationGenerate(
    String surface,
    String entity,
    int id,
  ) =>
      '${translations(surface)}/$entity/$id/generate';
  static String translationApproveAll(
    String surface,
    String entity,
    int id,
  ) =>
      '${translations(surface)}/$entity/$id/approve-all';
  static String translation(String surface, int id) =>
      '${translations(surface)}/$id';
  static String translationApprove(String surface, int id) =>
      '${translation(surface, id)}/approve';
  static String translationReject(String surface, int id) =>
      '${translation(surface, id)}/reject';
  static String translationRegenerate(String surface, int id) =>
      '${translation(surface, id)}/regenerate';

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
  static String storePaymentConnections(int storeId) =>
      '/tenant/stores/$storeId/payment-connections';
  static String storePaymentConnection(int storeId, int accountId) =>
      '/tenant/stores/$storeId/payment-connections/$accountId';
  static String storePaymentConnectionVerify(int storeId, int accountId) =>
      '/tenant/stores/$storeId/payment-connections/$accountId/verify';
  static const merchantPayments = '/tenant/payments';
  static String merchantPayment(int id) => '/tenant/payments/$id';
  static String merchantPaymentSync(int id) => '/tenant/payments/$id/sync';
  static String merchantPaymentRefund(int id) =>
      '/tenant/payments/$id/refunds';
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

  // Omnichannel integrations. A credential value never travels back out.
  static const integrations = '/tenant/integrations';
  static String integration(int id) => '/tenant/integrations/$id';
  static String integrationTest(int id) => '/tenant/integrations/$id/test';
  static String integrationReconnect(int id) =>
      '/tenant/integrations/$id/reconnect';

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

  // The workspace's own AI settings: feature switches, BYOK keys and usage.
  static const tenantAiSettings = '/tenant/ai-settings';
  static const tenantAiUsage = '/tenant/ai-settings/usage';
  static const tenantAiCredentials = '/tenant/ai-settings/credentials';
  static const tenantAiCredentialTest = '/tenant/ai-settings/credentials/test';
  static String tenantAiCredential(int id) =>
      '/tenant/ai-settings/credentials/$id';

  // Automation rules, runs and the human task queue.
  static const automationMeta = '/tenant/automation/meta';
  static const automationRules = '/tenant/automation/rules';
  static String automationRule(int id) => '/tenant/automation/rules/$id';
  static const automationRuns = '/tenant/automation/runs';
  static String automationRun(int id) => '/tenant/automation/runs/$id';
  static const automationTasks = '/tenant/automation/tasks';
  static String automationTask(int id) => '/tenant/automation/tasks/$id';
  static const automationTemplates = '/tenant/automation/templates';
  static String automationTemplate(int id) =>
      '/tenant/automation/templates/$id';
  static String automationTemplateInstall(int id) =>
      '/tenant/automation/templates/$id/install';
  static const automationInstallations = '/tenant/automation/installations';
  static String automationInstallation(int id) =>
      '/tenant/automation/installations/$id';
  static String automationInstallationPreview(int id) =>
      '/tenant/automation/installations/$id/update-preview';
  static String automationInstallationApplyUpdate(int id) =>
      '/tenant/automation/installations/$id/apply-update';
  static String automationInstallationEnable(int id) =>
      '/tenant/automation/installations/$id/enable';
  static String automationInstallationDisable(int id) =>
      '/tenant/automation/installations/$id/disable';

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
  static String publicStorefrontOrderPayment(
          String tenant, String store, String token) =>
      '/public/storefront/$tenant/$store/orders/$token/payment';
}
