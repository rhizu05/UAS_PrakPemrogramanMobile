import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/admin_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/status_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _lastUpdatedTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.fetchDashboardData();
      provider.fetchAllOrders(refresh: true);
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final hourStr = now.hour.toString().padLeft(2, '0');
    setState(() {
      _lastUpdatedTime = "$hourStr.$minuteStr";
    });
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

  Future<void> _handleRefresh(AdminProvider provider) async {
    _updateTime();
    await Future.wait([
      provider.fetchDashboardData(),
      provider.fetchAllOrders(refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Admin Header (Figma 10:5085)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Admin Dashboard",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getFormattedDate(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          "Terakhir diperbarui $_lastUpdatedTime",
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                    onPressed: () => _handleRefresh(adminProvider),
                  ),
                ],
              ),
            ),

            // Main Body Content
            Expanded(child: _buildBody(adminProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AdminProvider provider) {
    if (provider.isLoadingDashboard) {
      return const LoadingWidget();
    }

    if (provider.errorDashboard != null) {
      return ErrorStateWidget(
        message: provider.errorDashboard!,
        onRetry: () => _handleRefresh(provider),
      );
    }

    final stats = provider.dashboardStats;
    if (stats == null) {
      return const Center(child: Text('Data statistik tidak tersedia.'));
    }

    // Prepare top 3 recent orders
    final recentOrders = provider.adminOrders.take(3).toList();

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(provider),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        children: [
          // 2x2 Grid of Statistics Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Card 1: Total Produk
              _buildStatsCard(
                title: "Total Produk",
                value: stats.totalProducts.toString(),
                icon: Icons.inventory_2_outlined,
                iconColor: const Color(0xFF2563EB), // blue-600
                bgColor: const Color(0xFFEFF6FF), // blue-50
              ),
              // Card 2: Total Pesanan
              _buildStatsCard(
                title: "Total Pesanan",
                value: stats.totalOrders.toString(),
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFF7C3AED), // purple-600
                bgColor: const Color(0xFFF3E8FF), // purple-50
              ),
              // Card 3: Total Pendapatan
              _buildStatsCard(
                title: "Total Pendapatan",
                value: CurrencyHelper.formatRupiah(stats.totalRevenue),
                icon: Icons.trending_up,
                iconColor: const Color(0xFF16A34A), // green-600
                bgColor: const Color(0xFFDCFCE7), // green-50
              ),
              // Card 4: Total Pelanggan
              _buildStatsCard(
                title: "Total Pelanggan",
                value: stats.totalUsers.toString(),
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFFEA580C), // orange-600
                bgColor: const Color(0xFFFFEDD5), // orange-50
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Card 5: Pesanan Pending (Full Width)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2), // red-50
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFFEF4444), // red-500
                    size: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  (stats.ordersByStatus['pending'] ?? 0).toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Pesanan Pending",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Card 6: Pesanan Terbaru (List of top 3)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pesanan Terbaru",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                recentOrders.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Belum ada pesanan terbaru.",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentOrders.length,
                        separatorBuilder: (_, index) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1, color: AppColors.border),
                        ),
                        itemBuilder: (context, index) {
                          final order = recentOrders[index];
                          final orderNumber = order.id.length >= 8 
                              ? order.id.substring(0, 8).toUpperCase() 
                              : order.id.toUpperCase();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '#$orderNumber',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    order.customerName ?? 'Pelanggan',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              StatusBadge(status: order.status),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
