import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/app.dart';

// TODO: main.dart
// Tanggung jawab: Titik masuk utama aplikasi (main entry point).
// Menginisialisasi SharedPreferences, binding Flutter, dan menjalankan MobileMartApp.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MobileMartApp());
}
