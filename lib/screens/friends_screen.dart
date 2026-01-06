import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Import Auth
import 'home.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'sign_in_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  int _selectedIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Controller untuk input email teman
  final TextEditingController _friendEmailController = TextEditingController();
  bool _isLoading = false;

  // --- LOGIKA ADD FRIEND ---
  Future<void> _addFriend() async {
    String email = _friendEmailController.text.trim().toLowerCase();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // 1. Cari user lain berdasarkan email
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isEmpty) {
        _showSnackBar('User dengan email tersebut tidak ditemukan.', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      // Ambil data teman
      var friendDoc = query.docs.first;
      String friendId = friendDoc.id;
      String friendName = friendDoc['username'] ?? friendDoc['email'];

      // Cek agar tidak add diri sendiri
      if (friendId == currentUser.uid) {
        _showSnackBar('Anda tidak bisa menambahkan diri sendiri.', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }

      // 2. Tambahkan UID teman ke array 'friends' di dokumen kita
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'friends': FieldValue.arrayUnion([friendId])
      });

      _showSnackBar('Berhasil menambahkan $friendName!', Colors.green);
      Navigator.pop(context); // Tutup dialog
      _friendEmailController.clear();

    } catch (e) {
      _showSnackBar('Gagal menambahkan teman: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2838),
          title: const Text('Add a Friend', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _friendEmailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter friend\'s email',
              hintStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _addFriend,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                : const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // --- LOGIKA NAVIGASI ---
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LibraryScreen()));
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
        ),
        title: const Text('FRIENDS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _buildDrawer(), // Drawer dipisah biar rapi
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Your Friends
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFF355075), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.person, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Your Friends', style: TextStyle(color: Colors.white, fontSize: 16))),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TOMBOL ADD FRIEND (Sekarang Bisa Diklik)
            GestureDetector(
              onTap: _showAddFriendDialog, // Panggil Dialog saat diklik
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFF66C0F4), borderRadius: BorderRadius.circular(4)), // Warna Biru Steam
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Add Friend by Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('Friend List', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // LIST TEMAN (StreamBuilder)
            Expanded(
              child: currentUser == null 
                  ? const Center(child: Text('Please login', style: TextStyle(color: Colors.white)))
                  : StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        
                        var userData = snapshot.data!.data() as Map<String, dynamic>?;
                        List<dynamic> friendsList = userData?['friends'] ?? [];

                        if (friendsList.isEmpty) {
                          return const Center(child: Text('No friends yet. Add one!', style: TextStyle(color: Colors.white54)));
                        }

                        // Mengambil detail setiap teman berdasarkan ID mereka
                        // Note: Ini cara sederhana (client-side join). Untuk scale besar sebaiknya query terpisah.
                        return ListView.builder(
                          itemCount: friendsList.length,
                          itemBuilder: (context, index) {
                            String friendId = friendsList[index];
                            
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
                              builder: (context, friendSnapshot) {
                                if (!friendSnapshot.hasData) return const SizedBox(); // Loading state hidden
                                var friendData = friendSnapshot.data!.data() as Map<String, dynamic>;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFF2E3B4E), borderRadius: BorderRadius.circular(4)),
                                  child: Row(
                                    children: [
                                      // Avatar Teman
                                      const CircleAvatar(
                                        backgroundColor: Colors.blueGrey,
                                        child: Icon(Icons.person, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      // Nama & Status
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            friendData['username'] ?? 'Unknown',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const Text(
                                            'Online', // Status dummy (bisa dikembangkan nanti)
                                            style: TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF171A21),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }

  // Helper untuk Drawer (supaya kode build lebih bersih)
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A2E),
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1A1A2E)),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Log Out', style: TextStyle(color: Colors.white)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
            },
          ),
        ],
      ),
    );
  }
}