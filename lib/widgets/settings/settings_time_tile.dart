import 'package:flutter/cupertino.dart';

class SettingsTimeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final DateTime time;
  final ValueChanged<DateTime> onTimeChanged;

  const SettingsTimeTile({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.time,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      backgroundColor: CupertinoColors.white,
      leadingSize: 42,
      leadingToTitle: 12,
      title: Text(title),
      leading: Icon(icon, color: iconColor),
      trailing: Text(
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
        style: CupertinoTheme.of(context).textTheme.textStyle,
      ),
      onTap: () async {
        print('Tapped on $title tile');
        print('tijd verandern: ${time.hour}:${time.minute}');
      },
    );
  }
}
