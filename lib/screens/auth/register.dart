import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> registerUser() async {
    setState(() => loading = true);

    try {
      // 1️⃣ Create user in Firebase Auth
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2️⃣ Save user data in Firestore for Admin Management
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.user!.email)
          .set({
        "email": user.user!.email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Account created successfully!")),
      );

      Navigator.pop(context); // back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : registerUser,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
