import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart'; // Pastikan path ke model benar
import '../widgets/buy_button.dart';

class DetailScreen extends StatefulWidget {
  final ContentModel game; // Kita terima data dari Home

  const DetailScreen({super.key, required this.game});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = false;

  // Fungsi Transaksi Pembelian
  Future<void> _buyGame() async {
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        // Cek apakah game sudah ada di library (opsional, tapi bagus)
        DocumentSnapshot doc = await userDoc.get();
        List dynamicLibrary = (doc.data() as Map)['library'] ?? [];
        
        if (dynamicLibrary.contains(widget.game.id)) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda sudah memiliki game ini!'), backgroundColor: Colors.orange),
          );
        } else {
          // Tambahkan ID game ke library user
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
        title: Text(
          widget.game.name,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR (Menggunakan Network Image)
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network( // Ganti Asset jadi Network
                  widget.game.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey, 
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // DEVELOPER INFO
            Container(
              width: double.infinity,
              color: const Color(0xFF2A475E),
              padding: const EdgeInsets.all(16),
              child: Text(
                "Developer: ${widget.game.developer}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // DESCRIPTION
            const Text(
              "About this game",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF171A21),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                widget.game.description,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // CATEGORY (Diambil dari Model)
            const Text(
              "Categories",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                Chip( // Karena ContentModel kita kategori-nya cuma 1 string, kita tampilkan satu saja
                  label: Text(
                    widget.game.category,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF2A475E),
                )
              ],
            ),
            const SizedBox(height: 16),

            // PRICE & BUY BUTTON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF2A475E),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.game.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xFF212A3E),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          "Rp ${widget.game.price.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      // Tombol Beli yang Fungsional
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
    );
  }
}