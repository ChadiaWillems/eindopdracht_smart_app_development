import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/scanner_screen.dart';
import 'package:medscan/services/firestore_service.dart';
import 'package:medscan/widgets/generic/generic_welcome_header.dart'; // Importeer je nieuwe widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            const GenericWelcomeHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestoreService.getMedicines(),
                builder: (context, snapshot) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
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
                                  color: const Color(
                                    0xFF1B5AEE,
                                  ).withOpacity(0.4),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
