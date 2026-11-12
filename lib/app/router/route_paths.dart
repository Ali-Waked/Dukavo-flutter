/// Every navigable location in the app, in one place.
///
/// Detail routes take the identifier the API actually addresses the resource
/// by: products use their slug, orders use their order number, customers and
/// conversations use their numeric id.
class RoutePaths {
  const RoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const verifyEmail = '/verify-email';
  static const setup = '/setup';

  static const dashboard = '/dashboard';
  static const orders = '/orders';
  static const createOrder = '/orders/new';
  static const products = '/products';
  static const createProduct = '/products/new';
  static const categories = '/categories';
  static const customers = '/customers';
  static const createCustomer = '/customers/new';
  static const inventory = '/inventory';
  static const conversations = '/conversations';
  static const notifications = '/notifications';
  static String notificationDetail(String id) =>
      '/notifications/${Uri.encodeComponent(id)}';
  static const analytics = '/analytics';
  static const storefront = '/storefront';
  static const shippingZones = '/shipping-zones';
  static const paymentSettings = '/payments';
  static const support = '/support';
  static const profile = '/profile';
  static const security = '/security';
  static const welcome = '/welcome';
  static const settings = '/settings';
  static const more = '/more';
  static const noAccess = '/no-access';

  // Platform console.
  static const platform = '/platform';
  static const platformDashboard = '/platform/dashboard';
  static const platformTenants = '/platform/tenants';
  static const platformCreateTenant = '/platform/tenants/new';
  static const platformUsers = '/platform/users';
  static const platformCreateUser = '/platform/users/new';
  static const platformRoles = '/platform/roles';
  static const platformCreateRole = '/platform/roles/new';
  static const platformAudit = '/platform/audit';
  static const platformMarketing = '/platform/marketing';
  static const platformPricing = '/platform/pricing';
  static const platformCreatePricing = '/platform/pricing/new';
  static const platformFaq = '/platform/faq';
  static const platformCreateFaq = '/platform/faq/new';
  static const platformContentPages = '/platform/content-pages';
  static const platformWaitlist = '/platform/waitlist';
  static const platformContact = '/platform/contact';
  static const platformSubscribers = '/platform/subscribers';
  static const platformNewsletters = '/platform/newsletters';
  static const platformCreateNewsletter = '/platform/newsletters/new';
  static const platformSettings = '/platform/settings';
  static const platformSettingsFeatures = '/platform/settings/features';
  static const platformSettingsHealth = '/platform/settings/health';
  static const platformSettingsHistory = '/platform/settings/history';
  static const platformSettingsInfrastructure =
      '/platform/settings/infrastructure';
  static String platformSettingsSection(String category) =>
      '/platform/settings/$category';
  static const platformAiAdmin = '/platform/ai';
  static const platformPayments = '/platform/payments';
  static const platformIntegrations = '/platform/integrations';
  static const platformNotifications = '/platform/notifications';
  static const platformAutomationTemplates = '/platform/automation-templates';
  static const platformCreateAutomationTemplate =
      '/platform/automation-templates/new';
  static String platformAutomationTemplate(int id) =>
      '/platform/automation-templates/$id';
  static String platformAutomationTemplateEdit(int id) =>
      '/platform/automation-templates/$id/edit';
  static const platformMore = '/platform/more';

  // Merchant workspace additions.
  static const team = '/team';
  static const teamMembers = '/team/members';
  static const teamRoles = '/team/roles';
  static const createUser = '/team/users/new';
  static const createRole = '/team/roles/new';
  static const audit = '/audit';
  static const bundles = '/bundles';
  static const createBundle = '/bundles/new';
  static const whatsapp = '/whatsapp';
  static const createWhatsapp = '/whatsapp/new';
  static const integrations = '/integrations';
  static const aiActions = '/ai-actions';
  static const aiSettings = '/ai-settings';
  static const automations = '/automations';
  static const createAutomation = '/automations/new';
  static const automationRules = '/automations/rules';
  static const automationRuns = '/automations/runs';
  static const automationTasks = '/automations/tasks';
  static const automationTemplates = '/automations/templates';
  static String automationTemplate(int id) => '/automations/templates/$id';
  static const automationInstallations = '/automations/installations';
  static String automationInstallation(int id) =>
      '/automations/installations/$id';
  static const paymentConnections = '/payments/connections';
  static const paymentHistory = '/payments/history';
  static String paymentDetail(int id) => '/payments/history/$id';
  static const aiCopilot = '/ai/copilot';
  static const aiInsights = '/ai/insights';
  static const inventoryTransfer = '/inventory/transfer';
  static const recovery = '/recovery';
  static const profit = '/profit';
  static const stores = '/stores';
  static const createStore = '/stores/new';
  static const inventoryIntelligence = '/inventory/intelligence';

