// lib/src/data/models/topup_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TopUpItem {
  final String id;
  final String itemName;
  final int price;
  final String itemImageUrl;

  TopUpItem({
    required this.id,
    required this.itemName,
    required this.price,
    required this.itemImageUrl,
  });

  factory TopUpItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TopUpItem(
      id: doc.id,
      itemName: data['itemName'] ?? '',
      price: data['price'] ?? 0,
      itemImageUrl: data['itemImageUrl'] ?? '',
    );
  }
}
