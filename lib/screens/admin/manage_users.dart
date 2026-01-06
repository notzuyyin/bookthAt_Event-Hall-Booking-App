import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUsers extends StatelessWidget {
  const ManageUsers({super.key});

  /// 🔁 RESET PASSWORD
  Future<void> sendResetEmail(String email, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(email).get();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(email)
          .get()
          .then((doc) async {
        if (doc.exists) {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("📩 Reset link sent to $email")),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  /// ❌ DISABLE ACCOUNT
  Future<void> disableUser(String email, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(email)
          .update({"disabled": true});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚫 User disabled: $email")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  /// ♻️ ENABLE ACCOUNT AGAIN
  Future<void> enableUser(String email, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(email)
          .update({"disabled": false});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ User enabled: $email")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("No users registered yet."));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final email = user["email"] ?? "Unknown";
              final disabled = user["disabled"] == true;

              if (email == "admin@gmail.com") return const SizedBox(); // hide admin

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: disabled ? Colors.grey : Colors.black,
                  ),
                  title: Text(email),

                  subtitle: Text(
                    disabled ? "🚫 Account Disabled" : "🟢 Active",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: disabled ? Colors.red : Colors.green),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Reset Password
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.blue),
                        onPressed: () => sendResetEmail(email, context),
                      ),

                      /// Disable / Enable user
                      IconButton(
                        icon: Icon(
                          disabled ? Icons.lock_open : Icons.lock,
                          color: disabled ? Colors.green : Colors.red,
                        ),
                        onPressed: () => disabled
                            ? enableUser(email, context)
                            : disableUser(email, context),
                        tooltip:
                        disabled ? "Enable Account" : "Disable Account",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
