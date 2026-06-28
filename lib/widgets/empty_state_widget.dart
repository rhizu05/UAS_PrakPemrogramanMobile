import 'package:flutter/material.dart';

// TODO: widgets/empty_state_widget.dart
// Tanggung jawab: Menampilkan pesan fallback dalam Bahasa Indonesia beserta Material Icon saat data kosong
// (seperti catalog kosong, cart kosong, orders kosong, dll).
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Data masih kosong'),
    );
  }
}
