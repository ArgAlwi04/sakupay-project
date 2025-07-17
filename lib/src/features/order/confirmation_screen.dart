// lib/src/features/order/confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sakupay/src/core/main_screen.dart';
import 'package:sakupay/src/data/models/game_model.dart';
import 'package:sakupay/src/data/models/topup_item_model.dart';
import 'package:sakupay/src/data/models/user_model.dart';
import 'package:sakupay/src/data/repositories/firestore_repository.dart';

class ConfirmationScreen extends StatefulWidget {
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
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late Future<UserModel> _userFuture;

  String? _selectedPaymentMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _userFuture = _firestoreService.getUserData(_uid);
    }
  }

  final List<Map<String, String>> eWallets = [
    {'name': 'Gopay', 'logo': 'assets/gopay.png'},
    {'name': 'Dana', 'logo': 'assets/dana.png'},
    {'name': 'OVO', 'logo': 'assets/ovo.png'},
    {'name': 'ShopeePay', 'logo': 'assets/shopee_pay.png'},
  ];

  final List<Map<String, String>> virtualAccounts = [
    {'name': 'BCA Virtual Account', 'logo': 'assets/bca.png'},
    {'name': 'BRI Virtual Account', 'logo': 'assets/bri.png'},
    {'name': 'Mandiri Virtual Account', 'logo': 'assets/mandiri.png'},
    {'name': 'BNI Virtual Account', 'logo': 'assets/bni.png'},
  ];

  void processPayment(int userBalance) async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih metode pembayaran.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_selectedPaymentMethod == 'Saldo SakuPay') {
        await _firestoreService.payWithBalance(
          authUid: _uid!,
          gameId: widget.game.id,
          gameName: widget.game.name,
          userId: widget.userId,
          item: widget.selectedItem,
        );
      } else {
        await _firestoreService.createTransaction(
          authUid: _uid!,
          gameId: widget.game.id,
          gameName: widget.game.name,
          userId: widget.userId,
          item: widget.selectedItem,
          paymentMethod: _selectedPaymentMethod!,
        );
      }

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Pembayaran Berhasil'),
          content:
              Text('Top up ${widget.selectedItem.itemName} telah berhasil.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    // --- PERUBAHAN PENTING DI SINI ---
                    builder: (c) =>
                        const MainScreen(initialIndex: 2)), // Diubah ke 2
                (route) => false,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Pesanan')),
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Gagal memuat data pengguna.'));
          }

          final userData = snapshot.data!;
          final bool isBalanceSufficient =
              userData.balance >= widget.selectedItem.price;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Detail Pesanan',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Game:', widget.game.name),
                        _buildDetailRow('User ID:', widget.userId),
                        _buildDetailRow('Item:', widget.selectedItem.itemName),
                        const Divider(height: 30),
                        _buildDetailRow(
                          'Total Harga:',
                          currencyFormatter.format(widget.selectedItem.price),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Pilih Metode Pembayaran',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: RadioListTile<String>(
                    title: Row(
                      children: [
                        Image.asset('assets/logo_sakupay.png',
                            width: 40, height: 25, fit: BoxFit.contain),
                        const SizedBox(width: 16),
                        Text('Saldo SakuPay',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isBalanceSufficient ? null : Colors.grey)),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(left: 56.0),
                      child: Text(
                        'Saldo Anda: ${currencyFormatter.format(userData.balance)}${isBalanceSufficient ? '' : ' (Tidak Cukup)'}',
                        style: TextStyle(
                            color: isBalanceSufficient
                                ? Colors.grey.shade600
                                : Colors.red),
                      ),
                    ),
                    value: 'Saldo SakuPay',
                    groupValue: _selectedPaymentMethod,
                    onChanged: isBalanceSufficient
                        ? (value) =>
                            setState(() => _selectedPaymentMethod = value)
                        : null,
                  ),
                ),
                _buildPaymentCategory(
                    title: 'E-Wallet (Simulasi)', methods: eWallets),
                _buildPaymentCategory(
                    title: 'Virtual Account (Simulasi)',
                    methods: virtualAccounts),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<UserModel>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            return ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => processPayment(snapshot.data!.balance),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18)),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    )
                  : const Text('Bayar Sekarang'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentCategory({
    required String title,
    required List<Map<String, String>> methods,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: methods.map((method) {
          return RadioListTile<String>(
            title: Row(
              children: [
                Image.asset(method['logo']!,
                    width: 40, height: 25, fit: BoxFit.contain),
                const SizedBox(width: 16),
                Expanded(child: Text(method['name']!)),
              ],
            ),
            value: method['name']!,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) =>
                setState(() => _selectedPaymentMethod = value),
          );
        }).toList(),
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
