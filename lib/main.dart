import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignInScreen(), // Halaman utama adalah SignInScreen
      routes: {
        '/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
      },
    );
  }
}
