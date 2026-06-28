import 'package:flutter/material.dart';

// TODO: widgets/custom_text_field.dart
// Tanggung jawab: Widget input text custom (rounded input border radius 14, validation error styles).
class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(hintText: 'Custom Text Field'),
    );
  }
}
