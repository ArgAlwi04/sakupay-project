// lib/src/features/history/history_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sakupay/src/data/models/transaction_model.dart';
import 'package:sakupay/src/data/repositories/firestore_repository.dart';
import 'package:sakupay/src/features/history/transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  // --- STATE BARU UNTUK PENCARIAN ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('d MMMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: _uid == null
          ? const Center(child: Text('Pengguna tidak ditemukan.'))
          : Column(
              children: [
                // --- KOLOM PENCARIAN BARU ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama game atau item...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                // --- DAFTAR TRANSAKSI YANG BISA DI-FILTER ---
                Expanded(
                  child: StreamBuilder<List<TransactionModel>>(
                    stream: _firestoreService.getTransactionsForUser(_uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada riwayat transaksi.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      }

                      // --- LOGIKA FILTER PENCARIAN ---
                      final allTransactions = snapshot.data!;
                      final filteredTransactions = _searchQuery.isEmpty
                          ? allTransactions
                          : allTransactions.where((trx) {
                              final query = _searchQuery.toLowerCase();
                              final gameName = trx.gameName.toLowerCase();
                              final itemName = trx.itemName.toLowerCase();
                              return gameName.contains(query) ||
                                  itemName.contains(query);
                            }).toList();

                      if (filteredTransactions.isEmpty) {
                        return const Center(
                          child: Text(
                            'Transaksi tidak ditemukan.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final trx = filteredTransactions[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TransactionDetailScreen(
                                            transaction: trx),
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text(trx.itemName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(trx.gameName),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormatter.format(trx.price),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormatter
                                          .format(trx.createdAt.toDate()),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
