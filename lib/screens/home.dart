import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart'; // Pastikan path ini benar
import 'game_detail_page.dart';
import 'game_detail_screen.dart'; // Sesuaikan nama file; // Gunakan halaman detail yang baru kita fix
import 'friends_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
    if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LibraryScreen()));
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        title: const Text('Store', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
           IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {}, // Nanti tambahkan fitur search
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil data dari koleksi 'games' yang sudah diapprove admin
        stream: FirebaseFirestore.instance.collection('games').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No games available yet", style: TextStyle(color: Colors.white)));
          }

          // Konversi Data Firestore ke List<ContentModel>
          List<ContentModel> allGames = snapshot.data!.docs.map((doc) {
             return ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Featured / Recommended
                const Text('Featured & Recommended', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildHorizontalList(allGames, isBig: true),

                const SizedBox(height: 24),

                // Section 2: Special Offers (Misal kita tampilkan semua game lagi dengan style beda)
                const Text('Special Offers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildHorizontalList(allGames.reversed.toList(), isBig: false), // Reversed biar urutannya beda
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF171A21),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<ContentModel> games, {bool isBig = false}) {
    return SizedBox(
      height: isBig ? 220 : 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final game = games[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Pastikan memanggil GameDetailScreen dan mengirim data 'game'
                  builder: (_) => GameDetailScreen(game: game), 
                ),
              );
            },
            child: Container(
              width: isBig ? 300 : 120, // Ukuran lebar beda
              decoration: BoxDecoration(
                color: const Color(0xFF2A475E),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Game
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.network(
                        game.coverUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  // Info Game
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp ${game.price.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}