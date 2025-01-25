class ContentModel {
  final int? id;
  final String name;
  final String category;
  final double price;
  final String about;

  ContentModel({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.about,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'about': about,
    };
  }

  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      about: map['about'],
    );
  }
}
