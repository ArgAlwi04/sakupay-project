// lib/src/features/profile/profile_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- Import intl untuk format mata uang
import 'package:sakupay/src/data/repositories/auth_repository.dart';
import 'package:sakupay/src/data/repositories/firestore_repository.dart';
import 'package:sakupay/src/data/models/user_model.dart';
import 'package:sakupay/src/features/history/history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final authService = AuthService();
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // Formatter untuk mata uang
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : FutureBuilder<UserModel>(
              future: firestoreService.getUserData(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat data profil.'));
                }

                final userData = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // --- Bagian Info Profil ---
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.pink.shade100,
                      child: Text(
                        userData.fullName.isNotEmpty
                            ? userData.fullName[0].toUpperCase()
                            : 'U',
                        style:
                            const TextStyle(fontSize: 50, color: Colors.pink),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userData.email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No. Telepon: ${userData.phoneNumber}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // --- WIDGET BARU UNTUK SALDO ---
                    Card(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo SakuPay',
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormatter.format(userData.balance),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- AKHIR DARI WIDGET BARU ---

                    const SizedBox(height: 16),

                    // --- Bagian Menu ---
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Riwayat Transaksi'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HistoryScreen()),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red.shade700),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      onTap: () async {
                        await authService.signOut();
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
