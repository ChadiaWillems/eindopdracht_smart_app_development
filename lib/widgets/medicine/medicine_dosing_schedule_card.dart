import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MedicineDosingScheduleCard extends StatelessWidget {
  final String label;
  final int amount;
  final IconData icon;

  const MedicineDosingScheduleCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = amount > 0;
    Color primaryColor = const Color(0xFF1B5AEE);

    return Container(
      width: 115,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? primaryColor.withOpacity(0.05)
            : CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? primaryColor.withOpacity(0.2)
              : CupertinoColors.systemGrey5,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF1B5AEE)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 118, 118, 118),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toString()} pill',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
