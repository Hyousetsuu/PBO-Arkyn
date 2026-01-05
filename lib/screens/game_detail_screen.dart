import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart'; // Pastikan path ke model benar
import '../widgets/buy_button.dart'; // Pastikan path ke widget benar
import 'home.dart';
import 'friends_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class GameDetailScreen extends StatefulWidget {
  // Kita ubah agar menerima data game yang diklik dari Home
  final ContentModel game;

  const GameDetailScreen({super.key, required this.game});

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  int _selectedIndex = 0;
  bool _isLoading = false; // Status loading saat membeli

  // Fungsi Navigasi Bottom Bar
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
    if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LibraryScreen()));
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  // Fungsi Logika Pembelian ke Firestore
  Future<void> _buyGame() async {
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        // Cek apakah game sudah ada di library user
        DocumentSnapshot doc = await userDoc.get();
        List dynamicLibrary = (doc.data() as Map<String, dynamic>)['library'] ?? [];
        
        if (dynamicLibrary.contains(widget.game.id)) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda sudah memiliki game ini!'), backgroundColor: Colors.orange),
          );
        } else {
          // Tambahkan ID game ke library user di Firestore
          await userDoc.update({
            'library': FieldValue.arrayUnion([widget.game.id]),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Berhasil membeli ${widget.game.name}!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membeli: $e'), backgroundColor: Colors.red),
        );
      }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silahkan login terlebih dahulu'), backgroundColor: Colors.red),
        );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.game.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF171A21),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR GAME (Dari Internet/Firestore)
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.network(
                widget.game.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[700],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
                ),
              ),
            ),

            // DEVELOPER INFO
            Container(
              width: double.infinity,
              color: const Color(0xFF2A475E),
              padding: const EdgeInsets.all(16),
              child: Text(
                "Developer : ${widget.game.developer}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About this game",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  // DESCRIPTION
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171A21),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.game.description,
                      style: const TextStyle(color: Colors.white70, height: 1.5),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // CATEGORY
                  const Text("Category", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(widget.game.category, style: const TextStyle(color: Colors.white)),
                    backgroundColor: const Color(0xFF2A475E),
                  ),

                  const SizedBox(height: 24),

                  // PRICE BOX & BUY BUTTON
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A475E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.game.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Harga
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF000000),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Rp ${widget.game.price.toStringAsFixed(0)}",
                                style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                              ),
                            ),
                            // Tombol Beli (Fixed)
                            BuyButton(
                              isLoading: _isLoading,
                              onPressed: _buyGame,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF171A21),
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}