import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageBookings extends StatelessWidget {
  const ManageBookings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("bookings").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final data = b.data() as Map<String, dynamic>;
              final id = b.id;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("${data["hallName"]} • ${data["date"]}"),
                  subtitle: Text("${data["userEmail"]} • ${data["guests"]} guests"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance.collection("bookings").doc(id).update({
                        "status": data["status"] == "Pending" ? "Approved" : "Pending",
                      });
                    },
                    child: Text(data["status"] == "Pending" ? "Approve" : "Undo"),
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
