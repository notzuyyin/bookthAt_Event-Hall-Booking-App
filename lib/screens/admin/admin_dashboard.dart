import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login.dart';
import 'manage_halls.dart';
import 'manage_bookings.dart';
import 'manage_users.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(milliseconds: 300));

    if (Navigator.canPop(context)) Navigator.pop(context);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Widget adminButton(BuildContext context, IconData icon, String label, Widget page) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color(0xFF2D9CDB),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: "Logout",
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Admin 👑",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            adminButton(context, Icons.meeting_room, "Manage Halls", const ManageHalls()),
            const SizedBox(height: 10),

            adminButton(context, Icons.book_online, "Manage Bookings", const ManageBookings()),
            const SizedBox(height: 10),

            adminButton(context, Icons.people, "Manage Users", const ManageUsers()),
          ],
        ),
      ),
    );
  }
}
