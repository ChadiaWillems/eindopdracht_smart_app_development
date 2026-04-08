import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getMedicines() {
    return db
        .collection("medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/medicines")
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getMedicineById(String id) {
    return db
        .collection("medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/medicines")
        .doc(id)
        .get();
  }

  Future<void> createUserProfile(String uid, String name, String email) async {
    await db
        .collection('medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/users')
        .doc(uid)
        .set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return db
        .collection('medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/users')
        .doc(uid)
        .get();
  }

  Future<void> addMedicineToUserSchedule({
    required String medicineName,
    required Map<String, dynamic> medicineData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userScheduleColl = db
        .collection('medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/users')
        .doc(user.uid)
        .collection('schedule');

    // De drie dagdelen die we controleren
    final periods = ['morning', 'afternoon', 'evening'];

    for (var period in periods) {
      int amount = medicineData[period] ?? 0;

      // Alleen toevoegen als het aantal groter is dan 0
      if (amount > 0) {
        await userScheduleColl.doc(period).set({
          'items': FieldValue.arrayUnion([
            {
              'name': medicineName,
              'amount': amount,
              'strength': medicineData['strength'] ?? '',
              'isTaken': false,
            },
          ]),
        }, SetOptions(merge: true));
      }
    }
  }

  // get user schedule stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserSchedule(
    String uid,
    String moment,
  ) {
    return db
        .collection('medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/users')
        .doc(uid)
        .collection('schedule')
        .doc(moment) // morning, afternoon, evening
        .snapshots();
  }

  // toggle isTaken in schedule array
  Future<void> toggleDoseInArray(
    String uid,
    String moment,
    int index,
    List currentItems,
  ) async {
    List updatedItems = List.from(currentItems);
    updatedItems[index]['isTaken'] = !updatedItems[index]['isTaken'];

    await db
        .collection('medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/users')
        .doc(uid)
        .collection('schedule')
        .doc(moment)
        .update({'items': updatedItems});
  }

  // Deze functie geeft een 'Stream' terug.
  // Dat betekent dat de app live blijft luisteren naar veranderingen in dat document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getScheduleMoment(
    String uid,
    String moment,
  ) {
    return db
        .collection('medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/users')
        .doc(uid)
        .collection('schedule')
        .doc(moment) // Hier vullen we 'morning', 'afternoon' of 'evening' in
        .snapshots(); // .snapshots() zorgt voor de live verbinding
  }

  // Haal alle instellingen op
  Future<DocumentSnapshot<Map<String, dynamic>>> getNotificationSettings(
    String uid,
  ) {
    return db
        .collection('medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .get();
  }

  // Update de instellingen (werkt voor zowel bools als strings)
  Future<void> updateNotificationSettings(
    String uid,
    Map<String, dynamic> data,
  ) {
    return db
        .collection('medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .set(data, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getNotificationSettingsStream(String uid) {
  return db
      .collection('medscan/59I6fSeQApRy4CpeKLGHGJoR3D23/users')
      .doc(uid)
      .collection('settings')
      .doc('notifications')
      .snapshots(); 
}
}
