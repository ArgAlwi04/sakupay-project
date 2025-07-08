// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sakupay/src/core/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  // Memastikan semua binding Flutter siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi format tanggal untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi palet warna utama aplikasi
    const Color primaryColor = Color(0xFFF48FB1); // Pink dari logo
    const Color backgroundColor = Color(0xFFFFF9F5); // Krem lembut
    const Color accentColor = Color(0xFFE91E63); // Pink lebih gelap untuk aksen

    return MaterialApp(
      title: 'SakuPay',
      debugShowCheckedModeBanner: false,
      // Konfigurasi tema utama aplikasi
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Poppins',

        // Tema untuk AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white, // Warna ikon dan judul di AppBar
          elevation: 1,
        ),

        // Tema untuk Tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor, // Warna tombol
            foregroundColor: Colors.white, // Warna teks di tombol
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),

        // Tema untuk Kartu (Card)
        cardTheme: const CardThemeData(
          // SUDAH DIPERBAIKI: Menggunakan CardThemeData
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          color: Colors.white,
        ),

        // Skema Warna Umum
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          background: backgroundColor,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
