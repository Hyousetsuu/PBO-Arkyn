import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Fungsi untuk register pengguna + Buat Database User
  static Future<UserCredential?> registerWithEmailPassword(
      String email, String password, String username) async { // Tambah parameter username
    try {
      // 1. Buat akun di Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 2. Jika sukses, buat data profil di Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users') // Nama koleksi di database
            .doc(userCredential.user!.uid) // Gunakan UID sebagai ID dokumen
            .set({
          'uid': userCredential.user!.uid,
          'email': email.trim(),
          'username': username.trim(),
          'wallet_balance': 0, // Saldo awal 0
          'library': [], // Belum punya game
          'wishlist': [], // Belum ada wishlist
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
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
