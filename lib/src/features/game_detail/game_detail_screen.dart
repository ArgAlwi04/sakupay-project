import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sakupay/src/data/models/game_model.dart';
import 'package:sakupay/src/data/models/topup_item_model.dart';
import 'package:sakupay/src/data/repositories/firestore_repository.dart';
import 'package:sakupay/src/features/order/confirmation_screen.dart';

class GameDetailScreen extends StatefulWidget {
  final String gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _userIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('--- GameDetailScreen initState ---');
    print('Game ID received: ${widget.gameId}');
  }

  @override
  Widget build(BuildContext context) {
    print('--- GameDetailScreen build ---');
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return FutureBuilder<Game>(
      future: _firestoreService.getGameById(widget.gameId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          print('Error loading game details: ${snapshot.error}');
          return const Scaffold(
            body: Center(child: Text('Gagal memuat data game.')),
          );
        }

        final game = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(game.name),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  game.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 200),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Masukkan User ID Anda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _userIdController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'User ID',
                          hintText: 'Contoh: 12345678',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2. Pilih Nominal Top-Up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<TopUpItem>>(
                        stream: _firestoreService.getTopUpItems(widget.gameId),
                        builder: (context, itemSnapshot) {
                          print(
                              'TopUp Items StreamBuilder state: ${itemSnapshot.connectionState}');
                          if (itemSnapshot.hasError) {
                            print('TopUp Items Error: ${itemSnapshot.error}');
                          }
                          if (itemSnapshot.hasData) {
                            print(
                                'TopUp Items count: ${itemSnapshot.data!.length}');
                            print(
                                'Raw data received: ${itemSnapshot.data!.map((e) => '${e.itemName} (${e.price})').join(', ')}');
                          }

                          if (itemSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (itemSnapshot.hasError ||
                              !itemSnapshot.hasData ||
                              itemSnapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('Belum ada item tersedia.'));
                          }

                          final items = itemSnapshot.data!;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.5,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Card(
                                child: InkWell(
                                  onTap: () {
                                    final userId =
                                        _userIdController.text.trim();
                                    if (userId.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'User ID tidak boleh kosong!'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ConfirmationScreen(
                                          game: game,
                                          selectedItem: item,
                                          userId: userId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Image.network(
                                            item.itemImageUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.diamond_outlined,
                                                color: Colors.grey,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.itemName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(currencyFormatter
                                                  .format(item.price)),
                                            ],
                                          ),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
