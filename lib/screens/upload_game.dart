import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool _isUploading = false;

  // Function to upload game data to Firebase Firestore
  Future<void> _uploadData() async {
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
      _isUploading = true;
    });

    try {
      // Simpan data ke koleksi 'pending' di Firestore
      final gameData = {
        'name': _nameController.text,
        'category': _categoryController.text,
        'price': double.tryParse(_priceController.text) ??
            0.0, // Konversi harga ke double
        'about': _aboutController.text,
        'uploadedAt':
            FieldValue.serverTimestamp(), // Tambahkan waktu unggah otomatis
      };

      // Menggunakan koleksi 'pending' daripada 'games'
      await FirebaseFirestore.instance.collection('pending').add(gameData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game uploaded to pending successfully')),
      );

      // Reset form
      _nameController.clear();
      _categoryController.clear();
      _priceController.clear();
      _aboutController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Upload Game',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input fields
            ...[
              {'label': 'Name', 'controller': _nameController},
              {'label': 'Category', 'controller': _categoryController},
              {'label': 'Price', 'controller': _priceController},
              {'label': 'About', 'controller': _aboutController}
            ].map((field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field['label'] as String,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: field['controller'] as TextEditingController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F2937),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter ${field['label']}',
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
            const Spacer(),
            if (_isUploading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _uploadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                    ),
                    child: const Text('Upload',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
