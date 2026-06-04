import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart'; // Pastikan path ini benar
import 'game_detail_screen.dart'; // Sesuaikan nama file; // Gunakan halaman detail yang baru kita fix
import 'friends_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Static variables to preserve context when navigating back and forth
  static String _savedCategory = 'All';
  static String _savedSort = 'Newest';
  static String _savedSearchQuery = '';
  static bool _savedIsSearching = false;

  late String _selectedCategory;
  late String _selectedSort;
  late String _searchQuery;
  late bool _isSearching;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _savedCategory;
    _selectedSort = _savedSort;
    _searchQuery = _savedSearchQuery;
    _isSearching = _savedIsSearching;
    _searchController.text = _searchQuery;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
    if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LibraryScreen()));
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  // Capitalize or format category string dynamically
  String _normalizeCategory(String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.toUpperCase() == 'RPG') return 'RPG';
    if (trimmed.toUpperCase() == 'FPS') return 'FPS';
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search games...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    setState(() {
                      _searchQuery = val;
                      _savedSearchQuery = val;
                    });
                  });
                },
              )
            : const Text('Store', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _savedIsSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                  _savedSearchQuery = '';
                  FocusScope.of(context).unfocus();
                } else {
                  _isSearching = true;
                  _savedIsSearching = true;
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (sort) {
              setState(() {
                _selectedSort = sort;
                _savedSort = sort;
              });
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'Newest', child: Text('Newest First')),
              const PopupMenuItem(value: 'PriceLowHigh', child: Text('Price: Low to High')),
              const PopupMenuItem(value: 'PriceHighLow', child: Text('Price: High to Low')),
              const PopupMenuItem(value: 'Alphabetical', child: Text('Alphabetical (A–Z)')),
            ],
            color: const Color(0xFF171A21),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil data dari koleksi 'games' yang sudah diapprove admin
        stream: FirebaseFirestore.instance.collection('games').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No games available yet", style: TextStyle(color: Colors.white)));
          }

          // Konversi Data Firestore ke List<ContentModel>
          List<ContentModel> allGames = snapshot.data!.docs.map((doc) {
             return ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          // Get unique categories dynamically
          Set<String> uniqueCategories = {'All'};
          for (var game in allGames) {
            for (var cat in game.categories) {
              final normalized = _normalizeCategory(cat);
              if (normalized.isNotEmpty) {
                uniqueCategories.add(normalized);
              }
            }
          }
          List<String> categoriesList = uniqueCategories.toList();

          // Normalize search query: trim whitespace and collapse consecutive spaces
          final normalizedQuery = _searchQuery.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

          // Filter games list
          List<ContentModel> filteredGames = allGames.where((game) {
            // Check search match (case-insensitive across name, description, developer, categories)
            final matchesSearch = normalizedQuery.isEmpty ||
                game.name.toLowerCase().contains(normalizedQuery) ||
                game.description.toLowerCase().contains(normalizedQuery) ||
                game.developer.toLowerCase().contains(normalizedQuery) ||
                game.categories.any((c) => _normalizeCategory(c).toLowerCase().contains(normalizedQuery));

            // Check category match
            final matchesCategory = _selectedCategory == 'All' ||
                game.categories.map((c) => _normalizeCategory(c)).contains(_selectedCategory);

            return matchesSearch && matchesCategory;
          }).toList();

          // Sort games list based on selected sort option
          if (_selectedSort == 'Newest') {
            filteredGames.sort((a, b) {
              if (a.uploadedAt == null && b.uploadedAt == null) return 0;
              if (a.uploadedAt == null) return 1;
              if (b.uploadedAt == null) return -1;
              return b.uploadedAt!.compareTo(a.uploadedAt!);
            });
          } else if (_selectedSort == 'PriceLowHigh') {
            filteredGames.sort((a, b) => a.price.compareTo(b.price));
          } else if (_selectedSort == 'PriceHighLow') {
            filteredGames.sort((a, b) => b.price.compareTo(a.price));
          } else if (_selectedSort == 'Alphabetical') {
            filteredGames.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Horizontal Category Chips Selector
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoriesList.length,
                    itemBuilder: (ctx, idx) {
                      final cat = categoriesList[idx];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              final newVal = selected ? cat : 'All';
                              _selectedCategory = newVal;
                              _savedCategory = newVal;
                            });
                          },
                          selectedColor: const Color(0xFF66C0F4),
                          backgroundColor: const Color(0xFF2A475E),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: filteredGames.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No games found matching search or category.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section 1: Featured / Recommended
                            const Text('Featured & Recommended', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildHorizontalList(filteredGames, isBig: true),

                            const SizedBox(height: 24),

                            // Section 2: Special Offers
                            const Text('Special Offers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildHorizontalList(filteredGames.reversed.toList(), isBig: false), // Reversed biar urutannya beda
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF171A21),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<ContentModel> games, {bool isBig = false}) {
    return SizedBox(
      height: isBig ? 220 : 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final game = games[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Pastikan memanggil GameDetailScreen dan mengirim data 'game'
                  builder: (_) => GameDetailScreen(game: game), 
                ),
              );
            },
            child: Container(
              width: isBig ? 300 : 120, // Ukuran lebar beda
              decoration: BoxDecoration(
                color: const Color(0xFF2A475E),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Game
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.network(
                        game.coverUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  // Info Game
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp ${game.price.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}