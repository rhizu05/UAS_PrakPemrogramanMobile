import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/admin_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/empty_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/top_product_item.dart';
import 'package:uas_prakpemrogramanmobile/widgets/top_products_bar_chart.dart';

class TopProductsScreen extends StatefulWidget {
  const TopProductsScreen({super.key});

  @override
  State<TopProductsScreen> createState() => _TopProductsScreenState();
}

class _TopProductsScreenState extends State<TopProductsScreen> {
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
        title: const Text('Produk Terlaris'),
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

    final topProducts = provider.topProducts;

    if (topProducts.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.leaderboard_outlined,
        message: 'Belum ada data penjualan produk.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar Chart Section
          Container(
            height: 300,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TopProductsBarChart(products: topProducts),
          ),
          const SizedBox(height: 24),

          // Ranked List Section
          const Text(
            'Daftar Peringkat Produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topProducts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return TopProductItem(
                product: topProducts[index],
                rank: index + 1,
              );
            },
          ),
        ],
      ),
    );
  }
}
