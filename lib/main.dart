import 'package:flutter/material.dart';

void main() {
  runApp(TinyWizApp());
}

class TinyWizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyWiz',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ParentDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ParentDashboard extends StatefulWidget {
  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hello, Aastha!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[800],
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.deepPurple[200],
            child: Icon(Icons.person, size: 28, color: Colors.deepPurple[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildChildStatusCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/image.png"),

                  // backgroundImage: NetworkImage(
                  //   'https://i.pravatar.cc/150?img=47',
                  // ), // Placeholder avatar
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent[400],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shivam',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Learning - Story Time',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetric({
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
                color: color.darken(0.2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildKeyMetric(
            icon: Icons.timer_outlined,
            title: "Today's Screen Time",
            value: "1h 15m / 2h",
            color: Colors.deepPurple,
          ),
          _buildKeyMetric(
            icon: Icons.menu_book_outlined,
            title: "Stories Completed",
            value: "3/5",
            color: Colors.purple,
          ),
          _buildKeyMetric(
            icon: Icons.emoji_emotions_outlined,
            title: "Current Mood",
            value: "😊 Happy",
            color: Colors.amber[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.bar_chart_outlined),
              label: Text('View Full Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[50],
                // onPrimary: Colors.deepPurple[800],
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.lock_outline),
              label: Text('Lock Device Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[700],
                //onPrimary: Colors.white,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem({
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

  Widget _buildDailySchedule() {
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
        _buildScheduleItem(
          time: "10:00 AM",
          activity: "Math Adventure",
          status: "Completed",
          statusColor: Colors.green,
        ),
        _buildScheduleItem(
          time: "12:00 PM",
          activity: "Outdoor Time",
          status: "Upcoming",
          statusColor: Colors.blue,
        ),
        _buildScheduleItem(
          time: "2:00 PM",
          activity: "Story Time",
          status: "In Progress",
          statusColor: Colors.deepPurple,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.deepPurple[700],
      unselectedItemColor: Colors.deepPurple[300],
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Setup',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(), // 1
              _buildChildStatusCard(), // 2
              _buildKeyMetrics(), // 3
              _buildQuickActions(), // 4
              _buildDailySchedule(), // 5
            ],
          ),
        ),
      ),
    );
  }
}

// Extension method to darken a color
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
