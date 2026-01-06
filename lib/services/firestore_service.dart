import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final halls = FirebaseFirestore.instance.collection("halls");
  final bookings = FirebaseFirestore.instance.collection("bookings");

  // Add hall
  Future addHall(Map<String, dynamic> data) => halls.add(data);

  // Update hall
  Future updateHall(String id, Map<String, dynamic> data) => halls.doc(id).update(data);

  // Delete hall
  Future deleteHall(String id) => halls.doc(id).delete();

  // Update booking status
  Future updateBooking(String id, String status) =>
      bookings.doc(id).update({"status": status});
}
