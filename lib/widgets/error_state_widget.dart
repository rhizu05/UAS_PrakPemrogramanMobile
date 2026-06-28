import 'package:flutter/material.dart';

// TODO: widgets/error_state_widget.dart
// Tanggung jawab: Menampilkan pesan error kegagalan request API/koneksi internet beserta tombol retry.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Terjadi kesalahan'),
    );
  }
}
