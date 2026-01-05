import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestAdmin extends StatefulWidget {
  const RequestAdmin({Key? key}) : super(key: key);

  @override
  State<RequestAdmin> createState() => _RequestAdminState();
}

class _RequestAdminState extends State<RequestAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF192030),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFF253044),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Label "Pending Games"
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Pending Games',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ListView untuk Game Pending
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(
                        'pending') // Ganti 'pending_games' dengan 'pending'
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No pending games',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final games = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return PendingGameCard(
                        name: game['name'],
                        price: game['price'],
                        onApprove: () => _approveGame(
                            game, context), // Pass context to show snackbar
                        onReject: () => _rejectGame(game),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menyetujui game
  Future<void> _approveGame(DocumentSnapshot game, BuildContext context) async {
    try {
      // Pindahkan data game ke koleksi 'games'
      await FirebaseFirestore.instance.collection('games').add({
        'name': game['name'],
        'price': game['price'],
        'category': game['category'],
        'about': game[
            'about'], // Pastikan Anda memindahkan semua data yang diperlukan
      });
      // Hapus data dari koleksi 'pending'
      await game.reference.delete();

      // Menampilkan snackbar dengan nama game yang disetujui
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil menyetujui game: ${game['name']}'),
          backgroundColor: Colors.green,
        ),
      );
      print('Game approved and moved to games collection.');
    } catch (e) {
      print('Error approving game: $e');
    }
  }

  // Fungsi untuk menolak game
  Future<void> _rejectGame(DocumentSnapshot game) async {
    try {
      // Hapus game dari koleksi 'pending'
      await game.reference.delete();
      print('Game rejected and removed from pending collection.');
    } catch (e) {
      print('Error rejecting game: $e');
    }
  }
}

// Komponen Card untuk Game Pending
class PendingGameCard extends StatelessWidget {
  final String name;
  final int price;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PendingGameCard({
    required this.name,
    required this.price,
    required this.onApprove,
    required this.onReject,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF253044),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${price.toString()}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
