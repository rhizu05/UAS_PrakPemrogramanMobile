class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';

  // Categories
  static const String categories = '/categories';

  // Products
  static const String products = '/products';
  static String productDetail(String id) => '/products/$id';

  // Cart
  static const String cart = '/cart';
  static String cartItem(String id) => '/cart/$id';

  // Orders
  static const String orders = '/orders';
  static String orderDetail(String id) => '/orders/$id';
  static const String adminOrders = '/orders/admin/all';
  static String updateOrderStatus(String id) => '/orders/$id/status';

  // Reviews
  static String productReviews(String productId) =>
      '/reviews/product/$productId';
  static String reviewDetail(String id) => '/reviews/$id';

  // Admin Dashboard
  static const String adminStats = '/dashboard/stats';
  static const String adminTopProducts = '/dashboard/top-products';
}
