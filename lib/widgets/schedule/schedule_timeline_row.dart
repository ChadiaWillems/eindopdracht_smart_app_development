import 'package:flutter/cupertino.dart';

class ScheduleTimelineRow extends StatelessWidget {
  final String time;
  final IconData icon;
  final Widget medicineCard;
  final bool isLast; // Belangrijk: om de lijn bij de laatste pil te stoppen

  const ScheduleTimelineRow({
    super.key,
    required this.time,
    required this.icon,
    required this.medicineCard,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight( // Zorgt dat de lijn even hoog is als de kaart
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom 1: Icoon en Tijd
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Icon(icon, color: CupertinoColors.systemGrey, size: 24),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          
          // Kolom 2: De Verticale Lijn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 28), // Start de lijn onder het icoon
                Expanded(
                  child: Container(
                    width: 1,
                    color: isLast ? CupertinoColors.transparent : CupertinoColors.systemGrey4,
                  ),
                ),
              ],
            ),
          ),

          // Kolom 3: Jouw bestaande ScheduleMedicineCard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24), // Ruimte tussen doses
              child: medicineCard,
            ),
          ),
        ],
      ),
    );
  }
}