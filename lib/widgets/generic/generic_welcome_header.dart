import 'package:flutter/cupertino.dart';

class GenericWelcomeHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String subtitle;
  final String userName;

  const GenericWelcomeHeader({
    super.key,
    this.subtitle = 'Scan je medicijn om te beginnen',
    this.userName = 'daar',
  });

  @override
  Widget build(BuildContext context) {
    final String firstName = userName.split(' ')[0];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey6, width: 1.0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle('Hallo $firstName!'),
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
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.8,
        color: CupertinoColors.black,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
