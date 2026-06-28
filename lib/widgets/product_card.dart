import 'package:flutter/material.dart';

// TODO: widgets/product_card.dart
// Tanggung jawab: Widget card catalog produk (gambar, nama maksimal 2 baris, harga terformat, kategori, rating).
class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Product Card'),
      ),
    );
  }
}
