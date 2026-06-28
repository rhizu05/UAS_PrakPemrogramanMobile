import 'package:uas_prakpemrogramanmobile/core/constants/api_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/api_service.dart';
import 'package:uas_prakpemrogramanmobile/models/dashboard_stats_model.dart';
import 'package:uas_prakpemrogramanmobile/models/top_product_model.dart';
import 'package:uas_prakpemrogramanmobile/models/order_model.dart';

class AdminService {
  // Fetch dashboard statistics
  Future<DashboardStatsModel> fetchDashboardStats() async {
    final response = await ApiService.get(
      ApiConstants.adminStats,
      requireAuth: true,
    );
    return DashboardStatsModel.fromJson(response['data']);
  }

  // Fetch top selling products
  Future<List<TopProductModel>> fetchTopProducts() async {
    final response = await ApiService.get(
      ApiConstants.adminTopProducts,
      requireAuth: true,
    );
    final List<dynamic> productsData = response['data'] ?? [];
    return productsData.map((json) => TopProductModel.fromJson(json)).toList();
  }

  // Fetch all customer orders (with optional status filter and pagination)
  Future<Map<String, dynamic>> fetchAllOrders({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status;
    }

    final response = await ApiService.get(
      ApiConstants.adminOrders,
      requireAuth: true,
      queryParams: queryParams,
    );

    final List<dynamic> ordersData = response['data'] ?? [];
    final orders = ordersData.map((json) => OrderModel.fromJson(json)).toList();

    final pagination = response['pagination'] ?? {};

    return {
      'orders': orders,
      'page': pagination['page'] ?? page,
      'totalPages': pagination['totalPages'] ?? 1,
      'total': pagination['total'] ?? orders.length,
    };
  }

  // Update specific order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await ApiService.put(
      ApiConstants.updateOrderStatus(orderId),
      body: {
        'status': newStatus,
      },
      requireAuth: true,
    );
  }
}
