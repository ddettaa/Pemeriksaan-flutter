import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/antrian_screen.dart';
import 'screens/histori_screen.dart';
import 'screens/stok_obat_screen.dart';
import 'http_overrides.dart'; // Jika Anda masih menggunakannya

// --- PERBAIKAN DI SINI ---
void main() async {
  // 1. Jadikan fungsi main menjadi async

  // 2. Pastikan binding Flutter sudah siap sebelum menjalankan kode lain
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Muat data lokalisasi untuk format tanggal dan tunggu hingga selesai
  await initializeDateFormatting('id_ID', null);

  // Baris ini opsional, hanya jika Anda masih mengalami masalah sertifikat SSL
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}
// --- AKHIR PERBAIKAN ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIaPotik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // Mengganti ke indigo agar lebih serasi dengan tema aplikasi Anda
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          // Memberi warna latar belakang yang lebih lembut dan modern
          scaffoldBackgroundColor: const Color(0xFFF4F6F8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black87,
            titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          )),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/antrian': (context) => const AntrianScreen(),
        '/histori': (context) => const HistoriScreen(),
        '/stok': (context) => const StokObatScreen(),
      },
    );
  }
}
