import 'package:flutter/cupertino.dart';
import 'package:medscan/screens/home_screen.dart';
import 'package:medscan/widgets/generic/generic_header.dart';

class GenericBottomNav extends StatelessWidget {
  const GenericBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
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
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (BuildContext context) {
                return const HomeScreen();
              },
            );
          case 1:
            return CupertinoPageScaffold(
              navigationBar: GenericHeader(),
              child: Center(child: Text('Schedule Tab')),
            );
          case 2:
            return CupertinoPageScaffold(
              navigationBar: GenericHeader(),
              child: Center(child: Text('Settings Tab')),
            );
          default:
            return CupertinoPageScaffold(
              navigationBar: GenericHeader(),
              child: Center(child: Text('Unknown Tab')),
            );
        }
      },
    );
  }
}
