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
    if (_usernameController.text.trim().isEmpty) {
      return 'Please enter a username.';
    }
    if (_usernameController.text.trim().length < 3) {
      return 'Username must be at least 3 characters long.';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Please enter your email address.';
    }
    if (!_emailController.text.trim().contains('@') || !_emailController.text.trim().contains('.')) {
      return 'Please enter a valid email address (e.g., user@example.com).';
    }
    if (_passwordController.text.isEmpty) {
      return 'Please enter a password.';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (_confirmPasswordController.text.isEmpty) {
      return 'Please confirm your password.';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return 'Passwords do not match. Please check and try again.';
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

      _showSnackBar('Account created successfully! Please sign in.', Colors.green);
      Navigator.pop(context);
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseAuthErrorMessage(e);
      _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      _showSnackBar('Unexpected error: ${e.toString()}. Please try again.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in or use a different email.';
      case 'invalid-email':
        return 'Invalid email format. Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? 24.0 : 32.0;
    final maxWidth = isMobile ? double.infinity : 400.0;

    return Scaffold(
      backgroundColor: const Color(0xFF3B4B61),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Input Username (Penting untuk profile)
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: _inputDecoration('Username'),
                  ),
                  const SizedBox(height: 16),

                  // Input Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black87),
                    decoration: _inputDecoration('Email'),
                  ),
                  const SizedBox(height: 16),

                  // Input Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black87),
                    decoration: _inputDecoration('Password'),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black87),
                    decoration: _inputDecoration('Confirm Password'),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                        ),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.blue[300],
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[600]),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}