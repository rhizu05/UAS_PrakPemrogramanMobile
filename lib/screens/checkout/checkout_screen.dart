import 'package:flutter/material.dart';

// TODO: screens/checkout/checkout_screen.dart
// Tanggung jawab: Menyediakan interface checkout (summary, input alamat dengan validator minimal 10 karakter,
// catatan opsional, tombol konfirmasi buat pesanan, dan popup dialog konfirmasi checkout).
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Checkout Screen'),
      ),
    );
  }
}
