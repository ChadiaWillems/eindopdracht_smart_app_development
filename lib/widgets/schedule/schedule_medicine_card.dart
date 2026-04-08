import 'package:flutter/cupertino.dart';

class ScheduleMedicineCard extends StatelessWidget {
  final String medicineName;
  final String dosage;
  final bool isTaken;
  final VoidCallback onToggleTaken;

  const ScheduleMedicineCard({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.isTaken,
    required this.onToggleTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey6),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bovenste gedeelte
          CupertinoListTile(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              medicineName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: CupertinoColors.black,
              ),
            ),
            subtitle: Text(
              dosage + ' capsule',
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 13,
              ),
            ),
            trailing: Icon(
              isTaken
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              color: isTaken
                  ? CupertinoColors.activeGreen
                  : CupertinoColors.systemGrey4,
              size: 28,
            ),
            onTap: onToggleTaken,
          ),

          // De Cupertino variant van de Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: CupertinoColors.systemGrey6,
          ),

          // De "Mark as taken" knop (volledig Cupertino)
          Container(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              onPressed: onToggleTaken,
              child: Text(
                isTaken ? "Taken" : "Mark as taken",
                style: TextStyle(
                  color: isTaken
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.activeBlue,
                  fontWeight: isTaken ? FontWeight.w400 : FontWeight.w600,
                  fontSize: 14,
                  
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
