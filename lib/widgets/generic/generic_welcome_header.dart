import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/services/firestore_service.dart';

class GenericWelcomeHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String subtitle;

  const GenericWelcomeHeader({
    super.key,
    this.subtitle = 'Scan je medicijn om te beginnen',
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey6, width: 1.0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HIER KOMT JOUW LOGICA ---
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, authSnapshot) {
                if (!authSnapshot.hasData || authSnapshot.data == null) {
                  return _buildTitle('Hallo daar!');
                }

                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: _firestoreService.getUserProfile(
                    authSnapshot.data!.uid,
                  ),
                  builder: (context, profileSnapshot) {
                    if (profileSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildTitle('Hallo...');
                    }

                    final data = profileSnapshot.data?.data();
                    final String fullName = data?['name'] ?? 'Gebruiker';
                    final String firstName = fullName.split(' ')[0];

                    return _buildTitle('Hallo $firstName!');
                  },
                );
              },
            ),

            // --- EINDE LOGICA ---
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Klein hulpje voor de styling van de titel
  Widget _buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.8,
        color: CupertinoColors.black,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
