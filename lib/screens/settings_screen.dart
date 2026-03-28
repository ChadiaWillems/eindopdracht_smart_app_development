import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/login_screen.dart';
import 'package:medscan/services/firestore_service.dart';
import 'package:medscan/widgets/settings/settings_switch_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 1. Hier maak je de variabele aan (standaard op false)
  bool _remindersEnabled = false;
  bool _soundsEnabled = true;

  final FirestoreService _firestoreService = FirestoreService();
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // 2. Optioneel: haal hier de beginwaarde op uit Firestore
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Hier zou je een get-aanroep kunnen doen naar je settings document
    // om de switch direct goed te zetten als Peter het scherm opent.
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: ListView(
        children: [
          CupertinoListSection.insetGrouped(
            header: const Text('Notificatie instellingen'),
            children: [
              // 3. Gebruik de variabele in je tile
              SettingsSwitchTile(
                title: "Herinneringen",
                subtitle:
                    "Krijg herinneringen voor medicijnen die je moet nemen",
                icon: CupertinoIcons.bell_fill,
                iconColor: CupertinoColors.systemBlue,
                value: _remindersEnabled, // <--- Hier leest hij de waarde
                onChanged: (bool newValue) async {
                  // 4. Update de UI direct (de switch klapt om)
                  setState(() {
                    _remindersEnabled = newValue;
                  });

                  // 5. Sla het op in de DB
                  await _firestoreService.updateNotificationSettings(uid, {
                    'remindersEnabled': newValue,
                  });
                },
              ),
              // Doe hetzelfde voor Sounds...
            ],
          ),
          if (FirebaseAuth.instance.currentUser != null)
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Uitloggen'),
                  leading: const Icon(CupertinoIcons.square_arrow_right),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    // Na uitloggen wil je misschien terug naar het home scherm of een login scherm tonen
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          if (FirebaseAuth.instance.currentUser == null)
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Inloggen'),
                  leading: const Icon(CupertinoIcons.person_crop_circle_fill),
                  onTap: () async {
                    // Navigeer naar het Login scherm
                    await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                    setState(() {});
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
