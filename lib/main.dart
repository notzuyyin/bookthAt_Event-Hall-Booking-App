import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import 'screens/guest/guest_home.dart';
import 'screens/auth/login.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/user/user_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EventHallApp());
}

class EventHallApp extends StatelessWidget {
  const EventHallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🌈 GLOBAL THEME
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6FAFF),
        primaryColor: const Color(0xFF2D9CDB),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D9CDB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D9CDB),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      // 🚀 FIX: Start HERE (not AuthWrapper)
      home: const GuestHome(),
    );
  }
}

/// 🔁 Used AFTER login only
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        /// User NOT logged in → Go to Login
        if (!snapshot.hasData) return const LoginScreen();

        /// Check admin by email
        if (snapshot.data!.email == "admin@gmail.com") {
          return const AdminDashboard();
        }

        /// Regular user
        return const UserDashboard();
      },
    );
  }
}
