import 'package:flutter/material.dart';
import '../models/content_model.dart';

class ProductListPage extends StatelessWidget {
  final List<ContentModel> productList;

  const ProductListPage({super.key, required this.productList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
      ),
      body: productList.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada produk yang tersedia.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: ListTile(
                    // Menampilkan Gambar Kecil di kiri (Opsional, biar lebih bagus)
                    leading: Image.network(
                      product.coverUrl, 
                      width: 50, 
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      'Kategori: ${product.category}\n'
                      'Harga: Rp${product.price}\n'
                      'Tentang: ${product.description}', // UBAH 'about' jadi 'description'
                    ),
                  ),
                );
              },
            ),
    );
  }
}