# 🔌 Connection Troubleshooting Guide

## 📋 How the Parent App Connects (Reference)

The parent app uses the following connection process:

### Connection Flow:
1. **Initialization**: Creates socket with server URL
2. **DNS Resolution**: Attempts to resolve hostname to IP address
3. **Socket Creation**: Creates Socket.IO client with:
   - Transports: `['websocket', 'polling']` (fallback support)
   - Auto Connect: `true`
   - Timeout: `5000ms` (5 seconds)
4. **Connection**: Calls `socket.connect()`
5. **Event Handlers**: Sets up listeners for:
   - `onConnect` - When connection succeeds
   - `onDisconnect` - When connection is lost
   - `onError` - When connection fails
6. **Registration**: After connection, emits `register_parent` event

### Current Configuration:
- **Server URL**: `http://192.168.1.13:3200`
- **Parent ID**: `parent123`
- **Child ID**: `child456`
- **Connection Timeout**: 2 seconds wait time

---

## 🚨 Common Child App Connection Issues & Solutions

### 1. **Server URL/IP Address Issues**

#### Problem:
- Child app can't reach the server
- DNS resolution fails
- Wrong IP address

#### Solutions:

**Check Server IP Address:**
```bash
# On the server machine, find your IP:
# macOS/Linux:
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows:
ipconfig
```

**Verify Server is Running:**
```bash
# Check if server is listening on port 3200
# macOS/Linux:
lsof -i :3200
netstat -an | grep 3200

# Windows:
netstat -an | findstr 3200
```

**Test Connection:**
```bash
# Test if server is reachable
curl http://192.168.1.13:3200
# or
ping 192.168.1.13
```

**Fix in Child App:**
- Ensure child app uses the **EXACT SAME** server URL as parent app
- Use IP address instead of hostname if DNS fails
- Check for typos in the URL

---

### 2. **Network Connectivity Issues**

#### Problem:
- Devices on different networks
- WiFi vs Mobile Data mismatch
- Network isolation

#### Solutions:

**Ensure Same Network:**
- ✅ Both parent and child devices must be on the **SAME WiFi network**
- ❌ Don't use mobile data on one device and WiFi on another
- ❌ Don't use different WiFi networks

**Check Network Connectivity:**
```dart
// Add this test in child app before connecting
import 'dart:io';

Future<bool> testServerReachability(String url) async {
  try {
    final uri = Uri.parse(url);
    final socket = await Socket.connect(uri.host, uri.port, timeout: Duration(seconds: 5));
    socket.destroy();
    print('✅ Server is reachable');
    return true;
  } catch (e) {
    print('❌ Server is NOT reachable: $e');
    return false;
  }
}
```

**Firewall Issues:**
- Check if firewall is blocking port 3200
- On server: Allow incoming connections on port 3200
- On client devices: Allow outbound connections

---

### 3. **Socket.IO Configuration Mismatch**

#### Problem:
- Different transport methods
- Timeout too short
- Auto-connect disabled

#### Solutions:

**Use Same Configuration as Parent:**
```dart
_socket = IO.io(
  url,
  IO.OptionBuilder()
      .setTransports(['websocket', 'polling'])  // ← MUST match parent
      .enableAutoConnect()                      // ← MUST be true
      .setTimeout(5000)                         // ← 5 second timeout
      .build(),
);
```

**Increase Timeout if Needed:**
```dart
.setTimeout(10000)  // 10 seconds instead of 5
```

**Add Connection Retry Logic:**
```dart
Future<bool> connectWithRetry(String deviceId, {String? serverUrl, int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    print('🔄 Connection attempt ${i + 1}/$maxRetries');
    final connected = await connect(deviceId, serverUrl: serverUrl);
    if (connected) return true;
    
    if (i < maxRetries - 1) {
      print('⏳ Waiting 3 seconds before retry...');
      await Future.delayed(Duration(seconds: 3));
    }
  }
  return false;
}
```

---

### 4. **Child Registration Issues**

#### Problem:
- Child app connects but doesn't register
- Server doesn't recognize child
- Registration event not emitted

#### Solutions:

**Ensure Registration After Connection:**
```dart
_socket!.onConnect((_) {
  print('✅ Connected - now registering as child');
  
  // Wait a moment for connection to stabilize
  Future.delayed(Duration(milliseconds: 500), () {
    emit('register_child', {
      'childId': _childId,
      'parentId': _parentId,  // If needed
    });
  });
});
```

**Verify Registration Event Name:**
- Check server code to confirm the exact event name
- Common names: `register_child`, `child_register`, `register`
- Must match server expectations exactly

**Add Registration Confirmation:**
```dart
on('child_registered', (data) {
  print('✅ Child registration confirmed: $data');
});

on('registration_failed', (data) {
  print('❌ Registration failed: $data');
});
```

---

### 5. **Platform-Specific Issues**

#### Android:

**Internet Permission:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

**Cleartext Traffic (HTTP):**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="true"  <!-- ← Add this for HTTP -->
    ...>
