import 'package:flutter/material.dart';

// TODO: widgets/custom_button.dart
// Tanggung jawab: Menyediakan tombol custom (primary, secondary, danger, disabled, loading)
// dengan radius 14 sesuai standar desain.
class CustomButton extends StatelessWidget {
  const CustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: const Text('Custom Button'),
    );
  }
}
