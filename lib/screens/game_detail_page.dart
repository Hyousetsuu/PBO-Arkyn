import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/content_model.dart'; // Pastikan path import model benar

class GameDetailPage extends StatefulWidget {
  final ContentModel game; // Kita oper object Model langsung

  const GameDetailPage({required this.game, Key? key}) : super(key: key);

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  bool _isLoading = false;

  // Fungsi Beli Game
  Future<void> _buyGame() async {
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        // Cek saldo user dulu (Opsional, nanti ditambahkan logic pengurangan saldo)
        
        // Tambahkan ID game ke array 'library' user
        await userDoc.update({
          'library': FieldValue.arrayUnion([widget.game.id]), // Masukkan ID game
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil membeli ${widget.game.name}!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membeli: $e')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2B45),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1D32),
        title: Text(widget.game.name, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Cover
            Image.network(
              widget.game.coverUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => 
                  Container(height: 220, color: Colors.grey, child: const Icon(Icons.broken_image)),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Developer
                  Text(
                    widget.game.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Dev: ${widget.game.developer}',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Kotak Harga & Tombol Beli
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A475E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rp ${widget.game.price.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Warna khas tombol beli Steam
                          ),
                          onPressed: _isLoading ? null : _buyGame,
                          child: _isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                              : const Text("Buy Now", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Text("About this game", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.game.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}