import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/services/firestore_service.dart';

class MedicineScreen extends StatelessWidget {
  final String medicineName;

  const MedicineScreen({super.key, required this.medicineName});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Resultaat')),
      child: SafeArea(
        // Dit is de "Apple-manier" om tekststijl overal goed te krijgen:
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
                padding: const EdgeInsets.all(16),
                children: [
                  Text("Naam: ${data['name']}"),
                  Text("Sterkte: ${data['strength']} capsule"),
                  Text("Categorie: ${data['category']}"),
                  Text("Ochtend: ${data['morning']}"),
                  Text("Middag: ${data['afternoon']}"),
                  Text("Avond: ${data['evening']}"),
                  const SizedBox(height: 20),
                  const Text("Waarschuwingen:"),
                  // Simpele lijst van waarschuwingen
                  ...warnings.map((w) => Text("- $w")),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
