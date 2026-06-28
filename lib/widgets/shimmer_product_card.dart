import 'package:flutter/material.dart';

// TODO: widgets/shimmer_product_card.dart
// Tanggung jawab: Skeleton loading shimmer untuk grid product catalog agar visual terlihat modern saat loading.
class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 150,
        child: Center(child: Text('Loading Shimmer...')),
      ),
    );
  }
}
