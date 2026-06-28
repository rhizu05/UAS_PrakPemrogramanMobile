import 'package:flutter/material.dart';

// TODO: screens/cart/cart_screen.dart
// Tanggung jawab: Menampilkan item keranjang belanja customer, control quantity (±), hapus item,
// tombol kosongkan keranjang (dialog konfirmasi), total/grand total, dan navigasi ke checkout.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Cart Screen'),
      ),
    );
  }
}
