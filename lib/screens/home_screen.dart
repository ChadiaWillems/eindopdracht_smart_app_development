import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/scanner_screen.dart';
import 'package:medscan/services/firestore_service.dart';
import 'package:medscan/widgets/generic/generic_header.dart';
import 'package:medscan/widgets/generic/generic_welcome_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    return CupertinoPageScaffold(
      navigationBar: const GenericHeader(),
      child: SafeArea(
        child: Column(
          children: [
            const GenericWelcomeHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("Knop ingedrukt! Navigeren naar Scanner...");
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const ScannerScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1B5AEE),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B5AEE).withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              CupertinoIcons.camera_fill,
                              size: 70,
                              color: CupertinoColors.white,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Scan medicijn',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      child: const Text(
                        'Tap om te scannen',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
