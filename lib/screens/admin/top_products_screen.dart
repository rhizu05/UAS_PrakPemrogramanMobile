import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/admin_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/empty_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Grafik Penjualan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: topProducts.fold<double>(
                          0, (max, e) => e.totalSold.toDouble() > max ? e.totalSold.toDouble() : max) * 1.2,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < topProducts.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '#${value.toInt() + 1}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: topProducts.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.totalSold.toDouble(),
                              color: AppColors.primary,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = topProducts[index];
              return Card(
                elevation: 0,
                color: AppColors.cardSoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    product.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${product.productId}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Terjual',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${product.totalSold}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
