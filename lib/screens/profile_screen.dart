import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:arkyn/screens/sign_in_screen.dart'; // Pastikan path benar
import 'package:flutter/material.dart';
import 'upload_game.dart'; 
import 'edit_profile.dart';
import 'home.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'library_screen.dart';
import 'friends_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Variabel untuk menyimpan informasi pengguna
  String name = '';
  String userEmail = '';
  String about = '';
  String photoUrl = ''; // Variabel URL Foto
  double walletBalance = 0.0;
  double totalTopup = 0.0;
  double totalSpent = 0.0;
  bool _isLoading = false;
  StreamSubscription<DocumentSnapshot>? _profileSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToProfile();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  // Berlangganan ke data profil secara real-time
  void _subscribeToProfile() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? 'No email';
      });

      _profileSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((docSnapshot) {
        if (docSnapshot.exists) {
          Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              photoUrl = data['photo_url'] ?? ''; 
              name = data['username'] ?? data['name'] ?? user.email?.split('@')[0] ?? 'User';
              about = data['about'] ?? 'No information available.';
              walletBalance = (data['wallet_balance'] ?? 0.0).toDouble();
              totalTopup = (data['total_topup'] ?? 0.0).toDouble();
              totalSpent = (data['total_spent'] ?? 0.0).toDouble();
            });
          }
        }
      });
    }
  }

  // Stub kosong sebagai fallback agar navigasi lain tidak rusak
  void _getUserInfo() {}

  // Fungsi untuk top up balance user ke Firestore dengan Transaction + Log History
  Future<void> _topUpWallet(double amount) async {
    if (amount <= 0) return;
    
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userDoc);
        if (!userSnapshot.exists) {
          throw Exception("User not found!");
        }
        
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        double currentBalance = (userData['wallet_balance'] ?? 0.0).toDouble();
        double currentTopup = (userData['total_topup'] ?? 0.0).toDouble();
        
        double newBalance = currentBalance + amount;
        double newTopup = currentTopup + amount;
        
        transaction.update(userDoc, {
          'wallet_balance': newBalance,
          'total_topup': newTopup,
        });
        
        // Buat data transaksi top up di subkoleksi 'wallet_transactions'
        DocumentReference transactionDoc = userDoc.collection('wallet_transactions').doc();
        transaction.set(transactionDoc, {
          'type': 'topup',
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil top up sebesar Rp ${amount.toStringAsFixed(0)}!'),
          backgroundColor: Colors.green,
        ),
      );
      
      _getUserInfo(); // Refresh state
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Top up gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Dialog untuk input nominal Top Up
  void _showTopUpDialog() {
    final TextEditingController customAmountController = TextEditingController();
    double? selectedAmount;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1B2838),
              title: const Text('Top Up Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select an amount to top up:', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    // Quick select
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [50000.0, 100000.0, 200000.0, 500000.0].map((amount) {
                        bool isSelected = selectedAmount == amount;
                        return ChoiceChip(
                          label: Text(
                            'Rp ${amount.toStringAsFixed(0)}',
                            style: TextStyle(color: isSelected ? Colors.black : Colors.white),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF66C0F4),
                          backgroundColor: const Color(0xFF2A475E),
                          onSelected: (selected) {
                            setStateDialog(() {
                              selectedAmount = selected ? amount : null;
                              if (selected) {
                                customAmountController.clear();
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Or enter custom amount:', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: customAmountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter custom amount',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFF2A475E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedAmount = double.tryParse(val);
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: (selectedAmount == null || selectedAmount! <= 0)
                      ? null
                      : () {
                          Navigator.pop(context);
                          _topUpWallet(selectedAmount!);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66C0F4),
                    disabledBackgroundColor: Colors.grey[700],
                  ),
                  child: const Text('Proceed to Top Up', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Fungsi untuk logout
  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // Function to handle back button press
  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
    return false;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FriendsScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LibraryScreen()));
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF1B2838),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B2838),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          title: const Text(
            'PROFILE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        endDrawer: Drawer(
          backgroundColor: const Color(0xFF1A1A2E),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF1A1A2E)),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: const Text('Log Out', style: TextStyle(color: Colors.white)),
                onTap: _logOut,
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Ruang agar tombol di bawah tidak tertutup
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // --- BAGIAN FOTO PROFIL (DIPERBAIKI) ---
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF2A475E),
                    // Logika: Jika photoUrl ada isinya, pakai NetworkImage. Jika tidak, pakai aset lokal.
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl) as ImageProvider
                        : const AssetImage('assets/images/user.png'),
                  ),
                  // ---------------------------------------

                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  // --- ARKYN WALLET CARD (STEAM INSPIRED) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1F2B45), Color(0xFF151D2A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF354870), width: 1.5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.account_balance_wallet, color: Color(0xFF66C0F4), size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'ARKYN WALLET',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _showTopUpDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF66C0F4),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  'Top Up',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF354870), height: 24, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Wallet Balance', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(
                                'Rp ${walletBalance.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Top Up', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(
                                'Rp ${totalTopup.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Spent', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(
                                'Rp ${totalSpent.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ------------------------------------------

                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'About me',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2E3D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: double.infinity,
                      child: Text(
                        about,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      // Tunggu hasil edit, lalu refresh
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      _getUserInfo(); // Refresh tampilan setelah kembali
                    },
                    child: const Text(
                      'Edit profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadGameScreen(), // Tambah const jika bisa
                        ),
                      );
                    },
                    child: const Text(
                      'Upload Game',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF171A21),
          selectedItemColor: Colors.blue,
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
      ),
    );
  }
}