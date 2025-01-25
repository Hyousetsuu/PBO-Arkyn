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
        options: FirebaseOptions(
          apiKey:
              "AIzaSyDSLhr-ztYTdGouAgS0K4f9K9pr2c_V7Pw", // Ganti dengan apiKey Anda
          appId:
              "1:914451946370:android:c02fe4058e72b6ba4dcd9b", // Ganti dengan appId Anda
          messagingSenderId: "", // Ganti dengan messagingSenderId Anda
          projectId: "arkyn-29edb", // Ganti dengan projectId Anda
          // Option lain sesuai kebutuhan
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
        home: const SignInScreen(), // Halaman utama adalah SignInScreen
        routes: {
          '/signIn': (context) => const SignInScreen(),
          '/signUp': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
        },
      );
    }
  }
