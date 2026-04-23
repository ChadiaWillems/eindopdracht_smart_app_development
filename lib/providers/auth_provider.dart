import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medscan/services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _userName;
  bool _isLoading = true;

  User? get user => _user;
  String get userName => _userName ?? "Daar";
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      _user = newUser;

      if (newUser != null) {
        // Als er een user is, haal direct de naam op uit Firestore
        await _fetchUserProfile(newUser.uid);
      } else {
        _userName = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await FirestoreService().getUserProfile(uid);
      if (doc.exists) {
        _userName = doc.data()?['name'];
      }
    } catch (e) {
      print("Fout bij ophalen profiel: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    // 1. Maak de gebruiker aan
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // 2. Maak direct het profiel aan in Firestore
    if (userCredential.user != null) {
      await FirestoreService().createUserProfile(
        userCredential.user!.uid,
        name,
        email,
      );
    }
    // De listener in de constructor van AuthProvider pikt de nieuwe user
    // daarna automatisch op en haalt de naam op!
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
