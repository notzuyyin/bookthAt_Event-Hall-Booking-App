import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_form.dart';

class BrowseHalls extends StatefulWidget {
  const BrowseHalls({super.key});

  @override
  State<BrowseHalls> createState() => _BrowseHallsState();
}

class _BrowseHallsState extends State<BrowseHalls> {
  String searchText = "";
  double maxPrice = 10000;
  int minCapacity = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse Halls"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// 🔍 Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search hall name...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => searchText = value.toLowerCase());
                  },
                ),

                const SizedBox(height: 10),

                /// 🎚 Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: "Min Capacity",
                          border: OutlineInputBorder(),
                        ),
                        value: minCapacity,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text("Any")),
                          DropdownMenuItem(value: 50, child: Text("50+")),
                          DropdownMenuItem(value: 100, child: Text("100+")),
                          DropdownMenuItem(value: 200, child: Text("200+")),
                        ],
                        onChanged: (value) {
                          setState(() => minCapacity = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: DropdownButtonFormField<double>(
                        decoration: const InputDecoration(
                          labelText: "Max Price",
                          border: OutlineInputBorder(),
                        ),
                        value: maxPrice,
                        items: const [
                          DropdownMenuItem(value: 10000, child: Text("Any")),
                          DropdownMenuItem(value: 3000, child: Text("≤ RM3000")),
                          DropdownMenuItem(value: 5000, child: Text("≤ RM5000")),
                          DropdownMenuItem(value: 8000, child: Text("≤ RM8000")),
                        ],
                        onChanged: (value) {
                          setState(() => maxPrice = value!);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("halls").snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final halls = snap.data!.docs.where((doc) {
            final hall = doc.data() as Map<String, dynamic>;
            final name = hall["name"]?.toString().toLowerCase() ?? "";
            final capacity = hall["capacity"] ?? 0;
            final price = hall["price"] ?? 0;
            return name.contains(searchText) &&
                capacity >= minCapacity &&
                price <= maxPrice;
          }).toList();

          if (halls.isEmpty) {
            return const Center(
              child: Text(
                "No halls match your filters 😢",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: halls.length,
            itemBuilder: (context, i) {
              final hall = halls[i].data() as Map<String, dynamic>;
              final name = hall["name"] ?? "Unnamed Hall";
              final imageUrl = hall["imageUrl"] ?? "";

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 📸 Hall Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        height: 170,
                        color: Colors.grey.shade300,
                        child: const Center(child: Text("No Image Available")),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text("📍 ${hall["location"]}"),
                          Text("💺 Capacity: ${hall["capacity"]} people"),
                          Text("💸 RM ${hall["price"]}"),

                          Text(
                            hall["available"] == true
                                ? "🟢 Available"
                                : "🔴 Not Available",
                            style: TextStyle(
                              color: hall["available"] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// 🛑 BOOKING BUTTON LOGIC
                          Align(
                            alignment: Alignment.centerRight,
                            child: () {
                              // 🚫 If guest → show text only
                              if (user == null) {
                                return const Text(
                                  "Login to book",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                );
                              }

                              // 🎯 If logged in → show button
                              return ElevatedButton(
                                onPressed: hall["available"] == true
                                    ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookingForm(hallName: name),
                                    ),
                                  );
                                }
                                    : null,
                                child: const Text("Book Now"),
                              );
                            }(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
