import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  // Mendapatkan referensi pengguna yang sedang login
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Fungsi untuk memuat data pengguna dari Firestore
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'] ?? '';
          _aboutController.text = userDoc['about'] ?? '';
        });
      }
    }
  }

  // Fungsi untuk menyimpan data pengguna ke Firestore
  Future<void> _saveUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set(
            {
              'name': _nameController.text,
              'about': _aboutController.text,
            },
            SetOptions(
                merge: true)); // Merge data agar tidak menimpa data lainnya

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved!')),
        );
        Navigator.pop(context); // Kembali ke halaman profil
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Foto Profil dengan Tombol Edit
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/user.jpg'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          // Tambahkan logika untuk mengganti foto profil
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input Nama
            const Text(
              'Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2E2E3D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Input "About Me"
            const Text(
              'About me',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _aboutController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tell us something about yourself',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2E2E3D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),

            // Tombol "Cancel" dan "Save"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Kembali tanpa menyimpan
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    // Simpan data dan kembali ke halaman ProfileScreen
                    final name = _nameController.text;
                    final about = _aboutController.text;

                    if (name.isNotEmpty && about.isNotEmpty) {
                      _saveUserData(); // Simpan perubahan
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill out all fields')),
                      );
                    }
                  },
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
