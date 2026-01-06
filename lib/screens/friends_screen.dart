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

  // --- LOGIKA ADD FRIEND (DIPERBAIKI: MUTUAL ADD) ---
  Future<void> _addFriend() async {
    // 1. Pastikan email lowercase agar pencarian akurat
    String email = _friendEmailController.text.trim().toLowerCase();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // 2. Cari user lain berdasarkan email
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
      String friendName = (friendDoc.data() as Map<String, dynamic>)['username'] ?? email;

      // Cek agar tidak add diri sendiri
      if (friendId == currentUser.uid) {
        _showSnackBar('Anda tidak bisa menambahkan diri sendiri.', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }

      // 3. PROSES SIMPAN DUA ARAH (BATCH WRITE)
      // Kita gunakan Batch agar data masuk ke User 1 DAN User 2 secara bersamaan
      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference myDoc = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      DocumentReference friendRef = FirebaseFirestore.instance.collection('users').doc(friendId);

      // A. Masukkan ID Teman ke list 'friends' SAYA
      batch.update(myDoc, {
        'friends': FieldValue.arrayUnion([friendId])
      });

      // B. Masukkan ID Saya ke list 'friends' TEMAN
      batch.update(friendRef, {
        'friends': FieldValue.arrayUnion([currentUser.uid])
      });

      // Jalankan kedua perintah di atas
      await batch.commit();

      _showSnackBar('Berhasil berteman dengan $friendName!', Colors.green);
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
      endDrawer: _buildDrawer(), 
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

            // TOMBOL ADD FRIEND
            GestureDetector(
              onTap: _showAddFriendDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFF66C0F4), borderRadius: BorderRadius.circular(4)),
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

                        // Menampilkan list teman
                        return ListView.builder(
                          itemCount: friendsList.length,
                          itemBuilder: (context, index) {
                            String friendId = friendsList[index];
                            
                            // Ambil detail teman secara real-time
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
                              builder: (context, friendSnapshot) {
                                if (!friendSnapshot.hasData) return const SizedBox(); 
                                
                                var friendData = friendSnapshot.data!.data() as Map<String, dynamic>?;
                                if (friendData == null) return const SizedBox(); // Jika user dihapus

                                String friendName = friendData['username'] ?? 'Unknown';
                                String friendPhoto = friendData['photo_url'] ?? '';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFF2E3B4E), borderRadius: BorderRadius.circular(4)),
                                  child: Row(
                                    children: [
                                      // Avatar Teman
                                      CircleAvatar(
                                        backgroundColor: Colors.blueGrey,
                                        backgroundImage: friendPhoto.isNotEmpty 
                                          ? NetworkImage(friendPhoto) 
                                          : null,
                                        child: friendPhoto.isEmpty 
                                          ? const Icon(Icons.person, color: Colors.white) 
                                          : null,
                                      ),
                                      const SizedBox(width: 12),
                                      // Nama & Status
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            friendName,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const Text(
                                            'Online', 
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