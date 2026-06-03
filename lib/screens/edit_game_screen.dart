import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';

class EditGameScreen extends StatefulWidget {
  final ContentModel game;

  const EditGameScreen({super.key, required this.game});

  @override
  _EditGameScreenState createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Isi form otomatis dengan data game yang sudah ada
    _nameController.text = widget.game.name;
    // Gabungkan array kategori menjadi string dipisah koma
    _categoryController.text = widget.game.categories.join(', ');
    _priceController.text = widget.game.price.toStringAsFixed(0);
    _aboutController.text = widget.game.description;
  }

  // Fungsi untuk Update data ke Firebase Firestore
  Future<void> _updateData() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _aboutController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    // Pecah kembali string kategori menjadi List
    List<String> categoryList = _categoryController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      // Siapkan data yang mau diupdate
      final updateData = {
        'name': _nameController.text,
        'category': categoryList,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'about': _aboutController.text, // Field di database Anda menggunakan 'about'
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // UPDATE ke koleksi 'games' berdasarkan ID dokumen
      await FirebaseFirestore.instance.collection('games').doc(widget.game.id).update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game updated successfully!'), backgroundColor: Colors.green),
        );
        // Kembali ke Dashboard (Pop 2 kali: Tutup halaman edit, tutup halaman detail)
        Navigator.pop(context); 
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('Edit Game', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView( // Tambahkan ini agar tidak error overflow saat keyboard muncul
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Cover (hanya preview, tidak diedit dulu)
            Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(widget.game.coverUrl), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            ...[
              {'label': 'Name', 'controller': _nameController, 'lines': 1},
              {'label': 'Categories (separate with comma)', 'controller': _categoryController, 'lines': 1},
              {'label': 'Price (Rp)', 'controller': _priceController, 'lines': 1},
              {'label': 'About / Description', 'controller': _aboutController, 'lines': 5}
            ].map((field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field['label'] as String, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: field['controller'] as TextEditingController,
                    maxLines: field['lines'] as int,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F2937),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
            
            const SizedBox(height: 20),
            if (_isUpdating)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _updateData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}