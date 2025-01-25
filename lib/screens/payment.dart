import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

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

    // Simulasi delay, misalnya melakukan transaksi
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isLoading = false;
      paymentStatus = 'Pembayaran Berhasil!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran Midtrans')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Jumlah Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rp 100.000,00',
              style: TextStyle(fontSize: 24, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPaymentMethodTile(
              title: 'Kartu Kredit / Debit',
              icon: Icons.credit_card,
            ),
            _buildPaymentMethodTile(
              title: 'Bank Transfer',
              icon: Icons.account_balance,
            ),
            _buildPaymentMethodTile(
              title: 'Indomaret',
              icon: Icons.store,
            ),
            const Divider(),
            const SizedBox(height: 15),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _startPayment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 40),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Menurunkan border radius
                          ),
                        ),
                        child: Text('Bayar Sekarang',
                            style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 10),
                      Text(paymentStatus, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(
      {required String title, required IconData icon}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Implement if needed for selecting payment method
      },
    );
  }
}
