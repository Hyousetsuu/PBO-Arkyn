import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/content_model.dart';
import 'game_detail_screen.dart';
import 'home.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _selectedSort = 'RecentlyAdded';

  // Function to remove a game from wishlist
  Future<void> _removeFromWishlist(String gameId, String gameName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'wishlist': FieldValue.arrayRemove([gameId])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed $gameName from wishlist.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        elevation: 0,
        title: const Text(
          'MY WISHLIST',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (sort) {
              setState(() {
                _selectedSort = sort;
              });
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'RecentlyAdded', child: Text('Recently Added')),
              const PopupMenuItem(value: 'PriceLowHigh', child: Text('Price: Low to High')),
              const PopupMenuItem(value: 'PriceHighLow', child: Text('Price: High to Low')),
              const PopupMenuItem(value: 'Alphabetical', child: Text('Alphabetical (A–Z)')),
            ],
            color: const Color(0xFF171A21),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("Please Login", style: TextStyle(color: Colors.white)))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text("User data not found", style: TextStyle(color: Colors.white)));
                }

                Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> wishlistIds = userData['wishlist'] ?? [];

                if (wishlistIds.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, color: Colors.grey[600], size: 80),
                          const SizedBox(height: 16),
                          const Text(
                            "Your wishlist is empty.",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Add games from the store to keep track of them here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF66C0F4),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            icon: const Icon(Icons.shopping_bag),
                            label: const Text('Browse Store', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('games').snapshots(),
                  builder: (context, gamesSnapshot) {
                    if (gamesSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!gamesSnapshot.hasData || gamesSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No games found in database", style: TextStyle(color: Colors.white)));
                    }

                    // Map all Firestore docs to ContentModel
                    List<ContentModel> allGames = gamesSnapshot.data!.docs
                        .map((doc) => ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                        .toList();

                    // Filter only wishlisted games
                    List<ContentModel> wishlistedGames = allGames
                        .where((game) => wishlistIds.contains(game.id))
                        .toList();

                    if (wishlistedGames.isEmpty) {
                      return const Center(child: Text("Updating wishlist...", style: TextStyle(color: Colors.white)));
                    }

                    // Apply Sorting
                    if (_selectedSort == 'RecentlyAdded') {
                      final orderedWishlistIds = List<String>.from(wishlistIds.reversed);
                      wishlistedGames.sort((a, b) => orderedWishlistIds
                          .indexOf(a.id)
                          .compareTo(orderedWishlistIds.indexOf(b.id)));
                    } else if (_selectedSort == 'PriceLowHigh') {
                      wishlistedGames.sort((a, b) => a.price.compareTo(b.price));
                    } else if (_selectedSort == 'PriceHighLow') {
                      wishlistedGames.sort((a, b) => b.price.compareTo(a.price));
                    } else if (_selectedSort == 'Alphabetical') {
                      wishlistedGames.sort((a, b) => a.name
                          .toLowerCase()
                          .compareTo(b.name.toLowerCase()));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: wishlistedGames.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final game = wishlistedGames[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GameDetailScreen(game: game)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A475E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF354870), width: 1.0),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Game Cover Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    game.coverUrl,
                                    width: 80,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 50,
                                      color: Colors.grey[700],
                                      child: const Icon(Icons.broken_image, color: Colors.white, size: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Game Name and Price
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        game.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Rp ${game.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Remove Icon Button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _removeFromWishlist(game.id, game.name),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
