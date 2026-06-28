import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/date_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/models/order_model.dart';
import 'package:uas_prakpemrogramanmobile/providers/admin_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/confirmation_dialog.dart';
import 'package:uas_prakpemrogramanmobile/widgets/empty_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/status_badge.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final _scrollController = ScrollController();
  final List<String> _statusFilters = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAllOrders();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      Provider.of<AdminProvider>(context, listen: false).fetchAllOrders(refresh: false);
    }
  }

  void _showUpdateStatusDialog(BuildContext context, AdminProvider provider, OrderModel order) {
    final currentStatus = order.status.toLowerCase();
    if (currentStatus == 'delivered' || currentStatus == 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan dengan status $currentStatus tidak dapat diubah lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String? selectedStatus = order.status;
    final List<String> availableStatuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Status Pesanan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${order.id.substring(0, 8).toUpperCase()}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: availableStatuses.contains(selectedStatus) ? selectedStatus : availableStatuses.first,
                    decoration: InputDecoration(
                      labelText: 'Status Baru',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: availableStatuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedStatus = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.secondary)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmUpdate(provider, order, selectedStatus!);
                  },
                  child: const Text('Simpan', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmUpdate(AdminProvider provider, OrderModel order, String newStatus) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'Konfirmasi',
        message: 'Anda yakin ingin mengubah status menjadi $newStatus?',
        onConfirm: () async {
          try {
            final success = await provider.updateOrderStatus(order, newStatus);
            if (!mounted) return;
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status pesanan berhasil diperbarui.'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Pesanan'),
        elevation: 0,
        backgroundColor: AppColors.card,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterChips(adminProvider),
        ),
      ),
      body: _buildBody(adminProvider),
    );
  }

  Widget _buildFilterChips(AdminProvider provider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isActive = (provider.selectedStatusFilter == filter) ||
                           (provider.selectedStatusFilter == null && filter == 'All');
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isActive,
              selectedColor: AppColors.primarySoft,
              backgroundColor: AppColors.cardSoft,
              labelStyle: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isActive ? AppColors.primary : Colors.transparent,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  provider.updateStatusFilter(filter == 'All' ? null : filter);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(AdminProvider provider) {
    if (provider.isLoadingOrders) {
      return const LoadingWidget();
    }

    if (provider.errorOrders != null) {
      return ErrorStateWidget(
        message: provider.errorOrders!,
        onRetry: () => provider.fetchAllOrders(refresh: true),
      );
    }

    if (provider.adminOrders.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        message: 'Tidak ada pesanan yang sesuai.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchAllOrders(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.adminOrders.length + (provider.isLoadingMoreOrders ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index < provider.adminOrders.length) {
            final order = provider.adminOrders[index];
            final orderNumber = order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase();
            final isTerminal = order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'cancelled';

            return Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ORDER-$orderNumber',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        StatusBadge(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateHelper.formatDate(order.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Harga',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              CurrencyHelper.formatRupiah(order.total),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (!isTerminal)
                          ElevatedButton(
                            onPressed: provider.isUpdatingStatus ? null : () => _showUpdateStatusDialog(context, provider, order),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text('Update Status'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
