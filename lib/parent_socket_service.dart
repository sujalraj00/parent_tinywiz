// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ParentSocketService {
//   IO.Socket? _socket;
//   String? _parentId;
//   String? _childId;

//   static final ParentSocketService _instance = ParentSocketService._internal();
//   factory ParentSocketService() => _instance;
//   ParentSocketService._internal();

//   void connect(String serverUrl, String parentId, String childId) {
//     _parentId = parentId;
//     _childId = childId;

//     _socket = IO.io(serverUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     _socket!.onConnect((_) {
//       print('Parent connected to server');
//       // Register as parent
//       _socket!.emit('register_parent', {
//         'parentId': parentId,
//         'childId': childId,
//       });
//     });

//     _socket!.onDisconnect((_) => print('Parent disconnected'));
//     _socket!.onError((error) => print('Socket error: $error'));

//     // Listen for child status updates
//     _socket!.on('child_status', (data) {
//       print('Child status update: $data');
//       // Handle child status updates
//     });

//     // Listen for lock command confirmation
//     _socket!.on('lock_command_sent', (data) {
//       print('Lock command response: $data');
//       // Handle lock command response
//     });
//   }

//   void lockChildPhone(bool lock) {
//     if (_socket != null && _socket!.connected) {
//       _socket!.emit('lock_child_phone', {
//         'parentId': _parentId,
//         'childId': _childId,
//         'lock': lock,
//       });
//     }
//   }

//   void disconnect() {
//     _socket?.disconnect();
//     _socket = null;
//   }

//   bool get isConnected => _socket?.connected ?? false;
// }

import 'package:parent_tinywiz/socket_service_base.dart';

class ParentSocketService extends SocketServiceBase {
  String? _parentId;
  String? _childId;

  // Callbacks for parent app
  Function(bool)? onLockStatusChanged;
  Function(Map<String, dynamic>)? onChildStatusUpdate;
  Function(Map<String, dynamic>)? onLockAcknowledged;
  Function(String)? onLockError;

  static final ParentSocketService _instance = ParentSocketService._internal();
  factory ParentSocketService() => _instance;
  ParentSocketService._internal();

  Future<bool> connectAsParent(
    String parentId,
    String childId, {
    String? serverUrl,
  }) async {
    print('═══════════════════════════════════════════════════════');
    print('👨‍👩‍👧 PARENT CONNECTION INITIATED');
    print('═══════════════════════════════════════════════════════');
    print('👤 Parent ID: $parentId');
    print('👶 Child ID: $childId');
    print('🌐 Server URL: ${serverUrl ?? 'default (192.168.1.13:3200)'}');
    print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    print('───────────────────────────────────────────────────────');

    _parentId = parentId;
    _childId = childId;

    final connected = await connect(parentId, serverUrl: serverUrl);

    if (connected) {
      print('✅ Parent connection successful, proceeding with registration');

      // Register as parent after connection
      final registrationData = {'parentId': parentId, 'childId': childId};
      print('📝 Registering as parent with data: $registrationData');
      emit('register_parent', registrationData);

      // Set up event listeners
      print('👂 Setting up event listeners...');
      _setupEventListeners();
      print('✅ Event listeners configured');
    } else {
      print('❌ Parent connection failed - cannot register');
      print('   Check:');
      print('   - Server is running');
      print('   - Network connectivity');
      print('   - Server URL is correct');
    }

    print('───────────────────────────────────────────────────────');
    return connected;
  }

