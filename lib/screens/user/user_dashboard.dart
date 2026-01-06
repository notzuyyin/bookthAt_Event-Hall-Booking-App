import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login.dart';
import 'my_bookings.dart';
import 'browse_halls.dart';


class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Loading indicator
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              await FirebaseAuth.instance.signOut();
              await Future.delayed(const Duration(milliseconds: 200));

              Navigator.pop(context); // close loading dialog

              // Force navigation to login screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${currentUser?.email ?? "User"} 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),


            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MyBookings()));
              },
              child: const Text("My Bookings"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BrowseHalls()));
              },
              child: const Text("Browse Halls"),
            ),
          ],
        ),
      ),
    );
  }
}
