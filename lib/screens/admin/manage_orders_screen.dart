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
import 'package:uas_prakpemrogramanmobile/screens/order/order_detail_screen.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final _scrollController = ScrollController();
  final List<String> _statusFilters = ['Semua', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  String _getProductSummary(OrderModel order) {
    if (order.items.isEmpty) return 'Tidak ada item';
    final firstItem = order.items[0].productName;
    if (order.items.length == 1) {
      return firstItem;
    } else {
      return '$firstItem (+${order.items.length - 1} item lainnya)';
    }
  }

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

  void _showUpdateStatusBottomSheet(BuildContext context, AdminProvider provider, OrderModel order) {
    final orderNumber = order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase();
    final List<String> statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
    String selectedStatus = order.status;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ubah Status Pesanan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Pilih status baru untuk #$orderNumber",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Status buttons layout
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusBtn(statuses[0], selectedStatus, order.status, (val) {
                              setSheetState(() => selectedStatus = val);
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatusBtn(statuses[1], selectedStatus, order.status, (val) {
                              setSheetState(() => selectedStatus = val);
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusBtn(statuses[2], selectedStatus, order.status, (val) {
                              setSheetState(() => selectedStatus = val);
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatusBtn(statuses[3], selectedStatus, order.status, (val) {
                              setSheetState(() => selectedStatus = val);
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: 0.485,
                                child: _buildStatusBtn(statuses[4], selectedStatus, order.status, (val) {
                                  setSheetState(() => selectedStatus = val);
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border, width: 1.5),
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedStatus == order.status
                              ? null
                              : () {
                                  Navigator.pop(ctx);
                                  _confirmUpdate(provider, order, selectedStatus);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Update", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBtn(
    String status,
    String currentSelected,
    String originalStatus,
    ValueChanged<String> onChanged,
  ) {
    final isCurrent = status.toLowerCase() == originalStatus.toLowerCase();
    final isSelected = status.toLowerCase() == currentSelected.toLowerCase();

    Color bg;
    Border border;
    Color fg;

    if (isCurrent) {
      bg = Colors.grey.shade100;
      border = Border.all(color: Colors.transparent);
      fg = Colors.grey.shade400;
    } else if (isSelected) {
      bg = const Color(0xFFF1FBF0); // lime-50
      border = Border.all(color: AppColors.primary, width: 1.5);
      fg = AppColors.primary;
    } else {
      bg = Colors.white;
      border = Border.all(color: Colors.grey.shade200, width: 1.2);
      fg = Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: isCurrent ? null : () => onChanged(status),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          status,
          style: TextStyle(
            color: fg,
            fontWeight: isSelected || isCurrent ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
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
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header (Figma 10:5377)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Manajemen Pesanan",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                    onPressed: () => adminProvider.fetchAllOrders(refresh: true),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips/Tabs
            _buildFilterChips(adminProvider),

            // Order List Body
            Expanded(child: _buildBody(adminProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(AdminProvider provider) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isActive = (provider.selectedStatusFilter == filter) ||
                           (provider.selectedStatusFilter == null && filter == 'Semua');
          
          return GestureDetector(
            onTap: () {
              provider.updateStatusFilter(filter == 'Semua' ? null : filter);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : const Color(0xFFF1F5F9), // green-500 vs slate-100
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF64748B), // white vs slate-500
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
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
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: provider.adminOrders.length + (provider.isLoadingMoreOrders ? 1 : 0),
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index < provider.adminOrders.length) {
            final order = provider.adminOrders[index];
            final orderNumber = order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase();
            final isTerminal = order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'cancelled';

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: order.id),
                    ),
                  ).then((_) {
                    // Refresh data on returning in case status was updated
                    provider.fetchAllOrders(refresh: true);
                  });
                },
                child: Ink(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Order ID and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#$orderNumber',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          StatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Row 2: Customer Name
                      Text(
                        order.customerName ?? 'Pelanggan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Row 3: Date
                      Text(
                        DateHelper.formatDate(order.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Row 4: Product Summary
                      Text(
                        _getProductSummary(order),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Row 5: Price and Lihat Detail
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyHelper.formatRupiah(order.total),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
        },
      ),
    );
  }
}
