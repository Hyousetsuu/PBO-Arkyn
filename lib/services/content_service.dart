import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';

class ContentService {
  // Referensi ke koleksi 'games' di Firestore
  final CollectionReference _gamesCollection =
      FirebaseFirestore.instance.collection('games');

  // CREATE: Menambah game baru (Biasanya dipakai oleh Admin / UploadGameScreen)
  // Catatan: ID akan dibuat otomatis oleh Firestore
  Future<void> addGame(ContentModel game) async {
    try {
      await _gamesCollection.add(game.toMap());
    } catch (e) {
      print("Error adding game: $e");
      rethrow;
    }
  }

  // READ: Mendapatkan semua game secara Realtime (Stream)
  // Dipakai di HomeScreen agar kalau ada game baru langsung muncul
  Stream<List<ContentModel>> getGamesStream() {
    return _gamesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Mengubah data JSON dari Firestore menjadi object ContentModel
        return ContentModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id, // Ambil ID dokumen dari Firestore
        );
      }).toList();
    });
  }

  // READ: Mendapatkan satu game spesifik berdasarkan ID
  Future<ContentModel?> getGameById(String id) async {
    try {
      DocumentSnapshot doc = await _gamesCollection.doc(id).get();
      if (doc.exists) {
        return ContentModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print("Error getting game: $e");
      return null;
    }
  }

  // UPDATE: Memperbarui data game
  Future<void> updateGame(ContentModel game) async {
    try {
      await _gamesCollection.doc(game.id).update(game.toMap());
    } catch (e) {
      print("Error updating game: $e");
      rethrow;
    }
  }

  // DELETE: Menghapus game
  Future<void> deleteGame(String id) async {
    try {
      await _gamesCollection.doc(id).delete();
    } catch (e) {
      print("Error deleting game: $e");
      rethrow;
    }
  }
  
  // SEARCH: Mencari game berdasarkan nama (Case sensitive di Firestore standar)
  Stream<List<ContentModel>> searchGames(String query) {
    return _gamesCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ContentModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }
}