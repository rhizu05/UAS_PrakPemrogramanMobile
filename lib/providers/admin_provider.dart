import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/services/storage_service.dart';
import 'package:uas_prakpemrogramanmobile/models/dashboard_stats_model.dart';
import 'package:uas_prakpemrogramanmobile/models/top_product_model.dart';
import 'package:uas_prakpemrogramanmobile/models/order_model.dart';
import 'package:uas_prakpemrogramanmobile/services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  // Dashboard State
  DashboardStatsModel? _dashboardStats;
  List<TopProductModel> _topProducts = [];
  bool _isLoadingDashboard = false;
  String? _errorDashboard;

  // Orders State
  List<OrderModel> _adminOrders = [];
  bool _isLoadingOrders = false;
  bool _isLoadingMoreOrders = false;
  bool _isUpdatingStatus = false;
  String? _errorOrders;
  
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  String? _selectedStatusFilter;

  // Getters Dashboard
  DashboardStatsModel? get dashboardStats => _dashboardStats;
  List<TopProductModel> get topProducts => _topProducts;
  bool get isLoadingDashboard => _isLoadingDashboard;
  String? get errorDashboard => _errorDashboard;

  // Getters Orders
  List<OrderModel> get adminOrders => _adminOrders;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isLoadingMoreOrders => _isLoadingMoreOrders;
  bool get isUpdatingStatus => _isUpdatingStatus;
  String? get errorOrders => _errorOrders;
  bool get hasMore => _hasMore;
  String? get selectedStatusFilter => _selectedStatusFilter;

  // Helper to update local order status in SharedPreferences
  Future<void> _updateLocalOrderStatus(String id, String newStatus) async {
    try {
      final listJson = StorageService.getString('local_checkout_orders') ?? '[]';
      final List<dynamic> decoded = jsonDecode(listJson);
      for (var i = 0; i < decoded.length; i++) {
        if (decoded[i]['id'] == id) {
          decoded[i]['status'] = newStatus;
          break;
        }
      }
      await StorageService.saveString('local_checkout_orders', jsonEncode(decoded));
    } catch (_) {}
  }

  // Fetch Dashboard Stats and Top Products
  Future<void> fetchDashboardData() async {
    _isLoadingDashboard = true;
    _errorDashboard = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _adminService.fetchDashboardStats(),
        _adminService.fetchTopProducts(),
      ]);

      _dashboardStats = results[0] as DashboardStatsModel;
      _topProducts = results[1] as List<TopProductModel>;
      _errorDashboard = null;
    } catch (e) {
      _errorDashboard = e.toString();
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  // Update Status Filter and Fetch
  void updateStatusFilter(String? status) {
    _selectedStatusFilter = status;
    fetchAllOrders(refresh: true);
  }

  // Fetch All Customer Orders
  Future<void> fetchAllOrders({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _errorOrders = null;
      _isLoadingOrders = true;
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMoreOrders) return;
      _isLoadingMoreOrders = true;
      notifyListeners();
    }

    List<OrderModel> fetchedOrders = [];
    
    try {
      final result = await _adminService.fetchAllOrders(
        status: _selectedStatusFilter,
        page: _currentPage,
        limit: 10,
      );

      fetchedOrders = result['orders'];
      _currentPage = result['page'] + 1;
      _totalPages = result['totalPages'];
      _hasMore = result['page'] < _totalPages;
      _errorOrders = null;
    } catch (e) {
      if (refresh) {
        _errorOrders = e.toString();
      }
    }
    
    // Always load local checkout orders and merge with API orders
    if (refresh) {
      List<OrderModel> localOrders = [];
      try {
        final listJson = StorageService.getString('local_checkout_orders') ?? '[]';
        final List<dynamic> decoded = jsonDecode(listJson);
        localOrders = decoded.map((json) => OrderModel.fromJson(json)).toList();
      } catch (_) {}
      
      // Enrich local orders that don't have customerName from API orders
      final apiCustomerMap = <String, String>{};
      for (final apiOrder in fetchedOrders) {
        if (apiOrder.customerName != null && apiOrder.customerName!.trim().isNotEmpty) {
          apiCustomerMap[apiOrder.id] = apiOrder.customerName!;
        }
      }
      localOrders = localOrders.map((o) {
        if ((o.customerName == null || o.customerName!.trim().isEmpty) && apiCustomerMap.containsKey(o.id)) {
          return OrderModel(
            id: o.id,
            status: o.status,
            total: o.total,
            shippingAddress: o.shippingAddress,
            note: o.note,
            createdAt: o.createdAt,
            items: o.items,
            customerName: apiCustomerMap[o.id],
            customerEmail: o.customerEmail,
          );
        }
        return o;
      }).toList();
      
      final localIds = localOrders.map((o) => o.id).toSet();
      final filteredApi = fetchedOrders.where((o) => !localIds.contains(o.id)).toList();
      
      _adminOrders = [...localOrders, ...filteredApi];
      
      // Apply status filtering locally
      if (_selectedStatusFilter != null && _selectedStatusFilter!.isNotEmpty && _selectedStatusFilter!.toLowerCase() != 'all') {
        _adminOrders = _adminOrders.where((o) => o.status.toLowerCase() == _selectedStatusFilter!.toLowerCase()).toList();
      }
    } else {
      _adminOrders.addAll(fetchedOrders);
    }

    if (_adminOrders.isEmpty && _errorOrders == null) {
      _errorOrders = null;
    }

    if (refresh) {
      _isLoadingOrders = false;
    } else {
      _isLoadingMoreOrders = false;
    }
    notifyListeners();
  }

  // Update Order Status
  Future<bool> updateOrderStatus(OrderModel order, String newStatus) async {
    // Validate if current status is terminal
    final currentStatus = order.status.toLowerCase();
    if (currentStatus == 'delivered' || currentStatus == 'cancelled') {
      throw Exception('Pesanan dengan status $currentStatus tidak dapat diubah lagi.');
    }

    _isUpdatingStatus = true;
    notifyListeners();

    try {
      final isDummy = order.id.contains('-DUMMY');
      final isLocal = StorageService.getString('local_checkout_orders')?.contains(order.id) ?? false;
      
      if (isDummy) {
        // Mock the update locally for dummy data (bypass backend)
        await Future.delayed(const Duration(milliseconds: 500));
        final index = _adminOrders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
           final old = _adminOrders[index];
           _adminOrders[index] = OrderModel(
             id: old.id,
             status: newStatus,
             total: old.total,
             shippingAddress: old.shippingAddress,
             note: old.note,
             createdAt: old.createdAt,
             items: old.items,
             customerName: old.customerName,
             customerEmail: old.customerEmail,
           );
        }
      } else if (isLocal) {
        // It's a local checkout order: update backend AND update SharedPreferences locally
        try {
          await _adminService.updateOrderStatus(order.id, newStatus);
        } catch (_) {
          // If admin endpoint for status update fails (e.g. auth or 500), just fall back to local update
        }
        await _updateLocalOrderStatus(order.id, newStatus);
        
        final index = _adminOrders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
           final old = _adminOrders[index];
           _adminOrders[index] = OrderModel(
             id: old.id,
             status: newStatus,
             total: old.total,
             shippingAddress: old.shippingAddress,
             note: old.note,
             createdAt: old.createdAt,
             items: old.items,
             customerName: old.customerName,
             customerEmail: old.customerEmail,
           );
        }
      } else {
        await _adminService.updateOrderStatus(order.id, newStatus);
        // Refresh the list after successful update
        await fetchAllOrders(refresh: true);
      }
      
      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUpdatingStatus = false;
      notifyListeners();
      rethrow;
    }
  }
}
