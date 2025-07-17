// lib/src/features/history/transaction_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sakupay/src/data/models/transaction_model.dart';
import 'package:flutter/services.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pembelian Berhasil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Status', 'Berhasil',
                      valueColor: Colors.green.shade700),
                  const Divider(),
                  _buildDetailRow('Tanggal',
                      dateFormatter.format(transaction.createdAt.toDate())),
                  const Divider(),
                  _buildDetailRow('Game', transaction.gameName),
                  const Divider(),
                  _buildDetailRow('Item', transaction.itemName),
                  const Divider(),
                  _buildDetailRow('User ID Game', transaction.userId),
                  const Divider(),
                  _buildDetailRow(
                      'Harga', currencyFormatter.format(transaction.price)),
                  const Divider(),
                  // Tambahan baris untuk metode pembayaran
                  _buildDetailRow(
                      'Metode Pembayaran', transaction.paymentMethod),
                  const Divider(),
                  _buildDetailRow('ID Transaksi', transaction.id,
                      canCopy: true, context: context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value,
      {Color? valueColor, bool canCopy = false, BuildContext? context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: valueColor,
                    ),
                  ),
                ),
                if (canCopy && context != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: InkWell(
                      child: Icon(Icons.copy,
                          size: 18, color: Colors.grey.shade500),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('ID Transaksi disalin ke clipboard')),
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
