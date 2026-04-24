import 'dart:async';
import 'dart:math';

class MockInteractionService {
  final Random _random = Random();

  /// Simulates sending a voice command to the backend.
  /// 
  /// Takes a [path] to the audio file and returns a simulated response
  /// after a 1 to 3 seconds delay.
  Future<String> sendVoiceCommand(String path) async {
    // Simulate upload and processing delay (1 to 3 seconds)
    final delaySeconds = _random.nextInt(3) + 1;
    await Future.delayed(Duration(seconds: delaySeconds));

    // Simulate occasional failure
    if (_random.nextDouble() > 0.95) {
      throw Exception('Network error: Failed to send voice command.');
    }

    return 'Voice sent to server successfully. Command processed.';
  }

  /// Simulates sending a text command to the backend.
  /// 
  /// Takes [text] as input and returns a simulated response
  /// after a 1 to 2 seconds delay.
  Future<String> sendTextCommand(String text) async {
    // Simulate processing delay (1 to 2 seconds)
    final delaySeconds = _random.nextInt(2) + 1;
    await Future.delayed(Duration(seconds: delaySeconds));

    // Simulate occasional failure
    if (_random.nextDouble() > 0.95) {
      throw Exception('Network error: Failed to send text command.');
    }

    return 'Command received and processed.';
  }
}
