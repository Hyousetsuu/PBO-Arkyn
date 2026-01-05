import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart'; // Import Model
import 'game_card.dart'; 
import 'game_detail_screen.dart'; // Gunakan GameDetailScreen yang baru

class GamesPage extends StatefulWidget {
  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference gamesCollection =
      FirebaseFirestore.instance.collection('games');

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search for games...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFF253044),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'All Games',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Grid Games
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: gamesCollection.snapshots(), // Ambil semua data dulu
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No games available', style: TextStyle(color: Colors.white)));
              }

              // Filter Manual untuk Search (karena Firestore case-sensitive)
              final allDocs = snapshot.data!.docs;
              final filteredDocs = allDocs.where((doc) {
                final name = (doc['name'] as String).toLowerCase();
                return name.contains(_searchQuery.toLowerCase());
              }).toList();

              if (filteredDocs.isEmpty) {
                 return const Center(child: Text('Game not found', style: TextStyle(color: Colors.white)));
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8, // Sesuaikan rasio agar kartu muat
                ),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  // Ubah data Firestore jadi Object ContentModel
                  ContentModel game = ContentModel.fromMap(
                    doc.data() as Map<String, dynamic>, 
                    doc.id
                  );

                  return GameCard(
                    name: game.name,
                    imageUrl: game.coverUrl,
                    onTap: () {
                      // Navigasi mengirim FULL OBJECT ke DetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailScreen(game: game),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}