import 'package:flutter/material.dart';
import 'game.dart';
import '../widgets/buy_button.dart'; // Import BuyButton

class DetailScreen extends StatelessWidget {
  final Game game;

  // Constructor to receive the game object
  const DetailScreen(
      {super.key, required this.game,
      required String title,
      required String image,
      required String description,
      required String developer,
      required String price,
      required List<String> categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color:
                  Colors.white), // Change the color of the back arrow to white
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          game.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15, // Smaller font size for the title
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display game image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  game.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Display game developer info
            Container(
              width: double.infinity,
              color: const Color(0xFF2A475E),
              padding: const EdgeInsets.all(16),
              child: Text(
                "Developer: ${game.developer}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Display game description
            const Text(
              "About this game",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF171A21),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                game.description,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Display categories section with vertical spacing
            const Text(
              "Categories",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0, // Horizontal spacing between chips
              runSpacing: 8.0, // Vertical spacing between rows of chips
              children: game.categories
                  .map((category) => Chip(
                        label: Text(
                          category,
                          style: const TextStyle(
                              color: Colors
                                  .white), // Change category text color to white
                        ),
                        backgroundColor: const Color(0xFF2A475E),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Display price and buy button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF2A475E),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xFF212A3E),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          "Rp ${game.price}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                      BuyButton(), // Use BuyButton widget
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
