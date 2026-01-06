import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';
import '../auth/register.dart';
import '../user/browse_halls.dart';

class GuestHome extends StatelessWidget {
  const GuestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Hall Booking System"),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              /// 🎉 PAGE HEADER
              const SizedBox(height: 30),
              const Text(
                "Welcome! 🎉",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Browse halls, register and book your event space easily!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),

              /// 🔐 LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  label: const Text("Login"),
                ),
              ),

              const SizedBox(height: 15),

              /// 📝 REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.app_registration),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2D9CDB),
                    side: const BorderSide(color: Color(0xFF2D9CDB)),
                  ),
                  label: const Text("Register"),
                ),
              ),

              const SizedBox(height: 35),
              const Divider(thickness: 1),
              const SizedBox(height: 15),

              /// 🔽 GUEST OPTION TEXT
              const Text(
                "Continue as Guest 👇",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              /// 🏷️ VIEW HALLS AS GUEST
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.meeting_room),

                  // 🌟 IMPORTANT PART: FORCE LOGOUT BEFORE ENTER
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut(); // forced guest mode

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BrowseHalls()),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D9CDB),
                  ),
                  label: const Text("Browse Available Halls"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
