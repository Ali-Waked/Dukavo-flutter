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
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
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
  static const categorySlugAvailability = '/tenant/categories/slug-availability';

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
  static String conversationAssign(int id) => '/tenant/conversations/$id/assign';
}
