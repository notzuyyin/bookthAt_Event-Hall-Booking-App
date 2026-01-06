import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageHalls extends StatelessWidget {
  const ManageHalls({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Halls")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHallDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("halls").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final halls = snapshot.data!.docs;

          return ListView.builder(
            itemCount: halls.length,
            itemBuilder: (context, index) {
              final h = halls[index];
              final data = h.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data["name"] ?? "Unknown Hall"),
                  subtitle: Text(
                    "📍 ${data["location"]}\n💸 RM${data["price"]} • 👥 ${data["capacity"]} ppl",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showAddHallDialog(context, h.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("halls")
                              .doc(h.id)
                              .delete();
                        },
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

_showAddHallDialog(BuildContext context, [String? id, Map? existing]) {
  final name = TextEditingController(text: existing?["name"]);
  final location = TextEditingController(text: existing?["location"]);
  final price = TextEditingController(text: existing?["price"]?.toString());
  final capacity = TextEditingController(text: existing?["capacity"]?.toString());
  bool available = existing?["available"] ?? true;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(id == null ? "Add Hall" : "Edit Hall"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Hall Name"),
            ),
            TextField(
              controller: location,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price (RM)"),
            ),
            TextField(
              controller: capacity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Capacity"),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: available,
              onChanged: (v) {
                available = v;
              },
              title: const Text("Available for Booking"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            FirebaseFirestore.instance.collection("halls").doc(id).set({
              "name": name.text,
              "location": location.text,
              "price": int.tryParse(price.text) ?? 0,
              "capacity": int.tryParse(capacity.text) ?? 0,
              "available": available,
            }, SetOptions(merge: true));

            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
