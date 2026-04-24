import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:parent_tinywiz/services/mock_interaction_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final MockInteractionService _mockService = MockInteractionService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Audio Recording
  late RecorderController _recorderController;
  bool _isRecording = false;
  String? _recordedFilePath;

  // UI State
  bool _isLoading = false;
  bool _showSuccessOverlay = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _recorderController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showOverlayMessage(String message, {bool isError = false}) {
    setState(() {
      _statusMessage = message;
      _showSuccessOverlay = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessOverlay = false;
        });
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorderController.checkPermission();
      if (!hasPermission) return;

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/command_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorderController.record(path: path);
      setState(() {
        _isRecording = true;
        _recordedFilePath = path;
      });
    } catch (e) {
      _showOverlayMessage('Failed to start recording.', isError: true);
    }
  }

  Future<void> _stopAndSendRecording() async {
    try {
      final path = await _recorderController.stop();
      setState(() {
        _isRecording = false;
        _isLoading = true;
        _statusMessage = "Processing Voice...";
      });

      if (path != null) {
        // Simulate upload
        final response = await _mockService.sendVoiceCommand(path);
        _showOverlayMessage(response);
      }
    } catch (e) {
      _showOverlayMessage('Failed to send voice command.', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
        _recordedFilePath = null;
      });
    }
  }

  void _cancelRecording() async {
    await _recorderController.stop();
    setState(() {
      _isRecording = false;
      _recordedFilePath = null;
    });
  }

  Future<void> _sendTextCommand() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _statusMessage = "Processing Command...";
    });

    try {
      final response = await _mockService.sendTextCommand(text);
      _textController.clear();
      _showOverlayMessage(response);
    } catch (e) {
      _showOverlayMessage('Failed to send text command.', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildRecordingBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recording Audio...',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              StreamBuilder<Duration>(
                stream: _recorderController.onCurrentDuration,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return Text(
                    _formatDuration(duration),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF6C63FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: _cancelRecording,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AudioWaveforms(
                    size: const Size(double.infinity, 40),
                    recorderController: _recorderController,
                    enableGesture: false,
                    waveStyle: const WaveStyle(
                      waveColor: Colors.white,
                      showDurationLabel: false,
                      spacing: 8.0,
                      waveThickness: 3,
                      scaleFactor: 30.0,
                      showMiddleLine: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardVisible = viewInsets.bottom > 0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0F0F13),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Command Center',
                        style: GoogleFonts.outfit(
                          fontSize: isKeyboardVisible ? 20 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type a command or record a voice note to send directly to your child\'s device.',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: Colors.grey[400],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        
                        // Text Field Area
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C24),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            maxLines: isKeyboardVisible ? 4 : 8,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                            decoration: InputDecoration(
                              hintText: 'e.g. "Lock the screen for 10 minutes"',
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.grey[600],
                                fontSize: 18,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.all(24),
                              filled: false,
                            ),
                            onChanged: (val) {
                              setState(() {}); // Rebuild to toggle button states
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Media Section (Recording Waveform)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isRecording ? _buildRecordingBar() : const SizedBox.shrink(),
                        ),
                        
                        // Give some space at bottom when keyboard is up
                        SizedBox(height: isKeyboardVisible ? 40 : 0),
                      ],
                    ),
                  ),
                ),

                // Bottom Controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F13),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Side - Mic
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: _textController.text.isNotEmpty
                              ? const SizedBox.shrink()
                              : GestureDetector(
                                  onTap: _isLoading
                                      ? null
                                      : (_isRecording ? null : _startRecording),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: _isRecording 
                                          ? const Color(0xFF6C63FF) 
                                          : const Color(0xFF2B2B2B),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.05),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.mic_none_rounded,
                                      color: _isRecording ? Colors.white : Colors.grey[400],
                                      size: 24,
                                    ),
                                  ),
                                ),
                        ),
                        
                        // Right Side - Send Button
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: _textController.text.isNotEmpty ? 0 : 16.0),
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_isRecording
                                      ? _stopAndSendRecording
                                      : (_textController.text.isNotEmpty
                                          ? _sendTextCommand
                                          : null)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                disabledBackgroundColor: const Color(0xFF2B2B2B),
                                foregroundColor: Colors.white,
                                elevation: _textController.text.isNotEmpty || _isRecording ? 4 : 0,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Send Command',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: (_textController.text.isNotEmpty || _isRecording)
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Success / Status Overlay
        if (_showSuccessOverlay)
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: GoogleFonts.outfit(
                              color: Colors.greenAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
