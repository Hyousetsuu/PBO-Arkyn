import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadGameScreen extends StatefulWidget {
  const UploadGameScreen({super.key});

  @override
  _UploadGameScreenState createState() => _UploadGameScreenState();
}

class _UploadGameScreenState extends State<UploadGameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  
  // --- TAMBAHAN BARU: Controller untuk URL Gambar ---
  final TextEditingController _imageUrlController = TextEditingController(); 

  bool _isUploading = false;

  // Fungsi untuk upload data ke Firebase
  Future<void> _uploadData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first to upload a game!'), backgroundColor: Colors.red),
      );
      return;
    }

    // Validasi form agar tidak ada yang kosong
    if (_nameController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _aboutController.text.trim().isEmpty ||
        _imageUrlController.text.trim().isEmpty) { // Cek URL gambar juga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields!'), backgroundColor: Colors.red),
      );
      return;
    }

    final double? price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price must be greater than zero!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // --- LOGIKA KATEGORI (Ubah string dipisah koma menjadi List) ---
    List<String> categoryList = _categoryController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      final String developerName = currentUser.displayName ??
          (currentUser.email != null && currentUser.email!.contains('@')
              ? currentUser.email!.split('@').first
              : 'Unknown Developer');

      // Data yang akan disimpan ke koleksi 'pending'
      final gameData = {
        'name': _nameController.text.trim(),
        'category': categoryList, // Disimpan sebagai Array/List
        'price': price,
        'about': _aboutController.text.trim(),
        'cover_url': _imageUrlController.text.trim(), // Simpan URL Gambar
        'developer_uid': currentUser.uid,
        'developer_name': developerName,
        'developer_email': currentUser.email ?? '',
        'status': 'pending',
        'created_at': Timestamp.now(),
        'uploadedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('pending').add(gameData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game uploaded to pending successfully!'), backgroundColor: Colors.green),
        );
        
        // Reset form setelah berhasil
        _nameController.clear();
        _categoryController.clear();
        _priceController.clear();
        _aboutController.clear();
        _imageUrlController.clear(); // Reset controller gambar
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
          _isUploading = false;
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
    _imageUrlController.dispose(); // Jangan lupa di-dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('Upload Game', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView( // Tambahkan SingleChildScrollView agar bisa di-scroll
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List Input fields dengan tambahan fitur "lines" agar kotak About lebih besar
            ...[
              {'label': 'Name', 'controller': _nameController, 'lines': 1},
              {'label': 'Categories (separate with comma)', 'controller': _categoryController, 'lines': 1},
              {'label': 'Price (Rp)', 'controller': _priceController, 'lines': 1},
              {'label': 'Image URL (Link gambar dari Google)', 'controller': _imageUrlController, 'lines': 1}, // Input Gambar
              {'label': 'About / Description', 'controller': _aboutController, 'lines': 5}
            ].map((field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field['label'] as String,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: field['controller'] as TextEditingController,
                    maxLines: field['lines'] as int,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F2937),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter ${field['label'].toString().split(' ').first}',
                      hintStyle: const TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
            
            const SizedBox(height: 20), // Spacer
            if (_isUploading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _uploadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: const Text('Upload', style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}