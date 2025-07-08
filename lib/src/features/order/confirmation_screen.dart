import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Firebase Auth
import 'package:intl/intl.dart';
import 'package:sakupay/src/data/models/game_model.dart';
import 'package:sakupay/src/data/models/topup_item_model.dart';
import 'package:sakupay/src/data/repositories/firestore_repository.dart';

class ConfirmationScreen extends StatelessWidget {
  final Game game;
  final TopUpItem selectedItem;
  final String userId;

  const ConfirmationScreen({
    super.key,
    required this.game,
    required this.selectedItem,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final firestoreService = FirestoreService();

    void _processPayment() async {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login untuk melakukan transaksi.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Tampilkan dialog loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Simpan transaksi ke Firestore
        await firestoreService.createTransaction(
          authUid: currentUser.uid, // <-- Tambahkan authUid di sini
          gameId: game.id,
          gameName: game.name,
          userId: userId,
          item: selectedItem,
        );

        // Tutup dialog loading
        Navigator.pop(context);

        // Tampilkan dialog sukses
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pembayaran Berhasil'),
            content: Text(
              'Top up ${selectedItem.itemName} untuk game ${game.name} telah berhasil.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Kembali ke halaman sebelumnya
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Detail Pesanan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow('Game:', game.name),
                    _buildDetailRow('User ID:', userId),
                    _buildDetailRow('Item:', selectedItem.itemName),
                    const Divider(height: 30),
                    _buildDetailRow(
                      'Harga:',
                      currencyFormatter.format(selectedItem.price),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Bayar Sekarang'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
