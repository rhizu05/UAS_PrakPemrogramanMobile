import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/services/storage_service.dart';
import 'package:uas_prakpemrogramanmobile/models/order_model.dart';
import 'package:uas_prakpemrogramanmobile/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  OrderModel? _detailOrder;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingDetail = false;
  bool _isCreatingOrder = false;

  String? _errorMessage;
  String? _errorDetail;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get detailOrder => _detailOrder;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isCreatingOrder => _isCreatingOrder;

  String? get errorMessage => _errorMessage;
  String? get errorDetail => _errorDetail;

  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  // Fetch Orders
  Future<void> fetchOrders({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final result = await _orderService.fetchOrders(
        page: _currentPage,
        limit: 10,
      );

      final List<OrderModel> fetchedOrders = result['orders'];
      
      // Overwrite status with locally updated status if it exists in SharedPreferences
      try {
        final listJson = StorageService.getString('local_checkout_orders') ?? '[]';
        final List<dynamic> decoded = jsonDecode(listJson);
        final localMap = {for (var item in decoded) item['id'] as String: item['status'] as String};
        for (var i = 0; i < fetchedOrders.length; i++) {
          final localStatus = localMap[fetchedOrders[i].id];
          if (localStatus != null) {
            final old = fetchedOrders[i];
            fetchedOrders[i] = OrderModel(
              id: old.id,
              status: localStatus,
              total: old.total,
              shippingAddress: old.shippingAddress,
              note: old.note,
              createdAt: old.createdAt,
              items: old.items,
              customerName: old.customerName,
              customerEmail: old.customerEmail,
            );
          }
        }
      } catch (_) {}

      _currentPage = result['page'] + 1;
      _totalPages = result['totalPages'];
      _hasMore = result['page'] < _totalPages;

      if (refresh) {
        _orders = fetchedOrders;
      } else {
        _orders.addAll(fetchedOrders);
      }

      _errorMessage = null;
    } catch (e) {
      if (refresh) {
        _orders = [];
        _errorMessage = e.toString();
      }
    } finally {
      if (refresh) {
        _isLoading = false;
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  // Fetch Order Detail
  Future<void> fetchOrderDetail(String orderId) async {
    _isLoadingDetail = true;
    _errorDetail = null;
    _detailOrder = null;
    notifyListeners();

    try {
      final order = await _orderService.fetchOrderDetail(orderId);
      
      // Override status if local update exists in SharedPreferences
      String finalStatus = order.status;
      try {
        final listJson = StorageService.getString('local_checkout_orders') ?? '[]';
        final List<dynamic> decoded = jsonDecode(listJson);
        final localOrder = decoded.firstWhere((o) => o['id'] == order.id, orElse: () => null);
        if (localOrder != null) {
          finalStatus = localOrder['status'];
        }
      } catch (_) {}

      _detailOrder = OrderModel(
        id: order.id,
        status: finalStatus,
        total: order.total,
        shippingAddress: order.shippingAddress,
        note: order.note,
        createdAt: order.createdAt,
        items: order.items,
        customerName: order.customerName,
        customerEmail: order.customerEmail,
      );
      _errorDetail = null;
    } catch (e) {
      _errorDetail = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // Create Order (Checkout)
  Future<bool> createOrder({
    required String address,
    required String phone,
    String? notes,
  }) async {
    _isCreatingOrder = true;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        address: address,
        phone: phone,
        notes: notes,
      );
      
      // Save order to SharedPreferences for offline admin sync
      try {
        final listJson = StorageService.getString('local_checkout_orders') ?? '[]';
        final List<dynamic> decoded = jsonDecode(listJson);
        decoded.insert(0, order.toJson());
        await StorageService.saveString('local_checkout_orders', jsonEncode(decoded));
      } catch (e) {
        print('Failed to save order to local storage: $e');
      }
      
      // Refresh list after successful creation
      await fetchOrders(refresh: true);
      
      _isCreatingOrder = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isCreatingOrder = false;
      notifyListeners();
      rethrow;
    }
  }
}
