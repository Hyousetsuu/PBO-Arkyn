import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';
import 'edit_game_screen.dart'; // Import halaman edit yang akan kita buat

class AdminGameDetailScreen extends StatelessWidget {
  final ContentModel game;

  const AdminGameDetailScreen({super.key, required this.game});

  // Fungsi untuk Menghapus Game
  void _deleteGame(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A3B56),
          title: const Text('Delete Game', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete ${game.name}?', style: const TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await FirebaseFirestore.instance.collection('games').doc(game.id).delete();
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Game deleted successfully'), backgroundColor: Colors.red),
                    );
                    Navigator.pop(context); // Kembali ke Dashboard Admin
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        title: Text('Admin Manage: ${game.name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF171A21),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              game.coverUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey, child: const Icon(Icons.broken_image)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Price: Rp ${game.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.greenAccent, fontSize: 18)),
                  const SizedBox(height: 16),
                  
                  // --- TAMBAHAN KATEGORI ---
                  const Text("Categories", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: game.categories.map((cat) {
                      return Chip(
                        label: Text(cat, style: const TextStyle(color: Colors.white)),
                        backgroundColor: const Color(0xFF2A475E),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // --- TAMBAHAN DESKRIPSI ---
                  const Text("Description", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(game.description, style: const TextStyle(color: Colors.white70, height: 1.5)),
                  const SizedBox(height: 30),
                  
                  // Tombol Aksi Admin
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                       ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        onPressed: () {
                           // MENGARAHKAN KE HALAMAN EDIT
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => EditGameScreen(game: game),
                             ),
                           );
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Edit Game', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        onPressed: () => _deleteGame(context),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}