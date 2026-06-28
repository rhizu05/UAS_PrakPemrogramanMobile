class DashboardStatsModel {
  final int totalProducts;
  final int totalOrders;
  final int totalUsers;
  final double totalRevenue;
  final Map<String, int> ordersByStatus;

  DashboardStatsModel({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalUsers,
    required this.totalRevenue,
    required this.ordersByStatus,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    var statusMap = <String, int>{};
    if (json['orders_by_status'] is Map<String, dynamic>) {
      final map = json['orders_by_status'] as Map<String, dynamic>;
      map.forEach((key, value) {
        statusMap[key] = int.tryParse(value.toString()) ?? 0;
      });
    } else if (json['ordersByStatus'] is Map<String, dynamic>) {
      final map = json['ordersByStatus'] as Map<String, dynamic>;
      map.forEach((key, value) {
        statusMap[key] = int.tryParse(value.toString()) ?? 0;
      });
    }

    return DashboardStatsModel(
      totalProducts: json['total_products'] ?? json['totalProducts'] ?? 0,
      totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
      totalUsers: json['total_users'] ?? json['totalUsers'] ?? 0,
      totalRevenue: double.tryParse((json['total_revenue'] ?? json['totalRevenue'] ?? 0).toString()) ?? 0.0,
      ordersByStatus: statusMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'total_orders': totalOrders,
      'total_users': totalUsers,
      'total_revenue': totalRevenue,
      'orders_by_status': ordersByStatus,
    };
  }
}
