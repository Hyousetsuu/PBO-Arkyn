import 'package:flutter/material.dart';

class DeveloperFundsPage extends StatefulWidget {
  const DeveloperFundsPage({Key? key}) : super(key: key);

  @override
  State<DeveloperFundsPage> createState() => _DeveloperFundsPageState();
}

class _DeveloperFundsPageState extends State<DeveloperFundsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF192030),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF253044),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Label "Developer"
              const Text(
                'Developer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Developer Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF253044),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Developer Logo
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Text(
                          'SP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Fund Info & Transfer Button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rp. 50.000.000',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Rp. 50.000.000',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Aksi transfer
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                            ),
                            child: const Text('Transfer Funds'),
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
      ),
    );
  }
}
