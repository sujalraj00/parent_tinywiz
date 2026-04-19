import 'package:flutter/material.dart';
import 'package:parent_tinywiz/parent_socket_service.dart';
import 'package:parent_tinywiz/widgets/daily_schedule.dart';
import 'package:parent_tinywiz/widgets/key_metric.dart';
import 'package:parent_tinywiz/constants.dart';

class ParentDashboard extends StatefulWidget {
  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;
  final ParentSocketService _socketService = ParentSocketService();
  bool _isChildLocked = false;
  bool _isConnected = false;
  Map<String, dynamic>? _childStatus;

  @override
  void initState() {
    super.initState();
    print('═══════════════════════════════════════════════════════');
    print('📱 PARENT DASHBOARD INITIALIZED');
    print('═══════════════════════════════════════════════════════');
    print('⏰ Initialized at: ${DateTime.now().toIso8601String()}');
    print('───────────────────────────────────────────────────────');

    _setupSocketCallbacks();

    const parentId = 'parent123';
    const childId = 'child456';
    const serverUrl = AppConstants.serverUrl;

    print('🚀 Starting parent connection...');
    print('   Parent ID: $parentId');
    print('   Child ID: $childId');
    print('   Server URL: $serverUrl');

    _socketService
        .connectAsParent(parentId, childId, serverUrl: serverUrl)
        .then((connected) {
          print('═══════════════════════════════════════════════════════');
          print('📱 PARENT DASHBOARD CONNECTION RESULT');
          print('═══════════════════════════════════════════════════════');
          print('✅ Connection Status: ${connected ? 'SUCCESS' : 'FAILED'}');
          print('⏰ Result at: ${DateTime.now().toIso8601String()}');
          print('───────────────────────────────────────────────────────');
        });
  }

  void _setupSocketCallbacks() {
    print('🔧 Setting up socket callbacks in UI...');

    // Update lock status when child acknowledges
    _socketService.onLockStatusChanged = (bool locked) {
      print('🔄 UI: Lock status changed to: ${locked ? 'LOCKED' : 'UNLOCKED'}');
      setState(() {
        _isChildLocked = locked;
      });
    };

    // Handle child status updates
    _socketService.onChildStatusUpdate = (Map<String, dynamic> status) {
      print('🔄 UI: Child status updated');
      print('   Status data: $status');
      setState(() {
        _childStatus = status;
      });
    };

    // Handle lock acknowledgment
    _socketService.onLockAcknowledged = (Map<String, dynamic> data) {
      print('✅ UI: Showing success snackbar for lock acknowledgment');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Child ${data['locked'] ? 'locked' : 'unlocked'} successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    };

    // Handle lock errors
    _socketService.onLockError = (String error) {
      print('❌ UI: Showing error snackbar');
      print('   Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lock command failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
      // Revert state if command failed
      print('🔄 UI: Reverting lock state due to error');
      setState(() {
        _isChildLocked = !_isChildLocked;
      });
    };

    // Connection status callbacks
    _socketService.onConnected = () {
      print('═══════════════════════════════════════════════════════');
      print('✅ UI: CONNECTION ESTABLISHED CALLBACK');
      print('═══════════════════════════════════════════════════════');
      print('⏰ Connected at: ${DateTime.now().toIso8601String()}');
      print('🔄 Updating UI connection status to: CONNECTED');
      setState(() {
        _isConnected = true;
      });
      print('───────────────────────────────────────────────────────');
    };

    _socketService.onDisconnected = (String reason) {
      print('═══════════════════════════════════════════════════════');
      print('❌ UI: DISCONNECTION CALLBACK');
      print('═══════════════════════════════════════════════════════');
      print('📝 Reason: $reason');
      print('⏰ Disconnected at: ${DateTime.now().toIso8601String()}');
      print('🔄 Updating UI connection status to: DISCONNECTED');
      setState(() {
        _isConnected = false;
      });
      print('───────────────────────────────────────────────────────');
    };

    print('✅ Socket callbacks configured');
  }

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
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              // Connection status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.deepPurple[700],
                child: Icon(Icons.person, size: 28, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
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

  void _toggleChildPhoneLock() {
    print('═══════════════════════════════════════════════════════');
    print('👆 USER ACTION: TOGGLE CHILD PHONE LOCK');
    print('═══════════════════════════════════════════════════════');
    print('🔒 Current Lock Status: ${_isChildLocked ? 'LOCKED' : 'UNLOCKED'}');
    print(
      '🔌 Connection Status: ${_isConnected ? 'CONNECTED' : 'NOT CONNECTED'}',
    );
    print('⏰ Action at: ${DateTime.now().toIso8601String()}');

    // Optimistically update UI
    final newLockState = !_isChildLocked;
    print(
      '🔄 Optimistically updating UI to: ${newLockState ? 'LOCKED' : 'UNLOCKED'}',
    );
    setState(() {
      _isChildLocked = newLockState;
    });

    // Send command to server
    print('📤 Sending lock command to server...');
    _socketService.lockChildPhone(_isChildLocked);
    print('───────────────────────────────────────────────────────');
  }

  // Add child status card widget
  Widget buildChildStatusCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Child Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _isChildLocked ? Icons.lock : Icons.lock_open,
                  color: _isChildLocked ? Colors.red : Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  _isChildLocked ? 'Phone Locked' : 'Phone Unlocked',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isChildLocked ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            if (_childStatus != null) ...[
              SizedBox(height: 8),
              Text('Status: ${_childStatus!['status']}'),
              Text('Battery: ${_childStatus!['battery']}%'),
            ],
          ],
        ),
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
                backgroundColor: const Color(0xFF2B2B2B),
                foregroundColor: Colors.white,
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
              onPressed: _isConnected ? _toggleChildPhoneLock : null,
              icon: Icon(_isChildLocked ? Icons.lock_open : Icons.lock_outline),
              label: Text(
                _isChildLocked ? 'Unlock Child Phone' : 'Lock Child Phone',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[600],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // bottomNavigationBar: _buildBottomNavigationBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(), // 1
              buildChildStatusCard(), // 2
              buildKeyMetrics(), // 3
              _buildQuickActions(), // 4
              buildDailySchedule(), // 5
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clear callbacks to prevent memory leaks
    // Don't disconnect socket as it's a singleton used by other screens
    _socketService.onLockStatusChanged = null;
    _socketService.onChildStatusUpdate = null;
    _socketService.onLockAcknowledged = null;
    _socketService.onLockError = null;
    _socketService.onConnected = null;
    _socketService.onDisconnected = null;
    super.dispose();
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
