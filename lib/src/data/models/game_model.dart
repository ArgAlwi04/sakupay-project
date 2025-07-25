// lib/src/data/models/game_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String userIdHelpImageUrl; // <-- Field baru ditambahkan

  Game({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.userIdHelpImageUrl, // <-- Field baru ditambahkan
  });

  factory Game.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Game(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      userIdHelpImageUrl:
          data['userIdHelpImageUrl'] ?? '', // <-- Field baru ditambahkan
    );
  }
}
