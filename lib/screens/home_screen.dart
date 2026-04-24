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
  final ParentSocketService _socketService = ParentSocketService();
  bool _isChildLocked = false;
  bool _isConnected = false;
  Map<String, dynamic>? _childStatus;

  @override
  void initState() {
    super.initState();
    _setupSocketCallbacks();
    const parentId = 'parent123';
    const childId = 'child456';
    const serverUrl = AppConstants.serverUrl;
    
    _socketService
        .connectAsParent(parentId, childId, serverUrl: serverUrl)
        .then((connected) {
          // connection result
        });
  }

  void _setupSocketCallbacks() {
    _socketService.onLockStatusChanged = (bool locked) {
      setState(() {
        _isChildLocked = locked;
      });
    };

    _socketService.onChildStatusUpdate = (Map<String, dynamic> status) {
      setState(() {
        _childStatus = status;
      });
    };

    _socketService.onLockAcknowledged = (Map<String, dynamic> data) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Child ${data['locked'] ? 'locked' : 'unlocked'} successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    };

    _socketService.onLockError = (String error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lock command failed: $error'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _isChildLocked = !_isChildLocked;
      });
    };

    _socketService.onConnected = () {
      setState(() {
        _isConnected = true;
      });
    };

    _socketService.onDisconnected = (String reason) {
      setState(() {
        _isConnected = false;
      });
    };
  }

  void _toggleChildPhoneLock() {
    final newLockState = !_isChildLocked;
    setState(() {
      _isChildLocked = newLockState;
    });
    _socketService.lockChildPhone(_isChildLocked);
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good Morning,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Aastha 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                child: const Icon(Icons.person, size: 28, color: Color(0xFF6C63FF)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF121212), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildChildStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1C1C24),
            const Color(0xFF252530),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (_isChildLocked ? Colors.redAccent : Colors.greenAccent).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _isChildLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              size: 36,
              color: _isChildLocked ? Colors.redAccent : Colors.greenAccent,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Child Phone Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isChildLocked ? 'Locked' : 'Unlocked',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _isChildLocked ? Colors.redAccent : Colors.greenAccent,
                  ),
                ),
                if (_childStatus != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Battery: ${_childStatus!['battery']}%  •  ${_childStatus!['status']}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bar_chart_rounded, size: 20),
              label: const Text('Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF252530),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isConnected ? _toggleChildPhoneLock : null,
              icon: Icon(_isChildLocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded, size: 20),
              label: Text(_isChildLocked ? 'Unlock Phone' : 'Lock Phone'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isChildLocked ? Colors.green : const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _isChildLocked ? Colors.green.withOpacity(0.4) : const Color(0xFF6C63FF).withOpacity(0.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
      backgroundColor: const Color(0xFF0F0F13),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              buildChildStatusCard(),
              const SizedBox(height: 10),
              buildKeyMetrics(), // Using original widget
              _buildQuickActions(),
              buildDailySchedule(), // Using original widget
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.onLockStatusChanged = null;
    _socketService.onChildStatusUpdate = null;
    _socketService.onLockAcknowledged = null;
    _socketService.onLockError = null;
    _socketService.onConnected = null;
    _socketService.onDisconnected = null;
    super.dispose();
  }
}
