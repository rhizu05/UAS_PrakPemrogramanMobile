import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/admin_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/stats_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        backgroundColor: AppColors.card,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => adminProvider.fetchDashboardData(),
          ),
        ],
      ),
      body: _buildBody(adminProvider),
    );
  }

  Widget _buildBody(AdminProvider provider) {
    if (provider.isLoadingDashboard) {
      return const LoadingWidget();
    }

    if (provider.errorDashboard != null) {
      return ErrorStateWidget(
        message: provider.errorDashboard!,
        onRetry: () => provider.fetchDashboardData(),
      );
    }

    final stats = provider.dashboardStats;
    if (stats == null) {
      return const Center(child: Text('Data statistik tidak tersedia.'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchDashboardData(),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Ringkasan Bisnis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatsCard(
                title: 'Total Pendapatan',
                value: CurrencyHelper.formatRupiah(stats.totalRevenue),
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
              ),
              StatsCard(
                title: 'Total Pesanan',
                value: stats.totalOrders.toString(),
                icon: Icons.shopping_bag_rounded,
                color: AppColors.success,
              ),
              StatsCard(
                title: 'Produk Aktif',
                value: stats.totalProducts.toString(),
                icon: Icons.inventory_2_rounded,
                color: AppColors.secondary,
              ),
              StatsCard(
                title: 'Total Pelanggan',
                value: stats.totalCustomers.toString(),
                icon: Icons.people_alt_rounded,
                color: AppColors.info,
              ),
              StatsCard(
                title: 'Pesanan Pending',
                value: stats.totalPendingOrders.toString(),
                icon: Icons.pending_actions_rounded,
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
