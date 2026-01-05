import 'package:cloud_firestore/cloud_firestore.dart'; // Ganti Storage jadi Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController(); // Tambah ini
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Fungsi untuk Sign Up & Buat Database User
  Future<void> _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Buat Akun di Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Simpan Data User ke Firestore (PENTING!)
      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'wallet_balance': 0, // Saldo awal
          'library': [], // List game kosong
          'created_at': FieldValue.serverTimestamp(),
          'about': 'New gamer on Arkyn', // Default bio
        });
      }

      _showSnackBar('Sign up successful! Please log in.', Colors.green);
      Navigator.pop(context);
      
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Error occurred', Colors.red);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
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
      backgroundColor: const Color(0xFF1B2838), // Warna tema Steam
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Sign Up', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 30),
              
              // Input Username (Baru)
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Username'),
              ),
              const SizedBox(height: 10),
              
              // Input Email
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Email'),
              ),
              const SizedBox(height: 10),
              
              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Password'),
              ),
              const SizedBox(height: 10),
              
              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Confirm Password'),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?", style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Sign in', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF2A475E), // Warna input field Steam
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}