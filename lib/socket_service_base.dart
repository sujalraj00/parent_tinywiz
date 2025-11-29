import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';

class SocketServiceBase {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentServerUrl;
  String? _currentDeviceId;

  // Connection callbacks
  Function()? onConnected;
  Function(String)? onError;
  Function(String)? onDisconnected;

  Future<bool> connect(String deviceId, {String? serverUrl}) async {
    try {
      // Use provided URL or default to your local network IP
      final String url =
          serverUrl ?? 'http://192.168.1.13:3200'; // ← UPDATE THIS

      _currentServerUrl = url;
      _currentDeviceId = deviceId;

      // Extract IP and port from URL
      final uri = Uri.parse(url);
      final host = uri.host;
      final port = uri.port;
      final scheme = uri.scheme;

      print('═══════════════════════════════════════════════════════');
      print('🔌 CONNECTION ATTEMPT STARTED');
      print('═══════════════════════════════════════════════════════');
      print('📱 Device ID: $deviceId');
      print('🌐 Server URL: $url');
      print('📍 Server Host: $host');
      print('🔢 Server Port: $port');
      print('🔐 Scheme: $scheme');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('───────────────────────────────────────────────────────');

      // Try to resolve hostname to IP
      try {
        final addresses = await InternetAddress.lookup(host);
        if (addresses.isNotEmpty) {
          print('🔍 DNS Resolution:');
          for (var addr in addresses) {
            print('   → $host resolves to ${addr.address} (${addr.type.name})');
          }
        }
      } catch (e) {
        print('⚠️ DNS Resolution failed: $e');
        print('   Using hostname directly: $host');
      }

      print('───────────────────────────────────────────────────────');
      print('🔧 Socket Configuration:');
      print('   Transports: [websocket, polling]');
      print('   Auto Connect: true');
      print('   Timeout: 5000ms');
      print('───────────────────────────────────────────────────────');

      _socket = IO.io(
        url,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // Fallback transport
            .enableAutoConnect()
            .setTimeout(5000)
            .build(),
      );

      // Setup event handlers with detailed logging
      _socket!.onConnect((_) {
        final socketId = _socket?.id ?? 'unknown';
        print('═══════════════════════════════════════════════════════');
        print('✅ CONNECTION ESTABLISHED');
        print('═══════════════════════════════════════════════════════');
        print('🔗 Socket ID: $socketId');
        print('🌐 Server: $_currentServerUrl');
        print('📱 Device ID: $_currentDeviceId');
        print('⏰ Connected at: ${DateTime.now().toIso8601String()}');
        print('───────────────────────────────────────────────────────');
        _isConnected = true;
        onConnected?.call();
      });

      _socket!.onDisconnect((reason) {
        print('═══════════════════════════════════════════════════════');
        print('❌ DISCONNECTED FROM SERVER');
        print('═══════════════════════════════════════════════════════');
        print('🌐 Server: $_currentServerUrl');
        print('📱 Device ID: $_currentDeviceId');
        print('📝 Reason: $reason');
        print('⏰ Disconnected at: ${DateTime.now().toIso8601String()}');
        print('───────────────────────────────────────────────────────');
        _isConnected = false;
        onDisconnected?.call(reason ?? 'Disconnected');
      });

      _socket!.onError((error) {
        print('═══════════════════════════════════════════════════════');
        print('🚨 SOCKET ERROR');
        print('═══════════════════════════════════════════════════════');
        print('🌐 Server: $_currentServerUrl');
        print('📱 Device ID: $_currentDeviceId');
        print('❌ Error Type: ${error.runtimeType}');
        print('❌ Error Details: $error');
        print('📋 Error String: ${error.toString()}');
        print('⏰ Error at: ${DateTime.now().toIso8601String()}');
        print('───────────────────────────────────────────────────────');
        _isConnected = false;
        onError?.call(error.toString());
      });

      _socket!.on('connected', (data) {
        print('🔗 Server connection confirmed event received');
        print('   Data: $data');
        print('   Type: ${data.runtimeType}');
      });

      // Log connection attempt
      print('🚀 Initiating socket connection...');
      _socket!.connect();
      print('⏳ Waiting for connection (2 second timeout)...');

      // Wait for connection with timeout
      await Future.delayed(Duration(seconds: 2));

      if (_isConnected) {
        print('✅ Connection check: CONNECTED');
      } else {
        print('❌ Connection check: NOT CONNECTED after 2 seconds');
        print('   This may indicate:');
        print('   - Server is not running');
        print('   - Network connectivity issues');
        print('   - Firewall blocking connection');
        print('   - Incorrect server URL');
      }

      return _isConnected;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════');
      print('💥 CONNECTION EXCEPTION');
      print('═══════════════════════════════════════════════════════');
      print('🌐 Server URL: $_currentServerUrl');
      print('📱 Device ID: $_currentDeviceId');
      print('❌ Exception Type: ${e.runtimeType}');
      print('❌ Exception Message: $e');
      print('📋 Stack Trace:');
      print(stackTrace);
      print('⏰ Exception at: ${DateTime.now().toIso8601String()}');
      print('───────────────────────────────────────────────────────');
      onError?.call(e.toString());
      return false;
    }
  }

