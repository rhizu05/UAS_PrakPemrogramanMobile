import 'package:flutter/material.dart';

// TODO: screens/auth/login_screen.dart
// Tanggung jawab: Menyediakan interface login (email & password) dengan validasi form.
// Alur sukses: Simpan token → Cek role → Arahkan ke dashboard admin / customer navigation.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Screen'),
      ),
    );
  }
}
