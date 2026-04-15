import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/home_screen.dart';
import 'package:medscan/screens/login_screen.dart';
import 'package:medscan/screens/schedule_screen.dart';
import 'package:medscan/screens/settings_screen.dart';

class GenericBottomNav extends StatefulWidget {
  const GenericBottomNav({super.key});

  @override
  State<GenericBottomNav> createState() => _GenericBottomNavState();
}

class _GenericBottomNavState extends State<GenericBottomNav> {
  @override
  void initState() {
    super.initState();
    // LUISTEREN: Zodra de login-status verandert, teken de hele bar + schermen opnieuw
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        // Gebruik CupertinoTabView zodat elke tab zijn eigen "stapel" heeft
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const HomeScreen(); // De TabBar blijft hieronder staan
              case 1:
                return user == null
                    ? const LoginScreen()
                    : const ScheduleScreen();
              case 2:
                return const SettingsScreen();
              default:
                return const HomeScreen();
            }
          },
        );
      },
    );
  }
}
