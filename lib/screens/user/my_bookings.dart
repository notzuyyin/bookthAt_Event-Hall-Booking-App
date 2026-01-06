// lib/screens/user/my_bookings.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'booking_form.dart';

class MyBookings extends StatelessWidget {
  const MyBookings({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .where("userEmail", isEqualTo: email)
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No bookings yet. Make your first booking! 😊"),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final data = b.data() as Map<String, dynamic>;
              final isPending = data["status"] == "Pending";

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["hallName"],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      Text("📅 Date: ${data["date"]}"),
                      Text("👥 Guests: ${data["guests"]}"),
                      Text("💸 Price: RM ${data["price"]}"),
                      Text(
                        "🛠️ Services: ${(data["services"] != null && data["services"].isNotEmpty)
                            ? data["services"].join(", ")
                            : "None"}",
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Chip(
                            label: Text(data["status"]),
                            backgroundColor: data["status"] == "Pending"
                                ? Colors.orange.shade200
                                : Colors.green.shade200,
                          ),
                          const Spacer(),

                          /// ✏ EDIT
                          if (isPending)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingForm(
                                      hallName: data["hallName"],
                                      isEditing: true,
                                      bookingId: b.id,
                                      bookingData: data,
                                    ),
                                  ),
                                );
                              },
                            ),

                          /// ❌ DELETE
                          if (isPending)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Cancel Booking?"),
                                    content: const Text(
                                        "This action cannot be undone."),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("No")),
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection("bookings")
                                              .doc(b.id)
                                              .delete();

                                          Navigator.pop(context);
                                        },
                                        child: const Text("Yes, Cancel"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
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
