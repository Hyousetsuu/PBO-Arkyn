import 'package:arkyn/screens/sign_in_screen.dart'; // Make sure you have this screen for Login
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for sign out

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  // Log out function
  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigating to LoginScreen after logging out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } catch (e) {
      // Handle any potential errors here
      print('Error logging out: $e');
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
            // Navigasi ke halaman sebelumnya
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Text(
          'ADMIN PROFILE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              const Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'ID 00000000001',
                style: TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(45),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E3D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'This world is small,\nthat he can meet her.\nThis world is so big,\nthat he cannot find her again.',
                    style: TextStyle(
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
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: _logOut,
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
