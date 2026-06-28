import 'package:flutter/material.dart';
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
      _detailOrder = await _orderService.fetchOrderDetail(orderId);
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
      await _orderService.createOrder(
        address: address,
        phone: phone,
        notes: notes,
      );
      
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
