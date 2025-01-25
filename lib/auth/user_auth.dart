import 'package:firebase_auth/firebase_auth.dart';

class UserAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk login pengguna
  static Future<UserCredential?> loginWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    }
  }

  // Fungsi untuk register pengguna
  static Future<UserCredential?> registerWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    }
  }

  // Fungsi untuk logout pengguna
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Mendapatkan pengguna saat ini
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
