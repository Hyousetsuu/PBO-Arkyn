import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart'; // Pastikan path ke model benar
import '../widgets/buy_button.dart'; // Pastikan path ke widget benar
import 'home.dart';
import 'friends_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'payment.dart';

class GameDetailScreen extends StatefulWidget {
  // Kita ubah agar menerima data game yang diklik dari Home
  final ContentModel game;

  const GameDetailScreen({super.key, required this.game});

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  int _selectedIndex = 0;
  bool _isLoading = false; // Status loading saat membeli
  Stream<DocumentSnapshot>? _userStream;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userStream = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();
    }
  }

  // Navigasi Bottom Bar
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) Navigator.pushReplacementNamed(context, '/home');
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
    if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LibraryScreen()));
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  // Fungsi Pembelian via Wallet dengan Safe Transaction + History Logging
  Future<void> _buyGameWithWallet() async {
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        String result = await FirebaseFirestore.instance.runTransaction<String>((transaction) async {
          DocumentSnapshot userSnapshot = await transaction.get(userDoc);
          if (!userSnapshot.exists) {
            return 'user_not_found';
          }
          
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
          List<dynamic> library = userData['library'] ?? [];
          
          if (library.contains(widget.game.id)) {
            return 'already_owned';
          }
          
          double balance = (userData['wallet_balance'] ?? 0).toDouble();
          double totalSpent = (userData['total_spent'] ?? 0).toDouble();
          if (balance < widget.game.price) {
            return 'insufficient_balance';
          }
          
          double newBalance = balance - widget.game.price;
          double newSpent = totalSpent + widget.game.price;
          List<dynamic> updatedLibrary = List.from(library)..add(widget.game.id);
          
          transaction.update(userDoc, {
            'wallet_balance': newBalance,
            'total_spent': newSpent,
            'library': updatedLibrary,
          });

          // Buat data transaksi di subkoleksi 'wallet_transactions'
          DocumentReference transactionDoc = userDoc.collection('wallet_transactions').doc();
          transaction.set(transactionDoc, {
            'type': 'purchase',
            'amount': -widget.game.price,
            'gameId': widget.game.id,
            'gameTitle': widget.game.name,
            'timestamp': FieldValue.serverTimestamp(),
          });
          
          // Buat data pembelian di subkoleksi 'purchases'
          DocumentReference purchaseDoc = userDoc.collection('purchases').doc();
          transaction.set(purchaseDoc, {
            'gameId': widget.game.id,
            'gameTitle': widget.game.name,
            'price': widget.game.price,
            'paymentMethod': 'wallet',
            'purchaseDate': FieldValue.serverTimestamp(),
          });
          
          return 'success';
        });

        if (result == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil membeli ${widget.game.name}! Saldo Anda telah didebit.'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (result == 'already_owned') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda sudah memiliki game ini!'), backgroundColor: Colors.orange),
          );
        } else if (result == 'insufficient_balance') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saldo tidak cukup untuk membeli game ini!'), backgroundColor: Colors.red),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User tidak ditemukan.'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membeli: $e'), backgroundColor: Colors.red),
        );
      }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silahkan login terlebih dahulu'), backgroundColor: Colors.red),
        );
    }
    setState(() => _isLoading = false);
  }

  // Fungsi Pembelian via Direct Payment (Redirect to PaymentScreen)
  void _buyGameWithDirectPayment(String paymentMethod) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          game: widget.game,
          paymentMethod: paymentMethod,
        ),
      ),
    ).then((success) {
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil membeli ${widget.game.name} via $paymentMethod!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  // Tampilkan Bottom Sheet Pilihan Pembayaran ala Steam
  void _showCheckoutBottomSheet(BuildContext context, double currentBalance) {
    String selectedMethod = 'wallet';
    if (currentBalance < widget.game.price) {
      selectedMethod = 'direct_qris';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Izinkan sheet berkembang melampaui limit tinggi default
      backgroundColor: const Color(0xFF171A21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            bool isWalletDisabled = currentBalance < widget.game.price;
            
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0, // Padding aman agar tidak overflow
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Checkout',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Game Summary
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          widget.game.coverUrl,
                          width: 80,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 80, height: 50, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.game.name,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${widget.game.price.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF354870), height: 32),
                  
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  
                  // Wallet Option
                  Opacity(
                    opacity: isWalletDisabled ? 0.5 : 1.0,
                    child: InkWell(
                      onTap: isWalletDisabled
                          ? null
                          : () {
                              setSheetState(() {
                                selectedMethod = 'wallet';
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedMethod == 'wallet' ? const Color(0xFF2A475E) : const Color(0xFF1B2838),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedMethod == 'wallet' ? const Color(0xFF66C0F4) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: selectedMethod == 'wallet' ? const Color(0xFF66C0F4) : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Arkyn Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(
                                    isWalletDisabled
                                        ? 'Insufficient Funds (Balance: Rp ${currentBalance.toStringAsFixed(0)})'
                                        : 'Balance: Rp ${currentBalance.toStringAsFixed(0)} (Remaining: Rp ${(currentBalance - widget.game.price).toStringAsFixed(0)})',
                                    style: TextStyle(
                                      color: isWalletDisabled ? Colors.redAccent : Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedMethod == 'wallet')
                              const Icon(Icons.check_circle, color: Color(0xFF66C0F4), size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // QRIS
                  InkWell(
                    onTap: () {
                      setSheetState(() {
                        selectedMethod = 'direct_qris';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedMethod == 'direct_qris' ? const Color(0xFF2A475E) : const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedMethod == 'direct_qris' ? const Color(0xFF66C0F4) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.qr_code,
                            color: selectedMethod == 'direct_qris' ? const Color(0xFF66C0F4) : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('QRIS / E-Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                SizedBox(height: 2),
                                Text('Pay instantly using GoPay, OVO, or Dana QR', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                          ),
                          if (selectedMethod == 'direct_qris')
                            const Icon(Icons.check_circle, color: Color(0xFF66C0F4), size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // VA
                  InkWell(
                    onTap: () {
                      setSheetState(() {
                        selectedMethod = 'direct_va';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedMethod == 'direct_va' ? const Color(0xFF2A475E) : const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedMethod == 'direct_va' ? const Color(0xFF66C0F4) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance,
                            color: selectedMethod == 'direct_va' ? const Color(0xFF66C0F4) : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Virtual Account (VA)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                SizedBox(height: 2),
                                Text('Transfer via BCA, Mandiri, BNI, or BRI', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                          ),
                          if (selectedMethod == 'direct_va')
                            const Icon(Icons.check_circle, color: Color(0xFF66C0F4), size: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Complete Purchase Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (selectedMethod == 'wallet') {
                          _buyGameWithWallet();
                        } else {
                          String payLabel = 'QRIS';
                          if (selectedMethod == 'direct_va') payLabel = 'Bank Transfer';
                          _buyGameWithDirectPayment(payLabel);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66C0F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Complete Purchase',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, userSnapshot) {
        bool isOwned = false;
        double currentBalance = 0.0;
        
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> library = userData['library'] ?? [];
          isOwned = library.contains(widget.game.id);
          currentBalance = (userData['wallet_balance'] ?? 0.0).toDouble();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF1B2838),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.game.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
            backgroundColor: const Color(0xFF171A21),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GAMBAR GAME (Dari Internet/Firestore)
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Image.network(
                    widget.game.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[700],
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
                    ),
                  ),
                ),

                // DEVELOPER INFO
                Container(
                  width: double.infinity,
                  color: const Color(0xFF2A475E),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Developer : ${widget.game.developer}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "About this game",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      
                      // DESCRIPTION
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171A21),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.game.description,
                          style: const TextStyle(color: Colors.white70, height: 1.5),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // CATEGORY
                      const Text("Categories", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: widget.game.categories.map((cat) {
                          return Chip(
                            label: Text(cat, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: const Color(0xFF2A475E),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // PRICE BOX & BUY BUTTON
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A475E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.game.name,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Harga
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF000000),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "Rp ${widget.game.price.toStringAsFixed(0)}",
                                    style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                                  ),
                                ),
                                // Tombol Beli / IN LIBRARY
                                isOwned
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4B6E1F),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.check, color: Colors.white, size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              'IN LIBRARY',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      )
                                    : BuyButton(
                                        isLoading: _isLoading,
                                        onPressed: () => _showCheckoutBottomSheet(context, currentBalance),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF171A21),
            selectedItemColor: Colors.grey,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Friends'),
              BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Library'),
              BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}