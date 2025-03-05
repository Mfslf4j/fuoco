import 'package:flutter/material.dart';

class MangaBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isWide;

  const MangaBadge({
    super.key,
    required this.text,
    required this.color,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 14 : 10,
        vertical: isWide ? 6 : 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)], // Default
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (color)!.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
    );
  }
}
