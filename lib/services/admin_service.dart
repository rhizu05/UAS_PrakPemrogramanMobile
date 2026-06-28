import 'package:uas_prakpemrogramanmobile/core/constants/api_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/api_service.dart';
import 'package:uas_prakpemrogramanmobile/models/dashboard_stats_model.dart';
import 'package:uas_prakpemrogramanmobile/models/top_product_model.dart';
import 'package:uas_prakpemrogramanmobile/models/order_model.dart';

class AdminService {
  Future<DashboardStatsModel> fetchDashboardStats() async {
    final response = await ApiService.get(
      ApiConstants.adminStats,
      requireAuth: true,
    );
    
    Map<String, dynamic> data = {};
    if (response != null && response['data'] is Map) {
      data = response['data'] as Map<String, dynamic>;
    } else if (response is Map<String, dynamic>) {
      data = response;
    }
    
    return DashboardStatsModel.fromJson(data);
  }

  // Fetch top selling products
  Future<List<TopProductModel>> fetchTopProducts() async {
    final response = await ApiService.get(
      ApiConstants.adminTopProducts,
      requireAuth: true,
    );
    
    List<dynamic> productsData = [];
    if (response['data'] is List) {
      productsData = response['data'];
    } else if (response['data'] is Map) {
      // If it's a Map, try to find a list inside it
      final mapData = response['data'] as Map;
      for (var value in mapData.values) {
        if (value is List) {
          productsData = value;
          break;
        }
      }
      // Or maybe it's directly the Map's values if the map is just { "0": {...}, "1": {...} }?
      if (productsData.isEmpty) {
         productsData = mapData.values.toList();
      }
    } else if (response is List) {
      productsData = response;
    }

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
