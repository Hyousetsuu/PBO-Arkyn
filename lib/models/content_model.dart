class ContentModel {
  final String id;
  final String name;
  final List<String> categories;
  final double price;
  final String description; // Di DB mungkin tersimpan sebagai 'about'
  final String coverUrl;    // Di DB mungkin tersimpan sebagai 'imageUrl'
  final String developer;

  ContentModel({
    required this.id,
    required this.name,
    required this.categories,
    required this.price,
    required this.description,
    required this.coverUrl,
    required this.developer,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': categories,
      'price': price,
      'description': description,
      'cover_url': coverUrl,
      'developer': developer,
    };
  }

  factory ContentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ContentModel(
      id: documentId,
      name: map['name'] ?? 'No Name',
      // Jika data di DB adalah String, ubah jadi List. Jika sudah List, ambil langsung.
      categories: map['category'] is List 
          ? List<String>.from(map['category']) 
          : [map['category'] ?? 'General'],
      
      // Handle konversi harga (Int ke Double) agar tidak error
      price: (map['price'] is int) 
          ? (map['price'] as int).toDouble() 
          : (map['price'] ?? 0.0).toDouble(),

      // SOLUSI: Cek 'description', jika kosong coba ambil dari 'about'
      description: map['description'] ?? map['about'] ?? 'No description available.',

      // SOLUSI: Cek 'cover_url', jika kosong coba ambil dari 'imageUrl'
      coverUrl: map['cover_url'] ?? map['imageUrl'] ?? 'https://placehold.co/600x400/png',
      
      developer: map['developer'] ?? 'Unknown Developer',
    );
  }
}