import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:arkyn/screens/sign_in_screen.dart'; // Make sure you have this screen for Login
import 'package:flutter/material.dart';
import 'upload_game.dart'; // Import file upload_game.dart
import 'edit_profile.dart';
import 'home.dart'; // Import halaman Home untuk kembali ke halaman Home
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for sign out
import 'library_screen.dart';
import 'friends_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Variabel untuk menyimpan informasi pengguna
  String name = '';
  String userEmail = '';
  String about = ''; // Variabel untuk menyimpan "about" dari Firestore

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  // Fungsi untuk mendapatkan informasi pengguna
  void _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? 'No email';
      });

      // Mengambil data name dan about dari koleksi bio di Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((docSnapshot) {
        if (docSnapshot.exists) {
          setState(() {
            name = docSnapshot['name'] ?? user.email?.split('@')[0] ?? 'User';
            about = docSnapshot['about'] ?? 'No information available.';
          });
        }
      });
    }
  }

  // Fungsi untuk logout
  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigating to LoginScreen after logging out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // Function to handle back button press
  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
    return false;
  }

  // Fungsi untuk menanggapi perubahan pada BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi berdasarkan index yang dipilih
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FriendsScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LibraryScreen()),
        );
        break;
      case 3:
        // Tetap di halaman ProfileScreen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF1B2838),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B2838),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          title: const Text(
            'PROFILE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        endDrawer: Drawer(
          backgroundColor: const Color(0xFF1A1A2E),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A2E),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: const Text('Log Out',
                    style: TextStyle(color: Colors.white)),
                onTap: _logOut,
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/user.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  name, // Menampilkan nama pengguna (field name)
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail, // Menampilkan email pengguna
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'About me',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 4.0),
                  child: Container(
                    padding: const EdgeInsets.all(45),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2E3D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      about, // Menampilkan tentang pengguna (field about)
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Edit profile',
                      style: TextStyle(color: Colors.white),
                    ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadGameScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Upload Game',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF171A21),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap:
              _onItemTapped, // Memastikan onTap mengarah ke fungsi _onItemTapped
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_add), label: 'Friends'),
            BottomNavigationBarItem(
                icon: Icon(Icons.archive), label: 'Library'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