```

#### iOS:

**App Transport Security:**
```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>  <!-- ← Allow HTTP connections -->
</dict>
```

---

### 6. **Timing Issues**

#### Problem:
- Connection happens before server is ready
- Registration happens before connection is stable

#### Solutions:

**Wait for Connection to Stabilize:**
```dart
_socket!.onConnect((_) {
  print('✅ Connected, waiting for stability...');
  
  // Wait for connection to fully establish
  Future.delayed(Duration(milliseconds: 1000), () {
    print('🚀 Connection stable, proceeding with registration');
    // Now register
  });
});
```

**Increase Connection Wait Time:**
```dart
// In connect() method, increase wait time
await Future.delayed(Duration(seconds: 3));  // Instead of 2
```

---

## 🔍 Step-by-Step Debugging Checklist

### For Child App Connection:

1. **✅ Verify Server is Running**
   - Check server logs
   - Test with `curl http://192.168.1.13:3200`

2. **✅ Check Network Connection**
   - Both devices on same WiFi
   - Can ping server IP from child device
   - No firewall blocking

3. **✅ Verify Server URL**
   - Exact same URL as parent app
   - Correct IP address
   - Correct port (3200)

4. **✅ Check Socket Configuration**
   - Same transports as parent
   - Auto-connect enabled
   - Appropriate timeout

5. **✅ Check Permissions**
   - Internet permission (Android)
   - Cleartext traffic allowed (Android)
   - App Transport Security (iOS)

6. **✅ Check Event Names**
   - Registration event name matches server
   - All event names are correct

7. **✅ Check Logs**
   - Look for connection errors
   - Check DNS resolution
   - Verify socket ID received

8. **✅ Test Connection Manually**
   - Use socket test tool
   - Try connecting from browser
   - Verify server accepts connections

---

## 📝 Child App Connection Code Template

Here's a complete example for child app:

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';

class ChildSocketService extends SocketServiceBase {
  String? _childId;
  String? _parentId;

  Future<bool> connectAsChild(
    String childId,
    String parentId, {
    String? serverUrl,
  }) async {
    print('═══════════════════════════════════════════════════════');
    print('👶 CHILD CONNECTION INITIATED');
    print('═══════════════════════════════════════════════════════');
    print('👶 Child ID: $childId');
    print('👤 Parent ID: $parentId');
    print('🌐 Server URL: ${serverUrl ?? 'default'}');
    print('───────────────────────────────────────────────────────');

    _childId = childId;
    _parentId = parentId;

    // Test server reachability first
    if (serverUrl != null) {
      final reachable = await testServerReachability(serverUrl);
      if (!reachable) {
        print('❌ Server is not reachable, aborting connection');
        return false;
      }
    }

    final connected = await connect(childId, serverUrl: serverUrl);

    if (connected) {
      print('✅ Child connection successful, proceeding with registration');
      
      // Wait for connection to stabilize
      await Future.delayed(Duration(milliseconds: 500));
      
      // Register as child
      final registrationData = {
        'childId': childId,
        'parentId': parentId,
      };
      print('📝 Registering as child with data: $registrationData');
      emit('register_child', registrationData);

      // Set up event listeners
      _setupEventListeners();
    } else {
      print('❌ Child connection failed');
    }

    return connected;
  }

  void _setupEventListeners() {
    // Listen for registration confirmation
    on('child_registered', (data) {
      print('✅ Child registration confirmed: $data');
    });

    // Listen for lock commands from parent
    on('lock_child_phone', (data) {
      print('🔒 Lock command received: $data');
      // Handle lock command
    });
  }

  Future<bool> testServerReachability(String url) async {
    try {
      final uri = Uri.parse(url);
      print('🔍 Testing server reachability: ${uri.host}:${uri.port}');
      
      final socket = await Socket.connect(
        uri.host,
        uri.port,
        timeout: Duration(seconds: 5),
      );
      
      socket.destroy();
      print('✅ Server is reachable');
      return true;
    } catch (e) {
      print('❌ Server is NOT reachable: $e');
      return false;
    }
  }
}
```

---

## 🎯 Quick Fixes Summary

1. **Same Network**: Both devices on same WiFi ✅
2. **Correct IP**: Use exact server IP address ✅
3. **Same Config**: Match parent app's socket config ✅
4. **Permissions**: Internet + Cleartext (Android) ✅
5. **Wait Time**: Give connection time to establish ✅
6. **Event Names**: Match server's expected events ✅
7. **Logs**: Check all logs for errors ✅

---

## 📞 Still Not Working?

If child app still can't connect:

1. **Compare Logs**: Check parent app logs vs child app logs
2. **Server Logs**: Check what server sees when child tries to connect
3. **Network Test**: Use network testing tools
4. **Simplified Test**: Try minimal connection code first
5. **Server Check**: Verify server accepts connections from any client

---

## 🔗 Useful Commands

```bash
# Find your IP address
ifconfig | grep "inet " | grep -v 127.0.0.1

# Check if port is open
lsof -i :3200

# Test server connection
curl http://192.168.1.13:3200

# Ping server
ping 192.168.1.13

# Check network interfaces
netstat -rn
```

---

**Last Updated**: Based on parent app implementation
**Server URL**: `http://192.168.1.13:3200`
**Port**: `3200`

