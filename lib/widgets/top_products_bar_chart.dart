import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/models/top_product_model.dart';

class TopProductsBarChart extends StatelessWidget {
  final List<TopProductModel> products;

  const TopProductsBarChart({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Tidak ada data penjualan',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final maxY = products.fold<double>(
          0,
          (max, e) => e.soldCount.toDouble() > max ? e.soldCount.toDouble() : max,
        ) *
        1.2;

    return Column(
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
              maxY: maxY == 0 ? 10.0 : maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (group.x >= 0 && group.x < products.length) {
                      return BarTooltipItem(
                        '${products[group.x].name}\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: 'Terjual: ${rod.toY.toInt()}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      );
                    }
                    return null;
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < products.length) {
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
              barGroups: products.asMap().entries.map((entry) {
                final color = entry.key == 0
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 1.0 - (entry.key * 0.15).clamp(0.3, 1.0));
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.soldCount.toDouble(),
                      color: color,
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
    );
  }
}
