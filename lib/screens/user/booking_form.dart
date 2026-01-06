import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingForm extends StatefulWidget {
  final String hallName;
  final bool isEditing;
  final String? bookingId;
  final Map<String, dynamic>? bookingData;

  const BookingForm({
    super.key,
    required this.hallName,
    this.isEditing = false,
    this.bookingId,
    this.bookingData,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController guestsCtrl = TextEditingController();

  // Optional add-on services
  final Map<String, int> servicePrices = {
    "Catering": 300,
    "Sound System": 200,
    "Decoration": 500,
    "Photography": 400,
  };

  List<String> selectedServices = [];
  int baseHallPrice = 0;
  int totalPrice = 0;

  // Load hall base price
  Future<void> fetchHallPrice() async {
    final doc = await FirebaseFirestore.instance
        .collection("halls")
        .doc(widget.hallName)
        .get();

    if (doc.exists) {
      baseHallPrice = doc.data()!["price"];
      calculateTotal();
    }
  }

  void calculateTotal() {
    int addonCost = selectedServices.fold(0, (sum, s) => sum + servicePrices[s]!);
    setState(() {
      totalPrice = baseHallPrice + addonCost;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchHallPrice();

    // Prefill if editing
    if (widget.isEditing && widget.bookingData != null) {
      dateCtrl.text = widget.bookingData!["date"];
      guestsCtrl.text = widget.bookingData!["guests"].toString();
      selectedServices = List<String>.from(widget.bookingData!["services"]);
      calculateTotal();
    }
  }

  Future<void> saveBooking() async {
    if (dateCtrl.text.isEmpty || guestsCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please complete all fields")),
      );
      return;
    }

    final booking = {
      "hallName": widget.hallName,
      "date": dateCtrl.text,
      "guests": int.parse(guestsCtrl.text),
      "services": selectedServices,
      "price": totalPrice,
      "status": "Pending",
      "userEmail": FirebaseAuth.instance.currentUser?.email,
      "timestamp": FieldValue.serverTimestamp(),
    };

    if (widget.isEditing) {
      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(widget.bookingId)
          .update(booking);
    } else {
      await FirebaseFirestore.instance.collection("bookings").add(booking);
    }

    if (Navigator.canPop(context)) Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isEditing
            ? "Booking Updated Successfully! 🎉"
            : "Booking Submitted Successfully! 🎉"),
      ),
    );
  }

  // 📌 Confirmation Popup
  void showConfirmationDialog() {
    if (dateCtrl.text.isEmpty || guestsCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please enter date & guests")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Booking Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 Hall: ${widget.hallName}"),
            Text("📅 Date: ${dateCtrl.text}"),
            Text("👥 Guests: ${guestsCtrl.text}"),
            Text("🔧 Services: ${selectedServices.isEmpty ? "None" : selectedServices.join(", ")}"),
            const SizedBox(height: 8),
            Text("💸 Total Price: RM $totalPrice",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              saveBooking();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  // 📍 MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(widget.isEditing ? "Edit Booking" : "Book: ${widget.hallName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 📅 DATE PICKER
              TextField(
                controller: dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Booking Date",
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    dateCtrl.text = "${picked.year}-${picked.month}-${picked.day}";
                  }
                },
              ),
              const SizedBox(height: 15),

              // 👥 GUESTS
              TextField(
                controller: guestsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Number of Guests"),
              ),
              const SizedBox(height: 25),

              const Text("Additional Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // 🧩 SERVICE CHECKBOXES
              ...servicePrices.entries.map((s) {
                return CheckboxListTile(
                  title: Text("${s.key} (+RM ${s.value})"),
                  value: selectedServices.contains(s.key),
                  onChanged: (value) {
                    setState(() {
                      value!
                          ? selectedServices.add(s.key)
                          : selectedServices.remove(s.key);
                      calculateTotal();
                    });
                  },
                );
              }),

              const SizedBox(height: 25),

              // 💸 PRICE
              Text(
                "Total Price: RM $totalPrice",
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              // CONFIRM BUTTON
              ElevatedButton(
                onPressed: showConfirmationDialog,
                child: Text(
                    widget.isEditing ? "Update Booking" : "Review & Confirm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
