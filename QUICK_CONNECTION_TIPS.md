# 🚀 Quick Connection Tips for Child App

## 📋 How Parent App Connects (Copy This Pattern!)

### Connection Steps:
1. **Parse URL** → Extract host, port, scheme
2. **DNS Lookup** → Resolve hostname to IP
3. **Create Socket** → With transports: `['websocket', 'polling']`
4. **Set Timeout** → 5000ms (5 seconds)
5. **Connect** → Call `socket.connect()`
6. **Wait** → 2 seconds for connection
7. **Register** → Emit `register_parent` event

### Current Parent App Settings:
```dart
Server URL: http://192.168.1.13:3200
Parent ID: parent123
Child ID: child456
Transports: ['websocket', 'polling']
Timeout: 5000ms
Auto Connect: true
```

---

## ✅ Child App MUST Match These Settings:

### 1. **Same Server URL**
```dart
// Child app MUST use EXACT same URL
const serverUrl = 'http://192.168.1.13:3200';
```

### 2. **Same Socket Configuration**
```dart
_socket = IO.io(
  url,
  IO.OptionBuilder()
      .setTransports(['websocket', 'polling'])  // ← MUST match
      .enableAutoConnect()                      // ← MUST be true
      .setTimeout(5000)                         // ← 5 seconds
      .build(),
);
```

### 3. **Same Network**
- ✅ Both devices on **SAME WiFi network**
- ❌ NOT mobile data + WiFi
- ❌ NOT different WiFi networks

### 4. **Test Server First** (NEW - Available in SocketServiceBase)
```dart
// Before connecting, test if server is reachable
final reachable = await socketService.testServerReachability(serverUrl);
if (!reachable) {
  print('❌ Server not reachable - check network!');
  return;
}
```

### 5. **Use Retry Logic** (NEW - Available in SocketServiceBase)
```dart
// Connect with automatic retries
final connected = await socketService.connectWithRetry(
  childId,
  serverUrl: serverUrl,
  maxRetries: 3,
  retryDelay: Duration(seconds: 3),
);
```

---

## 🔍 Top 5 Connection Issues:

### 1. **Wrong IP Address** ❌
**Fix**: Use exact same IP as parent app
```dart
// Check parent app logs for: "📍 Server Host: 192.168.1.13"
// Use that EXACT IP in child app
```

### 2. **Different Network** ❌
**Fix**: Both devices on same WiFi
```bash
# Check WiFi name matches on both devices
```

### 3. **Missing Permissions** ❌
**Android**: Add to `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true">
```

**iOS**: Add to `Info.plist`
```xml
<key>NSAppTransportSecurity</key>
<dict><key>NSAllowsArbitraryLoads</key><true/></dict>
```

### 4. **Wrong Event Names** ❌
**Fix**: Check server code for exact event names
```dart
// Common child registration events:
emit('register_child', {...});  // or
emit('child_register', {...});  // or
emit('register', {...});        // Check server!
```

### 5. **Connection Too Fast** ❌
**Fix**: Wait for connection to stabilize
```dart
_socket!.onConnect((_) {
  Future.delayed(Duration(milliseconds: 500), () {
    // Now register
    emit('register_child', {...});
  });
});
```

---

## 🛠️ New Helper Methods Available:

### `testServerReachability(url)`
Tests if server is reachable before connecting
```dart
final reachable = await socketService.testServerReachability(serverUrl);
```

### `connectWithRetry(deviceId, serverUrl, maxRetries, retryDelay)`
Connects with automatic retry logic
```dart
final connected = await socketService.connectWithRetry(
  childId,
  serverUrl: serverUrl,
  maxRetries: 3,
);
```

---

## 📊 Debug Checklist:

- [ ] Server URL matches parent app exactly
- [ ] Socket config matches parent app
- [ ] Both devices on same WiFi network
- [ ] Internet permission added (Android)
- [ ] Cleartext traffic allowed (Android HTTP)
- [ ] App Transport Security configured (iOS)
- [ ] Registration event name matches server
- [ ] Connection wait time sufficient (2+ seconds)
- [ ] Check logs for DNS resolution
- [ ] Check logs for connection errors

---

## 🎯 Quick Test:

```dart
// 1. Test server reachability
final reachable = await socketService.testServerReachability(serverUrl);
print('Server reachable: $reachable');

// 2. Connect with retry
final connected = await socketService.connectWithRetry(
  childId,
  serverUrl: serverUrl,
);

// 3. Check connection
print('Connected: $connected');
```

---

**See `CONNECTION_TROUBLESHOOTING.md` for detailed guide!**