  void _setupEventListeners() {
    print('🔧 Setting up parent-specific event listeners...');

    // Listen for registration confirmation
    on('parent_registered', (data) {
      print('═══════════════════════════════════════════════════════');
      print('✅ PARENT REGISTRATION CONFIRMED');
      print('═══════════════════════════════════════════════════════');
      print('👤 Parent ID: $_parentId');
      print('👶 Child ID: $_childId');
      print('📦 Registration Data: $data');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('───────────────────────────────────────────────────────');
    });

    // Listen for lock command confirmation from server
    on('lock_command_sent', (data) {
      print('═══════════════════════════════════════════════════════');
      print('📤 LOCK COMMAND RESPONSE FROM SERVER');
      print('═══════════════════════════════════════════════════════');
      print('📦 Response Data: $data');
      print('👤 Parent ID: $_parentId');
      print('👶 Child ID: $_childId');

      if (data['success'] == true) {
        // Server successfully sent command to child
        print('✅ Status: SUCCESS - Lock command sent to child');
        print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      } else {
        // Failed to send (child not connected, etc.)
        print('❌ Status: FAILED');
        print('❌ Error: ${data['error']}');
        print('💡 Possible reasons:');
        print('   - Child app not connected to server');
        print('   - Child ID mismatch');
        print('   - Server error');
        print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
        onLockError?.call(data['error'] ?? 'Unknown error');
      }
      print('───────────────────────────────────────────────────────');
    });

    // Listen for child's acknowledgment
    on('lock_acknowledged', (data) {
      print('═══════════════════════════════════════════════════════');
      print('✅ CHILD ACKNOWLEDGED LOCK COMMAND');
      print('═══════════════════════════════════════════════════════');
      print('📦 Acknowledgment Data: $data');
      print('👤 Parent ID: $_parentId');
      print('👶 Child ID: $_childId');
      final bool locked = data['locked'] ?? false;
      print('🔒 Lock Status: ${locked ? 'LOCKED' : 'UNLOCKED'}');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('───────────────────────────────────────────────────────');
      onLockAcknowledged?.call(data);
      onLockStatusChanged?.call(locked);
    });

    // Listen for child status updates
    on('child_status', (data) {
      print('═══════════════════════════════════════════════════════');
      print('📊 CHILD STATUS UPDATE RECEIVED');
      print('═══════════════════════════════════════════════════════');
      print('👶 Child ID: $_childId');
      print('📦 Status Data: $data');
      if (data is Map) {
        data.forEach((key, value) {
          print('   $key: $value');
        });
      }
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('───────────────────────────────────────────────────────');
      onChildStatusUpdate?.call(data);
    });

    // Listen for emergency alerts
    on('child_emergency', (data) {
      print('═══════════════════════════════════════════════════════');
      print('🚨 EMERGENCY ALERT FROM CHILD');
      print('═══════════════════════════════════════════════════════');
      print('👶 Child ID: $_childId');
      print('📦 Emergency Data: $data');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('⚠️ ACTION REQUIRED: Handle emergency situation');
      print('───────────────────────────────────────────────────────');
      // Handle emergency - show alert, notification, etc.
    });

    // Listen for unlock requests
    on('unlock_request_received', (data) {
      print('═══════════════════════════════════════════════════════');
      print('🔓 UNLOCK REQUEST FROM CHILD');
      print('═══════════════════════════════════════════════════════');
      print('👶 Child ID: $_childId');
      print('📦 Request Data: $data');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('💡 Show dialog to parent asking if they want to unlock');
      print('───────────────────────────────────────────────────────');
      // Show dialog to parent asking if they want to unlock
    });

    print('✅ All event listeners registered');
  }

  void lockChildPhone(bool lock) {
    print('═══════════════════════════════════════════════════════');
    print('🔒 LOCK CHILD PHONE COMMAND');
    print('═══════════════════════════════════════════════════════');
    print('👤 Parent ID: $_parentId');
    print('👶 Child ID: $_childId');
    print('🔒 Lock Action: ${lock ? 'LOCK' : 'UNLOCK'}');
    print(
      '🔌 Connection Status: ${isConnected ? 'CONNECTED' : 'NOT CONNECTED'}',
    );
    print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');

    if (isConnected) {
      final commandData = {
        'parentId': _parentId,
        'childId': _childId,
        'lock': lock,
      };
      print('📤 Sending command to server...');
      print('📦 Command Data: $commandData');
      emit('lock_child_phone', commandData);
      print('✅ Command sent, waiting for server response...');
    } else {
      print('❌ CANNOT SEND COMMAND - NOT CONNECTED');
      print('💡 Check connection status and try again');
      onLockError?.call('Not connected to server');
    }
    print('───────────────────────────────────────────────────────');
  }
}
