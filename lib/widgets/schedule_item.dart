import 'package:flutter/material.dart';

Widget buildScheduleItem({
  required String time,
  required String activity,
  required String status,
  required Color statusColor,
}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
      border: Border(left: BorderSide(color: statusColor, width: 5)),
    ),
    child: Row(
      children: [
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[700],
            fontSize: 16,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            activity,
            style: TextStyle(fontSize: 16, color: Colors.deepPurple[900]),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: statusColor,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
