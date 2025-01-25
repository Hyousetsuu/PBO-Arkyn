import 'package:flutter/material.dart';
import 'library_screen.dart'; // Pastikan jalur impor benar
import 'home.dart'; // Pastikan mengimpor HomeScreen
import 'friends_screen.dart'; // Pastikan mengimpor FriendsScreen
import 'profile_screen.dart'; // Pastikan mengimpor ProfileScreen
import '../../widgets/category_box.dart';
import '../widgets/buy_button.dart';

class GameDetailScreen extends StatefulWidget {
  const GameDetailScreen({super.key});

  get game => null;

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  int _selectedIndex = 0;

  // Fungsi untuk menangani pemilihan item di BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Menavigasi ke halaman yang sesuai berdasarkan pilihan
    switch (index) {
      case 0:
        // Navigasi ke HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const HomeScreen()), // Ganti dengan HomeScreen yang benar
        );
        break;
      case 1:
        // Navigasi ke FriendsScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const FriendsScreen()), // Ganti dengan FriendsScreen yang benar
        );
        break;
      case 2:
        // Navigasi ke LibraryScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LibraryScreen()),
        );
        break;
      case 3:
        // Navigasi ke ProfileScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const ProfileScreen()), // Ganti dengan ProfileScreen yang benar
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838), // Set background color to #FF1B2838
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke layar sebelumnya
          },
        ),
        title: const Text("Ghost of Tsushima DIRECTOR'S CUT"),
        titleTextStyle: const TextStyle(color: Colors.white), // Text warna putih
        iconTheme: const IconThemeData(color: Colors.white), // Ikon berwarna putih
        backgroundColor:
            const Color(0xFF1B2838), // Ganti warna latar belakang navbar atas
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[700],
                child: Image.asset(
                  'assets/images/got.jpg', // Pastikan path gambar benar
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                color: const Color(0xFF2A475E),
                padding: const EdgeInsets.all(16),
                child: const Text(
                  "Developer : Sucker Punch Productions",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: const Text(
                  "About this game",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF171A21),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "In the late 13th century, the Mongol empire has laid waste to entire nations...",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Category",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  CategoryBox(label: "Open World"),
                  SizedBox(width: 10),
                  CategoryBox(label: "Action"),
                  SizedBox(width: 10),
                  CategoryBox(label: "Adventure"),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A475E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ghost of Tsushima DIRECTOR'S CUT",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF212A3E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Rp 879 000",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        BuyButton(), // Pastikan widget BuyButton sudah didefinisikan
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF171A21),
        selectedItemColor:
            Colors.grey, // Set warna item yang dipilih menjadi grey
        unselectedItemColor:
            Colors.grey, // Set warna item yang tidak dipilih menjadi grey
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add), label: 'Add Friend'),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Library'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}
