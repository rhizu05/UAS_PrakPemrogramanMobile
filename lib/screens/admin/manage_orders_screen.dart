import 'package:flutter/material.dart';

// TODO: screens/admin/manage_orders_screen.dart
// Tanggung jawab: Menyediakan interface manajemen pesanan untuk admin. Dilengkapi dengan filter status (Chips),
// list pesanan, dan dropdown update status pesanan per card pesanan (disertai validasi delivered/cancelled locked).
class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Manage Orders Screen'),
      ),
    );
  }
}
