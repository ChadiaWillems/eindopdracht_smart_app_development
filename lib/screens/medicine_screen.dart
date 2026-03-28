import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/login_screen.dart';
import 'package:medscan/services/firestore_service.dart';
import 'package:medscan/widgets/generic/generic_button.dart';
import 'package:medscan/widgets/medicine/medicine_dosing_schedule_card.dart';
import 'package:medscan/widgets/medicine/medicine_header.dart';
import 'package:medscan/widgets/medicine/medicine_warnings.dart';

class MedicineScreen extends StatelessWidget {
  final String medicineName;

  const MedicineScreen({super.key, required this.medicineName});

  Future<void> _handleSaveToSchedule(Map<String, dynamic> data) async {
    try {
      // Gebruik nu de 'data' die we binnenkrijgen
      await FirestoreService().addMedicineToUserSchedule(
        medicineName: medicineName,
        medicineData: data,
      );
      print("Medicijn toegevoegd aan schema: $medicineName");

      // Optioneel: Toon hier een succes-berichtje
    } catch (e) {
      print("Fout bij toevoegen aan schema: $e");
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
              child: SafeArea(
                top: false,
                child: GenericButton(
                  label: 'Opslaan in schema',
                  onPressed: () async {
                    // Check of er een gebruiker is ingelogd
                    final User? user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      // NIET ingelogd -> Toon de popup
                      print("Gebruiker is NIET ingelogd");
                      _showLoginRequiredPopup(context);
                    } else {
                      final medicineDoc = await FirestoreService()
                          .getMedicineById(medicineName);
                      if (medicineDoc.exists) {
                        _handleSaveToSchedule(medicineDoc.data()!);
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
