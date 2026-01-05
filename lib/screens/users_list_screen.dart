import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersListScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'All Users',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<UserCardData>>(
        future: _fetchUsersFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error.toString()}', // Menampilkan error yang lebih jelas
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserCard(
                name: user.name,
                email: user.email,
                onDelete: () => _deleteUser(user.email),
              );
            },
          );
        },
      ),
      backgroundColor: Colors.blueGrey[900],
    );
  }

  // Mengambil data pengguna dari Firestore
  Future<List<UserCardData>> _fetchUsersFromFirestore() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs.map((doc) {
        return UserCardData(
          name: doc['name'] ?? 'No Name', // Default jika field tidak ada
          email: doc['email'] ?? 'No Email', // Default jika field tidak ada
        );
      }).toList();
    } catch (e) {
      // Menampilkan error jika gagal mengambil data
      print('Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Menghapus pengguna berdasarkan email
  Future<void> _deleteUser(String email) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('User with email $email has been deleted.');
    } catch (e) {
      print('Error deleting user: $e');
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
      color: Colors.blueGrey[800],
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
