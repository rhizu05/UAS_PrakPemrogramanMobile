import 'package:flutter/material.dart';

// TODO: screens/home/home_screen.dart
// Tanggung jawab: Menampilkan katalog produk customer. Dilengkapi dengan search bar, chip filter kategori,
// sort dropdown, product grid (pagination/load more), loading skeleton, error, dan empty states.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home Screen (Product Catalog)'),
      ),
    );
  }
}
