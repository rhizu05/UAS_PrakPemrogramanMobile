import 'package:flutter/material.dart';

// TODO: widgets/confirmation_dialog.dart
// Tanggung jawab: Menyediakan dialog konfirmasi popup reusable (e.g., checkout, logout, kosongkan cart, update status order).
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konfirmasi'),
      content: const Text('Apakah Anda yakin?'),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Batal')),
        TextButton(onPressed: () {}, child: const Text('Ya')),
      ],
    );
  }
}
