import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/app.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/date_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/services/storage_service.dart';

// TODO: main.dart
// Tanggung jawab: Titik masuk utama aplikasi (main entry point).
// Menginisialisasi SharedPreferences, binding Flutter, dan menjalankan MobileMartApp.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DateHelper.initialize();
  await StorageService.init();
  runApp(const MobileMartApp());
}
