import 'package:flutter/material.dart';
import 'package:parent_tinywiz/widgets/schedule_item.dart';

Widget buildDailySchedule() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          "Today's Schedule",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
        ),
      ),
      buildScheduleItem(
        time: "10:00 AM",
        activity: "Math Adventure",
        status: "Completed",
        statusColor: Colors.green,
      ),
      buildScheduleItem(
        time: "12:00 PM",
        activity: "Outdoor Time",
        status: "Upcoming",
        statusColor: Colors.blue,
      ),
      buildScheduleItem(
        time: "2:00 PM",
        activity: "Story Time",
        status: "In Progress",
        statusColor: Colors.deepPurple,
      ),
      SizedBox(height: 16),
    ],
  );
}
