import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.pink,
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
                    const SizedBox(height: 30),
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
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
