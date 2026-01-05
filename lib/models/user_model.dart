class UserModel {
  final String uid;
  final String email;
  final String name;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
  });

  // Konversi dari Map ke UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
    );
  }

  // Konversi dari UserModel ke Map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
    };
  }
}
