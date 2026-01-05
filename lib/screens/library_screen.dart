import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/content_model.dart';
import 'game_detail_screen.dart'; // Import halaman detail
import 'friends_screen.dart';
import 'home.dart';
import 'profile_screen.dart';
import 'sign_in_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1D2733),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2733),
        elevation: 0,
        title: const Text('LIBRARY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
        ),
      ),
      body: user == null 
          ? const Center(child: Text("Please Login", style: TextStyle(color: Colors.white)))
          : StreamBuilder<DocumentSnapshot>(
              // 1. Ambil data User dulu untuk melihat Library-nya
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                // Ambil array 'library' dari dokumen user
                List<dynamic> libraryIds = (userSnapshot.data!.data() as Map<String, dynamic>)['library'] ?? [];

                if (libraryIds.isEmpty) {
                  return const Center(child: Text("You haven't bought any games yet.", style: TextStyle(color: Colors.grey)));
                }

                // 2. Ambil Data Game berdasarkan ID yang ada di Library
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('games').snapshots(),
                  builder: (context, gameSnapshot) {
                    if (!gameSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                    // Filter game: Hanya tampilkan jika ID-nya ada di libraryIds user
                    List<ContentModel> myGames = gameSnapshot.data!.docs
                        .map((doc) => ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                        .where((game) => libraryIds.contains(game.id))
                        .toList();

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Tampilan library biasanya lebih kecil (3 kolom)
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: myGames.length,
                      itemBuilder: (context, index) {
                        final game = myGames[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GameDetailScreen(game: game)), // Pass ContentModel
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    game.coverUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_,__,___) => Container(color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                game.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
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
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}