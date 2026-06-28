import 'package:flutter/material.dart';

// TODO: widgets/status_badge.dart
// Tanggung jawab: Menampilkan badge status pesanan dengan warna yang sesuai (Pending: Orange,
// Processing: Blue, Shipped: Purple, Delivered: Green, Cancelled: Red).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Chip(
      label: Text('Pending'),
    );
  }
}