  // Public marketing experience.
  //
  // These are the canonical public locations. The legacy `/site/*` paths below
  // remain only as redirects so old links and the merchant overflow menu keep
  // working while every new entry point lands on the public route scheme.
  static const home = '/home';
  static const publicFeatures = '/features';
  static const publicPricing = '/pricing';
  static const publicHowItWorks = '/how-it-works';
  static const publicAbout = '/about';
  static const publicFaq = '/faq';
  static const publicBlog = '/blog';
  static const publicContact = '/contact';
  static const waitlist = '/waitlist';

  // Public marketing site (legacy redirects).
  static const site = '/site';
  static const siteFeatures = '/site/features';
  static const sitePricing = '/site/pricing';
  static const siteFaq = '/site/faq';
  static const siteNewsletter = '/site/newsletter';
  static const siteContact = '/site/contact';
  static const siteWaitlist = '/site/waitlist';

  // Public storefront.
  static const shop = '/shop';

  static String platformTenant(int id) => '/platform/tenants/$id';
  static String platformTenantEdit(int id) => '/platform/tenants/$id/edit';
  static String platformUser(int id) => '/platform/users/$id';
  static String platformUserEdit(int id) => '/platform/users/$id/edit';
  static String platformRole(int id) => '/platform/roles/$id';
  static String platformRoleEdit(int id) => '/platform/roles/$id/edit';
  static String platformPricingEdit(int id) => '/platform/pricing/$id/edit';
  static String platformPricingPlan(int id) => '/platform/pricing/$id';
  static String platformFaqEdit(int id) => '/platform/faq/$id/edit';
  static String platformFaqEntry(int id) => '/platform/faq/$id';
  static String platformAuditEntry(int id) => '/platform/audit/$id';
  static String platformContentPage(int id) => '/platform/content-pages/$id';
  static String platformContentPageEdit(int id) =>
      '/platform/content-pages/$id/edit';
  static String platformWaitlistEdit(int id) => '/platform/waitlist/$id/edit';
  static String platformWaitlistEntry(int id) => '/platform/waitlist/$id';
  static String platformContactEdit(int id) => '/platform/contact/$id/edit';
  static String platformContactMessage(int id) => '/platform/contact/$id';
  static String platformSubscriberEdit(int id) =>
      '/platform/subscribers/$id/edit';
  static String platformSubscriber(int id) => '/platform/subscribers/$id';
  static String platformNewsletterEdit(int id) =>
      '/platform/newsletters/$id/edit';
  static String platformNewsletter(int id) => '/platform/newsletters/$id';

  static String userEdit(int id) => '/team/users/$id/edit';
  static String userDetail(int id) => '/team/users/$id';
  static String roleEdit(int id) => '/team/roles/$id/edit';
  static String roleDetail(int id) => '/team/roles/$id';
  static String auditEntry(int id) => '/audit/$id';
  static String bundle(int id) => '/bundles/$id';
  static String bundleEdit(int id) => '/bundles/$id/edit';
  static String whatsappEdit(int id) => '/whatsapp/$id/edit';
  static String whatsappAccount(int id) => '/whatsapp/$id';
  static String aiAction(int id) => '/ai-actions/$id';
  static String automationEdit(int id) => '/automations/$id/edit';
  static String automationRule(int id) => '/automations/rules/$id';
  static String automationRun(int id) => '/automations/runs/$id';
  static String automationTask(int id) => '/automations/tasks/$id';
  static String recoveryDetail(int id) => '/recovery/$id';
  static String storeDetail(int id) => '/stores/$id';
  static String storeCurrency(int id) => '/stores/$id/currency';
  static String storeEdit(int id) => '/stores/$id/edit';
  static String productImages(String slug) => '/products/$slug/images';

  static String sitePage(String key) => '/site/page/$key';
  static String siteNewsletterArticle(String slug) => '/site/newsletter/$slug';

  static String publicPage(String key) => '/pages/$key';
  static String publicArticle(String slug) => '/blog/$slug';

  static String shopStore(String tenant, String store) =>
      '/shop/$tenant/$store';
  static String shopProduct(String tenant, String store, String slug) =>
      '/shop/$tenant/$store/p/$slug';
  static String shopCart(String tenant, String store) =>
      '/shop/$tenant/$store/cart';
  static String shopCheckout(String tenant, String store) =>
      '/shop/$tenant/$store/checkout';
  static String shopOrder(String tenant, String store, String token) =>
      '/shop/$tenant/$store/order/$token';
  static String shopTrack(String tenant, String store) =>
      '/shop/$tenant/$store/track';

  static String order(String orderNumber) => '/orders/$orderNumber';
  static String product(String slug) => '/products/$slug';
  static String productEdit(String slug) => '/products/$slug/edit';
  static String supportCategory(String slug) => '/support/categories/$slug';
  static String supportArticle(String slug) => '/support/articles/$slug';
  static String translationAssistant({
    required String surface,
    required String entity,
    required int id,
  }) =>
      '/translations/$surface/$entity/$id';
  static String customer(int id) => '/customers/$id';
  static String customerEdit(int id) => '/customers/$id/edit';
  static String customerCrm(int id) => '/customers/$id/crm';
  static String conversation(int id) => '/conversations/$id';
}
