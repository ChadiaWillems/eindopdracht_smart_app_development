import 'package:flutter/material.dart';

class GenericButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GenericButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: const Color(0xFF1B5AEE),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}
