import 'package:flutter/cupertino.dart';
import 'package:medscan/providers/auth_provider.dart';
import 'package:medscan/screens/scanner_screen.dart';
import 'package:medscan/widgets/generic/generic_header.dart';
import 'package:medscan/widgets/generic/generic_welcome_header.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return CupertinoPageScaffold(
      navigationBar: const GenericHeader(),
      child: SafeArea(
        child: Column(
          children: [
            GenericWelcomeHeader(userName: auth.userName),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("Knop ingedrukt! Navigeren naar Scanner...");
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
                              color: const Color(0xFF1B5AEE).withOpacity(0.4),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
