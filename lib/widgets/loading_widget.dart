import 'package:flutter/material.dart';

// TODO: widgets/loading_widget.dart
// Tanggung jawab: Menyediakan spinner CircularProgressIndicator dan base shimmer skeleton loader.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
