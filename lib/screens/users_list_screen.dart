import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersListScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // KITA HAPUS SCAFFOLD & APPBAR 
    // Agar tampilan ini menjadi bagian (widget) dari Admin Dashboard
    return Container(
      color: const Color(0xFF1B2B45), // Samakan background dengan Admin Dashboard
      child: FutureBuilder<List<UserCardData>>(
        future: _fetchUsersFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error.toString()}', 
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final users = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80), // Tambah padding bawah agar tidak tertutup navbar
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserCard(
                name: user.name,
                email: user.email,
                onDelete: () => _deleteUser(context, user.email),
              );
            },
          );
        },
      ),
    );
  }

  // Mengambil data pengguna dari Firestore
  Future<List<UserCardData>> _fetchUsersFromFirestore() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Cek 'username' (baru) atau 'name' (lama)
        String displayName = 'No Name';
        if (data.containsKey('username')) {
          displayName = data['username'];
        } else if (data.containsKey('name')) {
          displayName = data['name'];
        }

        return UserCardData(
          name: displayName, 
          email: data['email'] ?? 'No Email', 
        );
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Menghapus pengguna
  Future<void> _deleteUser(BuildContext context, String email) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User $email has been deleted'), backgroundColor: Colors.red),
      );
      
      // Note: Di real production, kita biasanya perlu me-refresh tampilan (setState) 
      // tapi karena kita pakai FutureBuilder, user harus pindah tab dulu baru balik lagi utk refresh list,
      // atau kita bisa ubah jadi StreamBuilder nanti.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

class UserCardData {
  final String name;
  final String email;

  UserCardData({
    required this.name,
    required this.email,
  });
}

class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onDelete;

  const UserCard(
      {required this.name, required this.email, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF253044),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}