  void disconnect() {
    print('═══════════════════════════════════════════════════════');
    print('🔌 DISCONNECTING FROM SERVER');
    print('═══════════════════════════════════════════════════════');
    print('🌐 Server: $_currentServerUrl');
    print('📱 Device ID: $_currentDeviceId');
    print('⏰ Disconnecting at: ${DateTime.now().toIso8601String()}');
    print('───────────────────────────────────────────────────────');

    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    _isConnected = false;

    print('✅ Disconnected and cleaned up');
    print('───────────────────────────────────────────────────────');
  }

  bool get isConnected => _isConnected;

  void emit(String event, dynamic data) {
    if (_isConnected) {
      print('📤 EMITTING EVENT');
      print('   Event: $event');
      print('   Data: $data');
      print('   Server: $_currentServerUrl');
      print('   Socket ID: ${_socket?.id ?? 'unknown'}');
      print('   Timestamp: ${DateTime.now().toIso8601String()}');
      _socket!.emit(event, data);
    } else {
      print('⚠️ CANNOT EMIT EVENT - NOT CONNECTED');
      print('   Event: $event');
      print('   Data: $data');
      print('   Server: $_currentServerUrl');
      print('   Connection Status: $_isConnected');
    }
  }

  // Add method to listen to events
  void on(String event, Function(dynamic) callback) {
    print('👂 REGISTERING EVENT LISTENER');
    print('   Event: $event');
    print('   Server: $_currentServerUrl');

    _socket?.on(event, (data) {
      print('📥 EVENT RECEIVED');
      print('   Event: $event');
      print('   Data: $data');
      print('   Data Type: ${data.runtimeType}');
      print('   Server: $_currentServerUrl');
      print('   Timestamp: ${DateTime.now().toIso8601String()}');
      callback(data);
    });
  }

  /// Test if server is reachable before attempting connection
  /// Useful for debugging connection issues
  Future<bool> testServerReachability(String url) async {
    Uri? uri;
    try {
      uri = Uri.parse(url);
      print('═══════════════════════════════════════════════════════');
      print('🔍 TESTING SERVER REACHABILITY');
      print('═══════════════════════════════════════════════════════');
      print('🌐 Server URL: $url');
      print('📍 Host: ${uri.host}');
      print('🔢 Port: ${uri.port}');
      print('⏰ Testing at: ${DateTime.now().toIso8601String()}');
      print('───────────────────────────────────────────────────────');

      // Try DNS resolution first
      try {
        final addresses = await InternetAddress.lookup(uri.host);
        if (addresses.isNotEmpty) {
          print('✅ DNS Resolution successful:');
          for (var addr in addresses) {
            print('   → ${uri.host} → ${addr.address} (${addr.type.name})');
          }
        }
      } catch (e) {
        print('⚠️ DNS Resolution failed: $e');
        print('   Will try direct connection anyway...');
      }

      // Try socket connection
      print('🔌 Attempting socket connection test...');
      final socket = await Socket.connect(
        uri.host,
        uri.port,
        timeout: Duration(seconds: 5),
      );

      print('✅ Server is REACHABLE - socket connection successful');
      print('   Local address: ${socket.address.address}:${socket.port}');
      print(
        '   Remote address: ${socket.remoteAddress.address}:${socket.remotePort}',
      );

      socket.destroy();
      print('───────────────────────────────────────────────────────');
      return true;
    } catch (e) {
      print('❌ Server is NOT REACHABLE');
      print('   Error: $e');
      print('   Error Type: ${e.runtimeType}');
      print('───────────────────────────────────────────────────────');
      print('💡 Troubleshooting tips:');
      print('   1. Check if server is running');
      print('   2. Verify IP address is correct');
      print('   3. Check if both devices are on same network');
      print('   4. Check firewall settings');
      if (uri != null) {
        print('   5. Try pinging the server: ping ${uri.host}');
      }
      print('───────────────────────────────────────────────────────');
      return false;
    }
  }

  /// Connect with retry logic - useful for unreliable networks
  Future<bool> connectWithRetry(
    String deviceId, {
    String? serverUrl,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 3),
  }) async {
    print('═══════════════════════════════════════════════════════');
    print('🔄 CONNECTION WITH RETRY');
    print('═══════════════════════════════════════════════════════');
    print('📱 Device ID: $deviceId');
    print('🌐 Server URL: ${serverUrl ?? 'default'}');
    print('🔄 Max Retries: $maxRetries');
    print('⏱️ Retry Delay: ${retryDelay.inSeconds}s');
    print('───────────────────────────────────────────────────────');

    for (int i = 0; i < maxRetries; i++) {
      print('🔄 Connection attempt ${i + 1}/$maxRetries');

      final connected = await connect(deviceId, serverUrl: serverUrl);

      if (connected) {
        print('✅ Connection successful on attempt ${i + 1}');
        return true;
      }

      if (i < maxRetries - 1) {
        print('⏳ Waiting ${retryDelay.inSeconds} seconds before retry...');
        await Future.delayed(retryDelay);
      }
    }

    print('❌ All connection attempts failed');
    print('───────────────────────────────────────────────────────');
    return false;
  }
}
