  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
  import 'screens/sign_in_screen.dart';
  import 'screens/sign_up_screen.dart';
  import 'screens/home.dart';

  Future main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase initialization for Web and other platforms (Android/iOS)
    if (kIsWeb) {
      // Inisialisasi Firebase untuk Web
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDSLhr-ztYTdGouAgS0K4f9K9pr2c_V7Pw",
          appId: "1:914451946370:android:c02fe4058e72b6ba4dcd9b",
          messagingSenderId: "914451946370", // Saya bantu isi sender ID dari AppID Anda (bagian depan sebelum :)
          projectId: "arkyn-29edb",
          
          // --- TAMBAHKAN BARIS INI ---
          storageBucket: "arkyn-29edb.appspot.com", 
        ),
      );
    } else {
      // Inisialisasi Firebase untuk platform Android/iOS secara otomatis
      await Firebase.initializeApp();
    }

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
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Jika sedang loading (koneksi lambat)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Jika ada error
            if (snapshot.hasError) {
              return const Center(child: Text('Terjadi Kesalahan!'));
            }
            // Jika user sudah login (data ada) -> Masuk ke Home
            if (snapshot.hasData) {
              return const HomeScreen();
            }
            // Jika belum login -> Masuk ke SignIn
            return const SignInScreen();
          },
        ),
        routes: {
          '/signIn': (context) => const SignInScreen(),
          '/signUp': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
        },
      );
    }
  }
