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
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => Container(
            height: 250,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                Container(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      child: const Text('Klaar'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: time,
                    use24hFormat: true,
                    onDateTimeChanged: onTimeChanged,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
