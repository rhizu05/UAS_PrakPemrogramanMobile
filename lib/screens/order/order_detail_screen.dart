import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/date_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/order_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/status_badge.dart';
import 'package:uas_prakpemrogramanmobile/providers/admin_provider.dart';
import 'package:uas_prakpemrogramanmobile/providers/auth_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/confirmation_dialog.dart';
import 'package:uas_prakpemrogramanmobile/models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrderDetail(widget.orderId);
    });
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFEDF8D3), // light green/lime
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressItem(IconData icon, String label, String address, String? note) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFEDF8D3), // light green/lime
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  "Catatan: $note",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  int _getStatusStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'processing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
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
              // Refresh detail screen
              Provider.of<OrderProvider>(context, listen: false).fetchOrderDetail(widget.orderId);
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

  Widget? _buildAdminBottomBar(BuildContext context, OrderProvider orderProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAdmin) return null;

    final order = orderProvider.detailOrder;
    if (order == null) return null;

    final isTerminal = order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'cancelled';
    if (isTerminal) return null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            final adminProvider = Provider.of<AdminProvider>(context, listen: false);
            _showUpdateStatusBottomSheet(context, adminProvider, order);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Ubah Status Pesanan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with back button (Figma 5:2288)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Detail Pesanan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Main Body Content
            Expanded(child: _buildBody(orderProvider)),
          ],
        ),
      ),
      bottomNavigationBar: _buildAdminBottomBar(context, orderProvider),
    );
  }

  Widget _buildBody(OrderProvider provider) {
    if (provider.isLoadingDetail) {
      return const LoadingWidget();
    }

    if (provider.errorDetail != null) {
      return ErrorStateWidget(
        message: provider.errorDetail!,
        onRetry: () => provider.fetchOrderDetail(widget.orderId),
      );
    }

    final order = provider.detailOrder;
    if (order == null) {
      return const Center(child: Text('Data pesanan tidak ditemukan.'));
    }

    final orderNumber = order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase();
    final statusStep = _getStatusStepIndex(order.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card 1: Unified Order & Delivery Info (Figma 12:5975)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "NO. PESANAN",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#$orderNumber',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    StatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 16),
                
                // Row with Tanggal & Pemesan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.widgets_outlined,
                        "TANGGAL",
                        DateHelper.formatDate(order.createdAt),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.person_outline_rounded,
                        "PEMESAN",
                        order.customerName ?? '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 16),

                // Alamat Pengiriman
                _buildAddressItem(
                  Icons.location_on_outlined,
                  "ALAMAT PENGIRIMAN",
                  order.shippingAddress.isNotEmpty ? order.shippingAddress : 'Alamat tidak tersedia',
                  order.note,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: Status Pengiriman Timeline (Figma 5:2288)
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
                  "Status Pengiriman",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                order.status.toLowerCase() == 'cancelled'
                    ? Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEE2E2), // light red
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFFEF4444), // red
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Pesanan Dibatalkan",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626), // dark red
                            ),
                          ),
                        ],
                      )
                    : _buildTimelineTracker(statusStep),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 3: Item Pesanan & Rincian (Figma 12:5975)
          Container(
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
                  "Produk yang Dipesan",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // grey circular box icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // product name & sub info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName.isNotEmpty ? item.productName : 'Produk',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity}x · ${CurrencyHelper.formatRupiah(item.price)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // total sub price
                        Text(
                          CurrencyHelper.formatRupiah(item.subtotal),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 16),
                
                // Ongkos kirim
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ongkos kirim',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(
                      'Gratis',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Total Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      CurrencyHelper.formatRupiah(order.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimelineTracker(int activeIndex) {
    final stages = [
      {'title': 'Pending'},
      {'title': 'Processing'},
      {'title': 'Shipped'},
      {'title': 'Delivered'},
    ];

    return Column(
      children: List.generate(stages.length, (index) {
        final title = stages[index]['title']!;
        final isActive = index == activeIndex;
        final isCompleted = index < activeIndex;
        final isNotLast = index < stages.length - 1;

        Widget dotWidget;

        if (isActive) {
          Color bg;
          Color fg;
          switch (index) {
            case 0: // Pending
              bg = const Color(0xFFFFEDD5);
              fg = const Color(0xFFEA580C);
              break;
            case 1: // Processing
              bg = const Color(0xFFDBEAFE);
              fg = const Color(0xFF2563EB);
              break;
            case 2: // Shipped
              bg = const Color(0xFFF3E8FF);
              fg = const Color(0xFF7C3AED);
              break;
            case 3: // Delivered
              bg = const Color(0xFFD1FAE5);
              fg = const Color(0xFF10B981);
              break;
            default:
              bg = const Color(0xFFFFEDD5);
              fg = const Color(0xFFEA580C);
          }

          dotWidget = Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
          );
        } else if (isCompleted) {
          // Green solid dot with checkmark
          dotWidget = Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
            ),
          );
        } else {
          // Grey dot
          dotWidget = Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column containing the Dot & Line spacer
              Column(
                children: [
                  dotWidget,
                  if (isNotLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isCompleted ? AppColors.primary : Colors.grey.shade200,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Right Column containing Title & Description text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: (isActive || isCompleted) ? FontWeight.bold : FontWeight.normal,
                          color: (isActive || isCompleted) ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        const Text(
                          "Status saat ini",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
