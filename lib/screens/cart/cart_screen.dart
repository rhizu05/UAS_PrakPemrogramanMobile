import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/cart_provider.dart';
import 'package:uas_prakpemrogramanmobile/screens/checkout/checkout_screen.dart';
import 'package:uas_prakpemrogramanmobile/widgets/confirmation_dialog.dart';
import 'package:uas_prakpemrogramanmobile/widgets/empty_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  Future<void> _handleUpdateQuantity(String cartItemId, int newQty) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final success = await cartProvider.updateQuantity(cartItemId, newQty);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.errorMessage ?? 'Gagal memperbarui jumlah produk'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleDeleteItem(String cartItemId) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final success = await cartProvider.deleteItem(cartItemId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil dihapus dari keranjang'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.errorMessage ?? 'Gagal menghapus produk'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleClearCart() async {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'Kosongkan Keranjang',
        message: 'Apakah Anda yakin ingin menghapus seluruh produk dari keranjang?',
        onConfirm: () async {
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          final success = await cartProvider.clearCart();
          if (!mounted) return;
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Keranjang berhasil dikosongkan'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(cartProvider.errorMessage ?? 'Gagal mengosongkan keranjang'),
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
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        elevation: 0,
        backgroundColor: AppColors.card,
        actions: [
          if (!cartProvider.isCartEmpty && !cartProvider.isLoading)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
              tooltip: 'Kosongkan Keranjang',
              onPressed: _handleClearCart,
            ),
        ],
      ),
      body: _buildCartBody(cartProvider),
      bottomNavigationBar: _buildBottomCheckoutSection(cartProvider),
    );
  }

  Widget _buildCartBody(CartProvider provider) {
    if (provider.isLoading && provider.cart == null) {
      return const LoadingWidget();
    }

    if (provider.errorMessage != null && provider.cart == null) {
      return ErrorStateWidget(
        message: provider.errorMessage!,
        onRetry: () => provider.fetchCart(),
      );
    }

    if (provider.isCartEmpty) {
      return const EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        message: 'Keranjang kamu masih kosong.',
      );
    }

    final cart = provider.cart!;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        final product = item.product;

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: product?.imageUrl != null && product!.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(color: AppColors.cardSoft),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.cardSoft,
                              child: const Icon(Icons.broken_image_outlined, color: AppColors.secondary),
                            ),
                          )
                        : Container(
                            color: AppColors.cardSoft,
                            child: const Icon(Icons.image_outlined, color: AppColors.secondary),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Info & Action Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        product?.name ?? 'Produk',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Unit Price
                      Text(
                        CurrencyHelper.formatRupiah(item.price),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Quantity Controls & Subtotal Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quantity +/- Button Controls
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: item.quantity > 1
                                      ? () => _handleUpdateQuantity(item.id, item.quantity - 1)
                                      : null, // Disabled if quantity is 1
                                ),
                                Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () => _handleUpdateQuantity(item.id, item.quantity + 1),
                                ),
                              ],
                            ),
                          ),
                          
                          // Subtotal Price
                          Text(
                            CurrencyHelper.formatRupiah(item.subtotal),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Delete Icon
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                  onPressed: () => _handleDeleteItem(item.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomCheckoutSection(CartProvider provider) {
    if (provider.isCartEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total Price Summary
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    CurrencyHelper.formatRupiah(provider.grandTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Checkout Button
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
