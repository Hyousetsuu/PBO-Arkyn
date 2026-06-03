import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';

class PaymentScreen extends StatefulWidget {
  final ContentModel game;
  final String paymentMethod;

  const PaymentScreen({
    super.key,
    required this.game,
    required this.paymentMethod,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;
  String paymentStatus = 'Menunggu Pembayaran...';

  void _startPayment() async {
    setState(() {
      isLoading = true;
      paymentStatus = 'Pembayaran sedang diproses...';
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Simulasi delay gateway 2-3 detik
        await Future.delayed(const Duration(seconds: 2));

        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        // Transaction safety: Menambahkan game ke library & membuat history pembelian
        WriteBatch batch = FirebaseFirestore.instance.batch();
        
        batch.update(userDoc, {
          'library': FieldValue.arrayUnion([widget.game.id]),
        });

        DocumentReference purchaseDoc = userDoc.collection('purchases').doc();
        batch.set(purchaseDoc, {
          'gameId': widget.game.id,
          'gameTitle': widget.game.name,
          'price': widget.game.price,
          'paymentMethod': widget.paymentMethod,
          'purchaseDate': FieldValue.serverTimestamp(),
        });

        await batch.commit();

        setState(() {
          isLoading = false;
          paymentStatus = 'Pembayaran Berhasil!';
        });

        // Delay sedikit sebelum pop agar user sempat melihat status sukses
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          isLoading = false;
          paymentStatus = 'Error: Silahkan login terlebih dahulu.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        paymentStatus = 'Gagal memproses pembayaran: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text('Direct Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Game Summary Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF171A21),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A475E)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      widget.game.coverUrl,
                      width: 100,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 100, height: 60, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.game.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Developer: ${widget.game.developer}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Jumlah Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${widget.game.price.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 28, color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF2A475E)),
            const SizedBox(height: 20),
            
            const Text(
              'Metode Pembayaran Terpilih',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A475E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF66C0F4)),
              ),
              child: ListTile(
                leading: Icon(
                  widget.paymentMethod.contains('Transfer') ? Icons.account_balance : Icons.qr_code,
                  color: const Color(0xFF66C0F4),
                ),
                title: Text(widget.paymentMethod, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Simulasi Instan Gateway', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ),
            ),
            
            const Spacer(),
            const Divider(color: Color(0xFF2A475E)),
            const SizedBox(height: 15),
            
            isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF66C0F4)))
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _startPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF66C0F4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Bayar Sekarang',
                            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          paymentStatus,
                          style: TextStyle(
                            fontSize: 14,
                            color: paymentStatus.contains('Berhasil') ? Colors.greenAccent : Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
