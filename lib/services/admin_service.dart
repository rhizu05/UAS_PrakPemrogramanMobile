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

    final data =
        _extractMapData(_readResponseField(response, 'data')) ??
        _extractMapData(response) ??
        {};

    return DashboardStatsModel.fromJson(data);
  }

  // Fetch top selling products
  Future<List<TopProductModel>> fetchTopProducts() async {
    final response = await ApiService.get(
      ApiConstants.adminTopProducts,
      requireAuth: true,
    );

    final productsData =
        _extractListData(_readResponseField(response, 'data')) ??
        _extractListData(response) ??
        const [];

    return productsData
        .whereType<Map>()
        .map(
          (json) => TopProductModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
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

    final ordersData =
        _extractListData(_readResponseField(response, 'data')) ??
        _extractListData(response) ??
        const [];
    final orders = ordersData
        .whereType<Map>()
        .map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    final pagination =
        _extractMapData(_readResponseField(response, 'pagination')) ??
        _extractMapData(response) ??
        {};

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
      body: {'status': newStatus},
      requireAuth: true,
    );
  }

  Map<String, dynamic>? _extractMapData(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries
            .where((entry) => entry.value != null)
            .map((entry) => MapEntry(entry.key.toString(), entry.value)),
      );
    }
    return null;
  }

  dynamic _readResponseField(dynamic response, String field) {
    if (response is Map) {
      return response[field];
    }
    return null;
  }

  List<dynamic>? _extractListData(dynamic value) {
    if (value is List<dynamic>) {
      return value;
    }
    if (value is Map) {
      final directList = value['products'] ?? value['orders'] ?? value['data'];
      if (directList is List<dynamic>) {
        return directList;
      }
    }
    return null;
  }
}
