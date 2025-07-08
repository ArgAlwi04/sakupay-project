// lib/src/data/repositories/firestore_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sakupay/src/data/models/game_model.dart';
import 'package:sakupay/src/data/models/topup_item_model.dart';
import 'package:sakupay/src/data/models/transaction_model.dart';
import 'package:sakupay/src/data/models/user_model.dart'; // <-- Pastikan file ini ada

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ambil daftar semua game (realtime)
  Stream<List<Game>> getGames() {
    return _db.collection('games').orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
    });
  }

  // Ambil data satu game berdasarkan ID
  Future<Game> getGameById(String gameId) async {
    final doc = await _db.collection('games').doc(gameId).get();
    return Game.fromFirestore(doc);
  }

  // Ambil item top-up dari subkoleksi game tertentu (tanpa orderBy di Firestore)
  Stream<List<TopUpItem>> getTopUpItems(String gameId) {
    return _db
        .collection('games')
        .doc(gameId)
        .collection('topup_items')
        .snapshots()
        .map((snapshot) {
      final list =
          snapshot.docs.map((doc) => TopUpItem.fromFirestore(doc)).toList();

      // Urutkan secara lokal berdasarkan harga dari yang termurah
      list.sort((a, b) => a.price.compareTo(b.price));

      return list;
    });
  }

  // Simpan transaksi ke koleksi 'transactions'
  Future<void> createTransaction({
    required String authUid,
    required String gameId,
    required String gameName,
    required String userId,
    required TopUpItem item,
  }) async {
    try {
      await _db.collection('transactions').add({
        'authUid': authUid,
        'gameId': gameId,
        'gameName': gameName,
        'userId': userId,
        'itemName': item.itemName,
        'price': item.price,
        'itemImageUrl': item.itemImageUrl,
        'status': 'success',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi ke database: $e');
    }
  }

  // Ambil daftar transaksi pengguna berdasarkan authUid
  Stream<List<TransactionModel>> getTransactionsForUser(String authUid) {
    return _db
        .collection('transactions')
        .where('authUid', isEqualTo: authUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  // Ambil data pengguna dari koleksi 'users' berdasarkan UID
  Future<UserModel> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('User tidak ditemukan di Firestore');
    }

    return UserModel.fromFirestore(doc);
  }
}
