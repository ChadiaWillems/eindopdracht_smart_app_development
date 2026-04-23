import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/home_screen.dart';
import 'package:medscan/screens/login_screen.dart';
import 'package:medscan/screens/schedule_screen.dart';
import 'package:medscan/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:medscan/providers/auth_provider.dart';

class GenericBottomNav extends StatefulWidget {
  const GenericBottomNav({super.key});

  static CupertinoTabController controller = CupertinoTabController(
    initialIndex: 0,
  );

  @override
  State<GenericBottomNav> createState() => _GenericBottomNavState();
}

class _GenericBottomNavState extends State<GenericBottomNav> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isLoading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    final user = auth.user;

    return CupertinoTabScaffold(
      controller: GenericBottomNav.controller,
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
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const HomeScreen();
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
