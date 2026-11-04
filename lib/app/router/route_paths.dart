/// Every navigable location in the app, in one place.
///
/// Detail routes take the identifier the API actually addresses the resource
/// by: products use their slug, orders use their order number, customers and
/// conversations use their numeric id.
class RoutePaths {
  const RoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
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
  static const analytics = '/analytics';
  static const storefront = '/storefront';
  static const shippingZones = '/shipping-zones';
  static const paymentSettings = '/payments';
  static const profile = '/profile';
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
  static const aiActions = '/ai-actions';
  static const automations = '/automations';
  static const createAutomation = '/automations/new';
  static const automationRules = '/automations/rules';
  static const automationRuns = '/automations/runs';
  static const automationTasks = '/automations/tasks';
  static const recovery = '/recovery';
  static const profit = '/profit';
  static const stores = '/stores';
  static const createStore = '/stores/new';
  static const inventoryIntelligence = '/inventory/intelligence';

  // Public marketing site.
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
  static String storeEdit(int id) => '/stores/$id/edit';
  static String productImages(String slug) => '/products/$slug/images';

  static String sitePage(String key) => '/site/page/$key';
  static String siteNewsletterArticle(String slug) => '/site/newsletter/$slug';

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
  static String customer(int id) => '/customers/$id';
  static String customerEdit(int id) => '/customers/$id/edit';
  static String conversation(int id) => '/conversations/$id';
}
