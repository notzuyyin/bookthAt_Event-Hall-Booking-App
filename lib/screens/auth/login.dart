import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/admin_dashboard.dart';
import '../user/user_dashboard.dart';
import '../guest/guest_home.dart';
import '../auth/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> loginUser() async {
    setState(() => loading = true);

    try {
      /// 1️⃣ Firebase Auth Login
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) throw Exception("User is null");

      final email = user.email!;

      /// 2️⃣ Fetch user record from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(email)
          .get();

      /// 3️⃣ If record doesn't exist → create it
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection("users").doc(email).set({
          "email": email,
          "disabled": false,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      /// 4️⃣ Check disabled status
      if (userDoc.exists && userDoc.data()?['disabled'] == true) {
        await FirebaseAuth.instance.signOut();
        throw FirebaseAuthException(
          code: "account-disabled",
          message: "🚫 This account has been disabled by an admin.",
        );
      }

      ///  5️⃣ Route: Admin or User
      if (email == "admin@gmail.com") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserDashboard()),
        );
      }

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Login Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Something went wrong: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: loginUser,
              child: const Text("Login"),
            ),

            const SizedBox(height: 20),

            ///  FIXED BUTTON — DIRECT NAVIGATION
            TextButton(
              child: const Text("Create new account"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
