import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GenericWelcomeHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String subtitle;

  const GenericWelcomeHeader({
    super.key,
    this.title = 'Hallo daar!',
    this.subtitle = 'Scan je medicijn om te beginnen',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey6, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
              color: CupertinoColors.black,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;
}
