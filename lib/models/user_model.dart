class UserModel {
  final String uid;
  final String email;
  final String username; // Ganti 'name' jadi 'username' agar lebih relevan utk gamer
  final double walletBalance; // Penting: Saldo user
  final List<String> library; // Penting: Daftar ID game yang sudah dibeli
  final List<String> wishlist; // Fitur tambahan: Game yang diinginkan

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.walletBalance = 0.0,
    this.library = const [],
    this.wishlist = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      // Konversi aman ke double (kadang Firestore simpan int jika bulat)
      walletBalance: (data['wallet_balance'] ?? 0).toDouble(),
      // Konversi List<dynamic> ke List<String>
      library: List<String>.from(data['library'] ?? []),
      wishlist: List<String>.from(data['wishlist'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'wallet_balance': walletBalance,
      'library': library,
      'wishlist': wishlist,
    };
  }
}