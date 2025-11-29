import 'package:flutter/material.dart';

Widget buildKeyMetric({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      margin: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: color),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color.withValues(alpha: color.alpha - 20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildKeyMetrics() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        buildKeyMetric(
          icon: Icons.timer_outlined,
          title: "Today's Screen Time",
          value: "1h 15m / 2h",
          color: Colors.deepPurple,
        ),
        buildKeyMetric(
          icon: Icons.menu_book_outlined,
          title: "Stories Completed",
          value: "3/5",
          color: Colors.purple,
        ),
        buildKeyMetric(
          icon: Icons.emoji_emotions_outlined,
          title: "Current Mood",
          value: "😊 Happy",
          color: Colors.amber[700]!,
        ),
      ],
    ),
  );
}
