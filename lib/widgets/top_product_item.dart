import 'package:flutter/material.dart';

// TODO: widgets/top_product_item.dart
// Tanggung jawab: Widget list item pendukung untuk menampilkan ranking, nama, gambar, dan total sold/sales
// di bawah grafik produk terlaris admin.
class TopProductItem extends StatelessWidget {
  const TopProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('Top Product Item'),
    );
  }
}
