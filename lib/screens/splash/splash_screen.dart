import 'package:flutter/material.dart';

// TODO: screens/splash/splash_screen.dart
// Tanggung jawab: Mengecek token saat startup. Mengarahkan ke login screen (tanpa token)
// atau mengarahkan ke customer_main_navigation_screen / admin_main_navigation_screen berdasarkan role user.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen - Mobile Mart'),
      ),
    );
  }
}
