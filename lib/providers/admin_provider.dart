import 'package:flutter/material.dart';
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

    try {
      final result = await _adminService.fetchAllOrders(
        status: _selectedStatusFilter,
        page: _currentPage,
        limit: 10,
      );

      final List<OrderModel> fetchedOrders = result['orders'];
      _currentPage = result['page'] + 1;
      _totalPages = result['totalPages'];
      _hasMore = result['page'] < _totalPages;

      if (refresh) {
        _adminOrders = fetchedOrders;
      } else {
        _adminOrders.addAll(fetchedOrders);
      }

      _errorOrders = null;
    } catch (e) {
      if (refresh) {
        _adminOrders = [];
        _errorOrders = e.toString();
      }
    } finally {
      if (refresh) {
        _isLoadingOrders = false;
      } else {
        _isLoadingMoreOrders = false;
      }
      notifyListeners();
    }
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
      await _adminService.updateOrderStatus(order.id, newStatus);
      
      // Refresh the list after successful update
      await fetchAllOrders(refresh: true);
      
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
