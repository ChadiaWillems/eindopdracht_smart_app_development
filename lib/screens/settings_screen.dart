import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/login_screen.dart';
import 'package:medscan/services/firestore_service.dart';
import 'package:medscan/widgets/settings/settings_acount_tile.dart';
import 'package:medscan/widgets/settings/settings_switch_tile.dart';
import 'package:medscan/widgets/settings/settings_time_tile.dart';

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

  Widget _buildAccountTile() {
    final user = FirebaseAuth.instance.currentUser;

    // Als de gebruiker niet is ingelogd, tonen we direct de gast-versie
    if (user == null) {
      return const SettingsAcountTile(name: 'Gast', email: 'Niet ingelogd');
    }

    // Als er wel een gebruiker is, halen we de naam uit Firestore
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _firestoreService.getUserProfile(user.uid),
      builder: (context, snapshot) {
        String name = 'Laden...';
        String email = user.email ?? 'Geen e-mail';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          name = data?['name'] ?? 'Gebruiker';
        }

        return SettingsAcountTile(name: name, email: email);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: ListView(
        children: [
          Text(
            'Notificaties',
            style: CupertinoTheme.of(
              context,
            ).textTheme.navTitleTextStyle.copyWith(fontSize: 20),
          ),
          SizedBox(height: 8),
          SettingsSwitchTile(
            title: "Herinneringen",
            subtitle: "Krijg herinneringen voor medicijnen die je moet nemen",
            icon: CupertinoIcons.bell_fill,
            iconColor: CupertinoColors.systemBlue,
            value: _remindersEnabled,
            onChanged: (bool newValue) async {
              setState(() {
                _remindersEnabled = newValue;
              });
              await _firestoreService.updateNotificationSettings(uid, {
                'remindersEnabled': newValue,
              });
            },
          ),
          SizedBox(height: 12),
          SettingsSwitchTile(
            title: "Geluid",
            subtitle: "Krijg geluiden voor medicijnen die je moet nemen",
            icon: CupertinoIcons.bell_fill,
            iconColor: CupertinoColors.systemBlue,
            value: _soundsEnabled,
            onChanged: (bool newValue) async {
              setState(() {
                _soundsEnabled = newValue;
              });
              await _firestoreService.updateNotificationSettings(uid, {
                'soundsEnabled': newValue,
              });
            },
          ),
          SizedBox(height: 20),
          Text(
            'Herinnerings tijden',
            style: CupertinoTheme.of(
              context,
            ).textTheme.navTitleTextStyle.copyWith(fontSize: 20),
          ),
          SizedBox(height: 8),
          SettingsTimeTile(
            title: 'Morgen dosis',
            icon: CupertinoIcons.bell_fill,
            iconColor: CupertinoColors.systemBlue,
            time: DateTime.now().copyWith(hour: 8, minute: 0),
            onTimeChanged: (DateTime newTime) {
              // Handle time change
            },
          ),
          SizedBox(height: 12),
          SettingsTimeTile(
            title: 'Middag dosis',
            icon: CupertinoIcons.bell_fill,
            iconColor: CupertinoColors.systemBlue,
            time: DateTime.now().copyWith(hour: 12, minute: 0),
            onTimeChanged: (DateTime newTime) {
              // Handle time change
            },
          ),
          SizedBox(height: 12),
          SettingsTimeTile(
            title: 'Avond Dosis',
            icon: CupertinoIcons.bell_fill,
            iconColor: CupertinoColors.systemBlue,
            time: DateTime.now().copyWith(hour: 18, minute: 0),
            onTimeChanged: (DateTime newTime) {
              // Handle time change
            },
          ),
          SizedBox(height: 20),
          Text(
            'Account instellingen',
            style: CupertinoTheme.of(
              context,
            ).textTheme.navTitleTextStyle.copyWith(fontSize: 20),
          ),
          SizedBox(height: 8),
          _buildAccountTile(),
          if (FirebaseAuth.instance.currentUser != null)
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Uitloggen'),
                  leading: const Icon(CupertinoIcons.square_arrow_right),
                  // TODO: icon rood maken
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    // TODO: navigeren naar home_screen
                    // if (mounted) {
                    //   Navigator.pop(context);
                    // }
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
