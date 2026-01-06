import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // PENTING: Ganti Storage jadi Firestore

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController(); // Controller Username
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Fungsi Validasi Input
  String? _validateInput() {
    if (_usernameController.text.isEmpty) {
      return 'Please enter a username!';
    }
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      return 'Please enter a valid email!';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters!';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return 'Passwords do not match!';
    }
    return null;
  }

  // Fungsi untuk Sign Up
  Future<void> _signUp() async {
    final validationMessage = _validateInput();
    if (validationMessage != null) {
      _showSnackBar(validationMessage, Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Buat Akun di Authentication
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Simpan Data User ke FIRESTORE (Database), BUKAN Storage
      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim().toLowerCase(), // Simpan lowercase agar mudah dicari
          'wallet_balance': 0,
          'library': [],
          'friends': [], // Siapkan array teman kosong
          'created_at': FieldValue.serverTimestamp(),
          'about': 'New gamer on Arkyn',
        });
      }

      _showSnackBar('Sign up successful! Please log in.', Colors.green);
      Navigator.pop(context);
      
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'An error occurred', Colors.red);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B4B61),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              
              // Input Username (Penting untuk profile)
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                decoration: _inputDecoration('Username'),
              ),
              const SizedBox(height: 10),

              // Input Email
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                decoration: _inputDecoration('Email'),
              ),
              const SizedBox(height: 10),

              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                decoration: _inputDecoration('Password'),
              ),
              const SizedBox(height: 10),

              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                decoration: _inputDecoration('Confirm Password'),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Sign in', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200], // Latar belakang putih/abu agar teks terlihat
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}