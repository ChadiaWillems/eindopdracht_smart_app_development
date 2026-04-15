import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/home_screen.dart';
import 'package:medscan/screens/login_screen.dart';
import 'package:medscan/services/firestore_service.dart';
import 'package:medscan/widgets/settings/settings_acount_tile.dart';
import 'package:medscan/widgets/settings/settings_switch_tile.dart';
import 'package:medscan/widgets/settings/settings_time_tile.dart';
import 'package:medscan/services/notification_service.dart';

import '../widgets/settings/settings_switch_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService =
      NotificationService(); // NIEUW
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _remindersEnabled = false;
  bool _soundsEnabled = true;

  String _morningTime = "08:00";
  String _afternoonTime = "13:00";
  String _eveningTime = "19:00";

  @override
  void initState() {
    super.initState();
    // Gebruik WidgetsBinding om te wachten tot het scherm er staat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapServices();
    });
  }

  // Een aparte functie die alles achter elkaar uitvoert
  Future<void> _bootstrapServices() async {
    try {
      print("Stap 1: Notificaties opstarten...");
      await _notificationService.init();

      print("Stap 2: Instellingen ophalen uit Firestore...");
      await _loadSettings();

      print("Klaar! Alles is gesynchroniseerd.");
    } catch (e) {
      print("Er ging iets mis bij het opstarten: $e");
    }
  }

  // NIEUW: Functie om de lokale notificaties te synchroniseren met je instellingen
  Future<void> _syncNotifications() async {
    if (!_remindersEnabled) {
      await _notificationService.cancelAll();
      return;
    }

    await _notificationService
        .cancelAll(); // Eerst schoonvegen om dubbelingen te voorkomen

    await _notificationService.scheduleDailyNotification(
      id: 1,
      title: "Morgen dosis",
      body: "Tijd voor je ochtend medicijnen!",
      timeStr: _morningTime,
    );
    await _notificationService.scheduleDailyNotification(
      id: 2,
      title: "Middag dosis",
      body: "Tijd voor je middag medicijnen!",
      timeStr: _afternoonTime,
    );
    await _notificationService.scheduleDailyNotification(
      id: 3,
      title: "Avond dosis",
      body: "Tijd voor je avond medicijnen!",
      timeStr: _eveningTime,
    );
  }

  Future<void> _loadSettings() async {
    if (uid.isEmpty) return;
    final snapshot = await _firestoreService.getNotificationSettings(uid);
    if (snapshot.exists) {
      final data = snapshot.data();
      setState(() {
        _remindersEnabled = data?['remindersEnabled'] ?? false;
        _soundsEnabled = data?['soundsEnabled'] ?? true;
        _morningTime = data?['morningTime'] ?? "08:00";
        _afternoonTime = data?['afternoonTime'] ?? "13:00";
        _eveningTime = data?['eveningTime'] ?? "19:00";
      });
      _syncNotifications(); // NIEUW: Na het laden direct inplannen
    }
  }

  DateTime _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return DateTime.now().copyWith(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        second: 0,
        millisecond: 0,
      );
    } catch (e) {
      // Fallback naar 08:00 als de string corrupt is
      return DateTime.now().copyWith(hour: 8, minute: 0);
    }
  }

  // Voeg 'String currentName' toe als parameter
  void _showEditProfileDialog(String currentName) {
    final TextEditingController nameController = TextEditingController(
      // Als de naam 'Laden...' is, tonen we een lege string, anders de echte naam
      text: currentName == 'Laden...' ? "" : currentName,
    );

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Profiel bewerken"),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: nameController,
            placeholder: "Je naam",
            textCapitalization: TextCapitalization.words,
            autofocus: true, // Zorgt dat het toetsenbord direct opent
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Annuleer"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Opslaan"),
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await _firestoreService.updateUserProfile(uid, {
                  'name': nameController.text.trim(),
                });
                setState(() {}); // Hiermee ververs je de FutureBuilder
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return SettingsAcountTile(
        name: 'Gast',
        email: 'Tik om in te loggen',
        onTap: () {
          Navigator.of(
            context,
          ).push(CupertinoPageRoute(builder: (context) => const LoginScreen()));
        },
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _firestoreService.getUserProfile(user.uid),
      builder: (context, snapshot) {
        String name = 'Laden...';
        String email = user.email ?? 'Geen e-mail';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          name = data?['name'] ?? 'Gebruiker';
        }
        return SettingsAcountTile(
          name: name,
          email: email,
          onTap: () => _showEditProfileDialog(name),
        );
      },
    );
  }

  Future<void> _deleteUserAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Stop alle meldingen op de iPhone
      await _notificationService.cancelAll();

      // 2. Verwijder de data uit Firestore
      await _firestoreService.deleteUserProfile(user.uid);

      // 3. Verwijder de gebruiker uit Firebase Auth
      await user.delete();

      // 4. Stuur terug naar login scherm en wis de navigatie geschiedenis
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showErrorAlert(
          "Beveiligingsregel: Je moet opnieuw inloggen voordat je je account kunt verwijderen.",
        );
      } else {
        _showErrorAlert("Er ging iets mis: ${e.message}");
      }
    } catch (e) {
      _showErrorAlert("Fout: $e");
    }
  }

  // Hulpfunctie voor foutmeldingen
  void _showErrorAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Fout"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Account verwijderen?"),
        content: const Text(
          "Weet je het zeker? Al je medicatie-instellingen en herinneringen worden definitief gewist. Dit kan niet ongedaan worden gemaakt.",
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Annuleer"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true, // Maakt de tekst rood
            child: const Text("Verwijder account"),
            onPressed: () async {
              await _deleteUserAccount();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Notificaties',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // --- Switch: Herinneringen ---
          SettingsSwitchTile(
            title: "Herinneringen",
            subtitle: "Krijg herinneringen voor medicijnen", // Toegevoegd
            icon: CupertinoIcons.bell_fill, // Toegevoegd
            iconColor: CupertinoColors.systemBlue, // Toegevoegd
            value: _remindersEnabled,
            onChanged: (bool newValue) async {
              setState(() => _remindersEnabled = newValue);
              await _firestoreService.updateNotificationSettings(uid, {
                'remindersEnabled': newValue,
              });
              await _syncNotifications();
            },
          ),

          // --- Switch: Geluid ---
          SettingsSwitchTile(
            title: "Geluid",
            subtitle: "Geluid bij herinneringen",
            icon: CupertinoIcons.speaker_2_fill,
            iconColor: CupertinoColors.systemBlue,
            value: _soundsEnabled,
            onChanged: (bool newValue) async {
              setState(() => _soundsEnabled = newValue);
              await _firestoreService.updateNotificationSettings(uid, {
                'soundsEnabled': newValue,
              });
              await _syncNotifications();
            },
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Herinnerings tijden',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // --- Tijd: Ochtend ---
          SettingsTimeTile(
            title: 'Ochtend dosis',
            icon: CupertinoIcons.sun_dust_fill, // Toegevoegd
            iconColor: CupertinoColors.systemOrange, // Toegevoegd
            time: _parseTimeString(_morningTime),
            onTimeChanged: (DateTime newTime) async {
              String formatted =
                  "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}";
              setState(() => _morningTime = formatted);
              await _firestoreService.updateNotificationSettings(uid, {
                'morningTime': formatted,
              });
              await _syncNotifications();
            },
          ),

          // --- Tijd: Middag ---
          SettingsTimeTile(
            title: 'Middag dosis',
            icon: CupertinoIcons.sun_max_fill, // Toegevoegd
            iconColor: CupertinoColors.systemYellow, // Toegevoegd
            time: _parseTimeString(_afternoonTime),
            onTimeChanged: (DateTime newTime) async {
              String formatted =
                  "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}";
              setState(() => _afternoonTime = formatted);
              await _firestoreService.updateNotificationSettings(uid, {
                'afternoonTime': formatted,
              });
              await _syncNotifications();
            },
          ),

          // --- Tijd: Avond ---
          SettingsTimeTile(
            title: 'Avond dosis',
            icon: CupertinoIcons.moon_stars_fill, // Toegevoegd
            iconColor: CupertinoColors.systemIndigo, // Toegevoegd
            time: _parseTimeString(_eveningTime),
            onTimeChanged: (DateTime newTime) async {
              String formatted =
                  "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}";
              setState(() => _eveningTime = formatted);
              await _firestoreService.updateNotificationSettings(uid, {
                'eveningTime': formatted,
              });
              await _syncNotifications();
            },
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Account instellingen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          _buildAccountTile(),

          if (FirebaseAuth.instance.currentUser != null)
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text(
                    'Uitloggen',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                  leading: const Icon(
                    CupertinoIcons.square_arrow_right,
                    color: CupertinoColors.destructiveRed,
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();

                    if (mounted) {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushAndRemoveUntil(
                        CupertinoPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
                CupertinoListTile(
                  title: const Text(
                    'Account verwijderen',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                  leading: const Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.destructiveRed,
                  ),
                  onTap: () =>
                      _showDeleteAccountDialog(), // We maken deze functie zo
                ),
              ],
            ),
        ],
      ),
    );
  }
}
