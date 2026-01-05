import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'users_list_screen.dart'; // Import the UsersListScreen
import 'requestadmin.dart'; // Import the RequestAdmin
import 'admin_finance.dart'; // Import the DeveloperFundsPage
import 'admin_profile.dart'; // Import the AdminProfileScreen
import 'sign_in_screen.dart'; // Import the SignInScreen

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    GamesPage(),
    UsersListScreen(),
    RequestAdmin(),
    DeveloperFundsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2B45),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1D32),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'Profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProfileScreen()),
                );
              } else if (value == 'Logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Profile', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList();
            },
            color: const Color(0xFF0A1D32),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1B2B45),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Funds',
          ),
        ],
      ),
    );
  }
}

// Halaman 1: Games Page
class GamesPage extends StatefulWidget {
  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference gamesCollection =
      FirebaseFirestore.instance.collection('games');

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            style: const TextStyle(color: Colors.white), // Tambah warna teks input
            decoration: InputDecoration(
              hintText: 'Search for games...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFF253044),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'All Games',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: gamesCollection.snapshots(), // Ambil semua data
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No games available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // Filter search manual (karena Firestore case-sensitive)
              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name'].toString().toLowerCase();
                return name.contains(_searchQuery.toLowerCase());
              }).toList();

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8, // <--- PERBAIKAN OVERFLOW: Ubah rasio agar kartu lebih tinggi (Tadi 1.5)
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  
                  // PERBAIKAN DATA ERROR:
                  // Gunakan 'cover_url' (sesuai model) dan berikan default value jika kosong
                  String imageUrl = data.containsKey('cover_url') 
                      ? data['cover_url'] 
                      : (data.containsKey('imageUrl') ? data['imageUrl'] : 'https://placehold.co/600x400');

                  return GameCard(
                    name: data['name'] ?? 'No Name',
                    imageUrl: imageUrl, 
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// 2. PERBAIKAN CLASS GameCard (Admin Version)
class GameCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const GameCard({
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A3B56),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          Expanded( // Gunakan Expanded agar gambar mengisi sisa ruang
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
          // Teks Judul
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              maxLines: 2, // Batasi maksimal 2 baris
              overflow: TextOverflow.ellipsis, // Jika kepanjangan, beri titik-titik (...)
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14, // Kecilkan font sedikit jika perlu
              ),
            ),
          ),
        ],
      ),
    );
  }
}
