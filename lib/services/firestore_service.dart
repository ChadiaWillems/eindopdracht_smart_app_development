import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirestoreService._internal();
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _rootPath = "medscan/59I6fSeQApRy4CpeKLGHGJoR3D23";

  Stream<QuerySnapshot<Map<String, dynamic>>> getMedicines() {
    return _db.collection("$_rootPath/medicines").snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getMedicineById(String id) {
    return _db.collection("$_rootPath/medicines").doc(id).get();
  }

  Future<void> createUserProfile(String uid, String name, String email) async {
    await _db.collection('$_rootPath/users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('$_rootPath/users').doc(uid).get();
  }

  Future<void> addMedicineToUserSchedule({
    required String medicineName,
    required Map<String, dynamic> medicineData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userScheduleColl = _db
        .collection('$_rootPath/users')
        .doc(user.uid)
        .collection('schedule');

    final periods = ['morning', 'afternoon', 'evening'];

    for (var period in periods) {
      int amount = medicineData[period] ?? 0;

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

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserSchedule(
    String uid,
    String moment,
  ) {
    return _db
        .collection('$_rootPath/users')
        .doc(uid)
        .collection('schedule')
        .doc(moment)
        .snapshots();
  }

  Future<void> toggleDoseInArray(
    String uid,
    String moment,
    int index,
    List currentItems,
  ) async {
    List updatedItems = List.from(currentItems);
    updatedItems[index]['isTaken'] = !updatedItems[index]['isTaken'];

    await _db
        .collection('$_rootPath/users')
        .doc(uid)
        .collection('schedule')
        .doc(moment)
        .update({'items': updatedItems});
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getScheduleMoment(
    String uid,
    String moment,
  ) {
    return _db
        .collection('$_rootPath/users')
        .doc(uid)
        .collection('schedule')
        .doc(moment)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getNotificationSettings(
    String uid,
  ) {
    return _db
        .collection('$_rootPath/users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .get();
  }

  Future<void> updateNotificationSettings(
    String uid,
    Map<String, dynamic> data,
  ) {
    return _db
        .collection('$_rootPath/users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .set(data, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getNotificationSettingsStream(
    String uid,
  ) {
    return _db
        .collection('$_rootPath/users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .snapshots();
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return _db
        .collection('$_rootPath/users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteUserProfile(String uid) {
    return _db.collection('$_rootPath/users').doc(uid).delete();
  }

  Future<void> removeMedicineFromSchedule(
    String uid,
    String moment,
    int index,
    List items,
  ) async {
    List updatedItems = List.from(items);
    updatedItems.removeAt(index);

    return _db
        .collection('$_rootPath/users')
        .doc(uid)
        .collection('schedule')
        .doc(moment)
        .update({'items': updatedItems});
  }
}
