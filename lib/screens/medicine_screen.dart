import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/home_screen.dart';
import 'package:medscan/screens/login_screen.dart';
import 'package:medscan/screens/schedule_screen.dart';
import 'package:medscan/services/firestore_service.dart';
import 'package:medscan/widgets/generic/generic_button.dart';
import 'package:medscan/widgets/medicine/medicine_dosing_schedule_card.dart';
import 'package:medscan/widgets/medicine/medicine_header.dart';
import 'package:medscan/widgets/medicine/medicine_warnings.dart';

class MedicineScreen extends StatelessWidget {
  final String medicineName;

  const MedicineScreen({super.key, required this.medicineName});

  Future<void> _handleSaveToSchedule(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      await FirestoreService().addMedicineToUserSchedule(
        medicineName: medicineName,
        medicineData: data,
      );

      // Toon een bevestiging aan de gebruiker
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: CupertinoColors.activeGreen,
              size: 50,
            ),
            content: Text('$medicineName is toegevoegd aan je schema!'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Bekijk schema'),
                onPressed: () {
                  Navigator.pop(context); // Sluit de popup
                  Navigator.pop(context); // Ga terug uit het detail scherm
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const ScheduleScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Toon foutmelding als het misgaat
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Fout'),
            content: const Text(
              'Kon het medicijn niet opslaan. Probeer het later opnieuw.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showLoginRequiredPopup(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Inloggen vereist'),
        content: const Text(
          'Je moet ingelogd zijn om medicijnen aan je persoonlijke schema toe te voegen.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annuleren'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Inloggen'),
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const LoginScreen()),
              );

              final user = FirebaseAuth.instance.currentUser;
              // if (user != null && mounted) {
              //   // De gebruiker is nu ingelogd! Voer direct de opslag-functie uit.
              //   _handleSaveToSchedule();
              // }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Resultaat')),
      child: Stack(
        children: [
          SafeArea(
            child: DefaultTextStyle(
              style: CupertinoTheme.of(context).textTheme.textStyle,
              child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: firestoreService.getMedicineById(medicineName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Niet gevonden.'));
                  }

                  final data = snapshot.data!.data()!;
                  final List warnings = data['warnings'] ?? [];

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      MedicineHeader(
                        medicineName: medicineName,
                        strength: data['strength'] ?? '',
                        category: data['category'] ?? '',
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Doseringsschema",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MedicineDosingScheduleCard(
                            label: "Ochtend",
                            amount: data['morning'] ?? 0,
                            icon: CupertinoIcons.sun_max,
                          ),
                          MedicineDosingScheduleCard(
                            label: "Middag",
                            amount: data['afternoon'] ?? 0,
                            icon: CupertinoIcons.sun_haze,
                          ),
                          MedicineDosingScheduleCard(
                            label: "Avond",
                            amount: data['evening'] ?? 0,
                            icon: CupertinoIcons.moon,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      MedicineWarnings(warnings: List<String>.from(warnings)),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              // We voegen een witte achtergrond met een lichte schaduw toe zodat de knoppen goed opvallen
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.withOpacity(0.9),
                border: const Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. De Opslaan Knop (met de StreamBuilder die we net maakten)
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, snapshot) {
                        final bool isLoggedIn = snapshot.hasData;
                        return GenericButton(
                          label: 'Opslaan in schema',
                          onPressed: () async {
                            if (!isLoggedIn) {
                              _showLoginRequiredPopup(context);
                            } else {
                              final medicineDoc = await FirestoreService()
                                  .getMedicineById(medicineName);
                              if (medicineDoc.exists && context.mounted) {
                                _handleSaveToSchedule(
                                  context,
                                  medicineDoc.data()!,
                                );
                              }
                            }
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 8), // Wat ruimte tussen de knoppen
                    // 2. De Annuleren Knop
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Annuleren',
                        style: TextStyle(
                          color: CupertinoColors.destructiveRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        // Dit brengt de gebruiker direct terug naar de HomeScreen/Scanner
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
