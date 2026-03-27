import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getMedicines() {
    return db
        .collection("medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/medicines")
        .snapshots();
  }
}
