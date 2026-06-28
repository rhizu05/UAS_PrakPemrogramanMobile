import 'package:uas_prakpemrogramanmobile/core/constants/api_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/api_service.dart';
import 'package:uas_prakpemrogramanmobile/models/order_model.dart';

class OrderService {
  // Fetch user orders with pagination
  Future<Map<String, dynamic>> fetchOrders({
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiService.get(
      ApiConstants.orders,
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

  // Fetch single order detail
  Future<OrderModel> fetchOrderDetail(String orderId) async {
    final response = await ApiService.get(
      ApiConstants.orderDetail(orderId),
      requireAuth: true,
    );
    
    return OrderModel.fromJson(response['data']);
  }

  // Create new order (checkout)
  Future<OrderModel> createOrder({
    required String address,
    required String phone,
    String? notes,
  }) async {
    final Map<String, dynamic> body = {
      'address': address,
      'phone': phone,
    };
    
    if (notes != null && notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }

    final response = await ApiService.post(
      ApiConstants.orders,
      body: body,
      requireAuth: true,
    );

    final data = response['data'] ?? response;
    return OrderModel.fromJson(data);
  }
}
