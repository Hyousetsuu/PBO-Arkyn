import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  // Fungsi Validasi Input
  String? _validateInput() {
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
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Menggunakan Firebase Storage untuk menyimpan data pengguna
      final storageRef = FirebaseStorage.instance.ref();
      final userRef = storageRef.child('users/${userCredential.user?.uid}.txt');

      // Menyimpan data user ke Firebase Storage (contohnya, menyimpan email dalam file)
      await userRef.putString('Email: ${userCredential.user?.email}');

      // Menampilkan notifikasi bahwa pendaftaran berhasil
      _showSnackBar('Sign up successful! Please log in.', Colors.green);

      // Navigasi ke Sign In
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      _showSnackBar(_getFirebaseAuthErrorMessage(e), Colors.red);
    } catch (e) {
      print("Unexpected error: $e");
      _showSnackBar('Berhasil mendaftar, Silahkan login.', Colors.blue);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Mendapatkan pesan error dari Firebase
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    print("Error Code: ${e.code}");
    print("Error Message: ${e.message}");

    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use!';
      case 'invalid-email':
        return 'The email address is not valid!';
      case 'weak-password':
        return 'The password is too weak!';
      default:
        return 'An unknown error occurred: ${e.message}';
    }
  }

  // Menampilkan SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
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
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration('Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration('Password'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _inputDecoration('Confirm Password'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?",
                      style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dekorasi Input
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
