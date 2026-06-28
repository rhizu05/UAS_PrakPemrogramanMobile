import 'package:flutter/material.dart';

// TODO: app.dart
// Tanggung jawab: Menyusun MaterialApp utama, mengonfigurasi tema Light Minimal Modern,
// mendaftarkan rute navigasi aplikasi, dan mengonfigurasi MultiProvider.
class MobileMartApp extends StatelessWidget {
  const MobileMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Mart',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Mobile Mart App')),
      ),
    );
  }
}
