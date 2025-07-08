// lib/src/data/models/transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String gameName;
  final String itemName;
  final int price;
  final Timestamp createdAt;

  TransactionModel({
    required this.id,
    required this.gameName,
    required this.itemName,
    required this.price,
    required this.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      gameName: data['gameName'] ?? 'N/A',
      itemName: data['itemName'] ?? 'N/A',
      price: data['price'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
