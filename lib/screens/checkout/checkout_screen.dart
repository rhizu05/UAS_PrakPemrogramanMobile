import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/validation_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/cart_provider.dart';
import 'package:uas_prakpemrogramanmobile/providers/order_provider.dart';
import 'package:uas_prakpemrogramanmobile/providers/auth_provider.dart';
import 'package:uas_prakpemrogramanmobile/screens/checkout/checkout_success_screen.dart';
import 'package:uas_prakpemrogramanmobile/widgets/confirmation_dialog.dart';
import 'package:uas_prakpemrogramanmobile/widgets/custom_button.dart';
import 'package:uas_prakpemrogramanmobile/widgets/custom_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        _phoneController.text = authProvider.user!.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleCheckout() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Konfirmasi Pesanan',
        message: 'Apakah Anda yakin ingin menyelesaikan pesanan ini?',
        onConfirm: () async {
          final orderProvider = Provider.of<OrderProvider>(context, listen: false);
          
          try {
            final success = await orderProvider.createOrder(
              address: _addressController.text,
              phone: _phoneController.text,
              notes: _notesController.text,
            );

            if (!mounted) return;

            if (success) {
              // Clear cart local state since it's already checked out
              Provider.of<CartProvider>(context, listen: false).fetchCart();
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const CheckoutSuccessScreen(),
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
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    if (cartProvider.cart == null || cartProvider.isCartEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Keranjang Anda kosong')),
      );
    }

    final cart = cartProvider.cart!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
        backgroundColor: AppColors.card,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan Pesanan
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      title: Text(
                        item.product?.name ?? 'Produk',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${item.quantity} x ${CurrencyHelper.formatRupiah(item.price)}'),
                      trailing: Text(
                        CurrencyHelper.formatRupiah(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Detail Pengiriman
              const Text(
                'Detail Pengiriman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Nomor Telepon',
                keyboardType: TextInputType.phone,
                validator: ValidationHelper.validatePhone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                labelText: 'Alamat Pengiriman',
                maxLines: 3,
                validator: ValidationHelper.validateAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                labelText: 'Catatan (Opsional)',
                hintText: 'Cth: Titip di pos satpam',
                maxLines: 2,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
                      CurrencyHelper.formatRupiah(cart.grandTotal),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 150,
                child: CustomButton(
                  text: 'Buat Pesanan',
                  isLoading: orderProvider.isCreatingOrder,
                  onPressed: _handleCheckout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
