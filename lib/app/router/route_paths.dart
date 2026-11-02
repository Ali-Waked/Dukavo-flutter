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

  static String order(String orderNumber) => '/orders/$orderNumber';
  static String product(String slug) => '/products/$slug';
  static String productEdit(String slug) => '/products/$slug/edit';
  static String customer(int id) => '/customers/$id';
  static String customerEdit(int id) => '/customers/$id/edit';
  static String conversation(int id) => '/conversations/$id';
}
