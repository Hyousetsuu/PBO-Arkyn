import 'dart:io'; // Import penting untuk File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Storage
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Instance Storage

  File? _imageFile; // Variabel untuk menampung gambar yang dipilih dari galeri
  String _currentPhotoUrl = ''; // URL foto saat ini dari database
  bool _isLoading = false; // Status loading saat upload

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fungsi memilih gambar dari Galeri
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery, 
      maxWidth: 512, // Kompres gambar agar tidak terlalu besar
      maxHeight: 512,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Simpan file lokal untuk preview
      });
    }
  }

  // LOAD DATA
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['username'] ?? data['name'] ?? '';
          _aboutController.text = data['about'] ?? '';
          _currentPhotoUrl = data['photo_url'] ?? ''; // Ambil URL foto jika ada
        });
      }
    }
  }

  // SAVE DATA (Termasuk Upload Gambar)
  Future<void> _saveUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return;
    
    if (_nameController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username cannot be empty')));
       return;
    }

    setState(() => _isLoading = true);

    String? newPhotoUrl;

    try {
      // 1. Cek apakah ada gambar baru yang dipilih?
      if (_imageFile != null) {
        // Buat referensi lokasi simpan di Firebase Storage
        // Path: user_profile_images/UID_USER.jpg
        final storageRef = _storage.ref().child('user_profile_images').child('${user.uid}.jpg');
        
        // Proses Upload
        UploadTask uploadTask = storageRef.putFile(_imageFile!);
        TaskSnapshot snapshot = await uploadTask;

        // Ambil URL download setelah selesai upload
        newPhotoUrl = await snapshot.ref.getDownloadURL();
      }

      // 2. Siapkan data yang mau diupdate ke Firestore
      Map<String, dynamic> updateData = {
        'username': _nameController.text,
        'about': _aboutController.text,
      };

      // Jika ada URL foto baru, tambahkan ke data update
      if (newPhotoUrl != null) {
        updateData['photo_url'] = newPhotoUrl;
      }

      // 3. Simpan ke Firestore
      await _firestore.collection('users').doc(user.uid).set(
        updateData,
        SetOptions(merge: true)
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Kembali dan refresh

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logika untuk menentukan gambar mana yang ditampilkan di CircleAvatar
    ImageProvider backgroundImage;
    if (_imageFile != null) {
      // 1. Prioritas Utama: Gambar lokal yang baru dipilih
      backgroundImage = FileImage(_imageFile!);
    } else if (_currentPhotoUrl.isNotEmpty) {
      // 2. Prioritas Kedua: Gambar dari URL database (jika ada)
      backgroundImage = NetworkImage(_currentPhotoUrl);
    } else {
      // 3. Default: Gambar aset placeholder
      backgroundImage = const AssetImage('assets/images/user.png');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      // Tambahkan Stack untuk loading overlay
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // BAGIAN FOTO PROFIL (Updated)
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey,
                        backgroundImage: backgroundImage, // Gunakan logika di atas
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: _pickImage, // Panggil fungsi pilih gambar saat diklik
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // INPUT NAME
                const Text('Username', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true, fillColor: const Color(0xFF2E2E3D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                // INPUT ABOUT
                const Text('About me', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _aboutController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tell us something about yourself',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true, fillColor: const Color(0xFF2E2E3D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 40),

                // BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: _isLoading ? null : _saveUserData, // Disable saat loading
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Loading Indicator Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}