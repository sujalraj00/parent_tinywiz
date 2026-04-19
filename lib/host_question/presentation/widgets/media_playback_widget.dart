import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum MediaType { audio, video }

class MediaPlaybackWidget extends StatefulWidget {
  final MediaType type;
  final String filePath;
  final bool isKeyboardVisible;
  final VoidCallback onDelete;

  const MediaPlaybackWidget({
    super.key,
    required this.type,
    required this.filePath,
    required this.isKeyboardVisible,
    required this.onDelete,
  });

  @override
  State<MediaPlaybackWidget> createState() => _MediaPlaybackWidgetState();
}

class _MediaPlaybackWidgetState extends State<MediaPlaybackWidget> {
  // For Video
  VideoPlayerController? _videoController;
  Duration _videoDuration = Duration.zero;

  // For Audio
  PlayerController? _audioController;
  Duration _audioDuration = Duration.zero;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == MediaType.video) {
      _initVideoPlayer();
    } else {
      _initAudioPlayer();
    }
  }

  Future<void> _initVideoPlayer() async {
    _videoController = VideoPlayerController.file(File(widget.filePath));
    await _videoController!.initialize();
    setState(() {
      _videoDuration = _videoController!.value.duration;
    });
  }

  Future<void> _initAudioPlayer() async {
    _audioController = PlayerController();
    await _audioController!.preparePlayer(
      path: widget.filePath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
    );

    final duration = await _audioController!.getDuration();
    setState(() {
      _audioDuration = Duration(milliseconds: duration);
    });

    _audioController!.onPlayerStateChanged.listen((state) {
      setState(() {
        _isAudioPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioController?.dispose();
    super.dispose();
  }

  void _toggleAudioPlayback() {
    if (_isAudioPlaying) {
      _audioController?.pausePlayer();
    } else {
      _audioController?.startPlayer();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.isKeyboardVisible ? 64 : 132,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: widget.type == MediaType.audio
          ? widget.isKeyboardVisible
                ? _buildAudioPlayerWhenKeyboardVisible()
                : _buildAudioPlayer()
          : _buildVideoPlayer(),
    );
  }

  Widget _buildAudioPlayerWhenKeyboardVisible() {
    return Container(
      // padding: const EdgeInsets.all(16),
      // height: 132,
      // decoration: BoxDecoration(
      //   color: const Color(0xFF2B2B2B),
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: Color(0xFFFFFFFF).withOpacity(0.05),
      //     width: 1,
      //   ),
      // ),
      height: 64,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _toggleAudioPlayback,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(0xFF5961FF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        _isAudioPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Audio Recorded',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                Text(
                  ' • ${_formatDuration(_audioDuration)}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                Spacer(),
                Icon(Icons.delete_outline, color: Colors.white, size: 20),
                // Image.asset('assets/icons/bin.png', width: 14, height: 14),
                const SizedBox(width: 10),
              ],
            ),
          ),
          // Container(
          //   height: 64,
          //   child: Row(
          //     children: [
          //       // IconButton(
          //       //   icon: Icon(
          //       //     _isAudioPlaying ? Icons.pause_circle : Icons.play_circle,
          //       //     color: Colors.white,
          //       //     size: 20,
          //       //   ),
          //       //   onPressed: _toggleAudioPlayback,
          //       // ),

          //       const SizedBox(width: 12),
          //       AudioFileWaveforms(
          //         size: const Size(260, 30.0),
          //         playerController: _audioController!,
          //         playerWaveStyle: const PlayerWaveStyle(
          //           fixedWaveColor: Colors.grey,

          //           seekLineThickness: 0,
          //           seekLineColor: Colors.transparent,
          //           liveWaveColor: Colors.white,
          //           spacing: 8,
          //           scaleFactor: 170.0,
          //           waveThickness: 4,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    if (_audioController == null) {
      return const SizedBox(
        height: 132,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Audio Recorded',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                Text(
                  ' • ${_formatDuration(_audioDuration)}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                Spacer(),
                GestureDetector(
                  onTap: widget.onDelete,
                  // child: Image.asset(
                  //   'assets/icons/bin.png',
                  //   width: 17,
                  //   height: 17,
                  // ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          Container(
            height: 64,
            child: Row(
              children: [
                // IconButton(
                //   icon: Icon(
                //     _isAudioPlaying ? Icons.pause_circle : Icons.play_circle,
                //     color: Colors.white,
                //     size: 20,
                //   ),
                //   onPressed: _toggleAudioPlayback,
                // ),
                GestureDetector(
                  onTap: _toggleAudioPlayback,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(0xFF5961FF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AudioFileWaveforms(
                  size: const Size(260, 30.0),
                  playerController: _audioController!,
                  playerWaveStyle: const PlayerWaveStyle(
                    fixedWaveColor: Colors.grey,

                    seekLineThickness: 0,
                    seekLineColor: Colors.transparent,
                    liveWaveColor: Colors.white,
                    spacing: 8,
                    scaleFactor: 170.0,
                    waveThickness: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Row(
      children: [
        // Thumbnail
        SizedBox(
          width: 50,
          height: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                (_videoController != null &&
                    _videoController!.value.isInitialized)
                ? Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_videoController!),
                      Container(color: Colors.black.withOpacity(0.3)),
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        // Title and Duration
        Expanded(
          child: Text(
            'Video Recorded • ${_formatDuration(_videoDuration)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onTap: widget.onDelete,
          child: Image.asset('assets/icons/bin.png', width: 17, height: 17),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
