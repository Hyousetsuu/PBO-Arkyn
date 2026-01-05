import 'package:flutter/material.dart';

class BuyButton extends StatelessWidget {
  final VoidCallback? onPressed; // Menerima fungsi klik dari luar
  final bool isLoading; // Untuk status loading

  const BuyButton({
    Key? key, 
    required this.onPressed, 
    this.isLoading = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1363BF), Color(0xFF063871)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ElevatedButton( // Ganti TextButton jadi ElevatedButton agar lebih mudah diatur
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading 
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
          : const Text(
              "Buy",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
      ),
    );
  }
}