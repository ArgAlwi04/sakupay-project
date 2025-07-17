// lib/src/core/main_screen.dart

import 'package:flutter/material.dart';
import 'package:sakupay/src/features/chat/chat_screen.dart'; // <-- Import baru
import 'package:sakupay/src/features/history/history_screen.dart';
import 'package:sakupay/src/features/home/home_screen.dart';
import 'package:sakupay/src/features/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  // Tambahkan ChatScreen ke daftar halaman
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ChatScreen(), // <-- Halaman baru
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Ubah bagian BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined), // <-- Item baru
            label: 'Asisten',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey, // Warna ikon yang tidak aktif
        onTap: _onItemTapped,
      ),
    );
  }
}
