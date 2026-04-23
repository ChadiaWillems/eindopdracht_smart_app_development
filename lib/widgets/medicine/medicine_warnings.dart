import 'package:flutter/cupertino.dart';

class MedicineWarnings extends StatelessWidget {
  final List warnings;
  static const Color criticalRed = Color.fromARGB(255, 243, 0, 0);

  const MedicineWarnings({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 246, 212, 212),
        border: const BorderDirectional(
          start: BorderSide(color: criticalRed, width: 10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.info_circle, color: criticalRed, size: 32),
              SizedBox(width: 10),
              Text(
                'WAARSCHUWINGEN',
                style: TextStyle(
                  color: criticalRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map(
            (warning) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(warning, style: const TextStyle(height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
