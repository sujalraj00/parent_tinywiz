import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class WaveBubble extends StatefulWidget {
  final String path;
  final bool isSender;
  final double width;

  const WaveBubble({
    super.key,
    required this.path,
    required this.isSender,
    required this.width,
  });

  @override
  State<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends State<WaveBubble> {
  late PlayerController playerController;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    playerController = PlayerController();
    _preparePlayer();
    _setupListeners();
  }

  Future<void> _preparePlayer() async {
    await playerController.preparePlayer(path: widget.path);
    final playerDuration = await playerController.getDuration(DurationType.max);
    setState(() {
      duration = Duration(milliseconds: playerDuration);
    });
  }

  void _setupListeners() {
    playerController.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }
    });

    playerController.onCurrentDurationChanged.listen((currentDuration) {
      setState(() {
        position = Duration(milliseconds: currentDuration);
      });
    });
  }

  Future<void> _togglePlayback() async {
    if (isPlaying) {
      await playerController.pausePlayer();
    } else {
      await playerController.startPlayer();
    }
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.isSender
              ? const Color(0xFF1E1B26)
              : const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: widget.isSender
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: widget.isSender
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _togglePlayback,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

