import 'package:flutter/cupertino.dart';

class SettingsAcountTile extends StatelessWidget {
  final String name;
  final String email;

  const SettingsAcountTile({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                email,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          // arrow
          Spacer(),
          Icon(CupertinoIcons.forward, color: CupertinoColors.systemGrey),
        ],
      ),
    );
  }
}
