// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// enum AudioRecordingStatus { idle, recording, done }

// enum MediaType { audio, video }

// class SetupScreen extends StatefulWidget {
//   const SetupScreen({super.key});

//   @override
//   State<SetupScreen> createState() => _SetupScreenState();
// }

// class _SetupScreenState extends State<SetupScreen> {
//   late RecorderController recorderController;
//   PlayerController? _playerController;
//   AudioRecordingStatus _audioStatus = AudioRecordingStatus.idle;
//   String? _tempAudioPath;
//   String? _audioPath;
//   String? _videoPath;
//   bool _isKeyboardVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     recorderController = RecorderController();
//     _setupKeyboardListener();
//   }

//   void _setupKeyboardListener() {
//     // Keyboard visibility will be detected in build method
//   }

//   @override
//   void dispose() {
//     recorderController.dispose();
//     _playerController?.dispose();
//     super.dispose();
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }

//   Future<void> _startRecording() async {
//     try {
//       final appDirectory = await getApplicationDocumentsDirectory();
//       final path = "${appDirectory.path}/recording.m4a";
//       await recorderController.record(path: path);
//       setState(() {
//         _audioStatus = AudioRecordingStatus.recording;
//       });
//     } catch (e) {
//       debugPrint('Error starting recording: $e');
//     }
//   }

//   Future<void> _stopAudioRecording() async {
//     try {
//       recorderController.reset();
//       final path = await recorderController.stop(false);
//       if (path != null) {
//         setState(() {
//           _tempAudioPath = path;
//           _audioStatus = AudioRecordingStatus.done;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error stopping recording: $e');
//     }
//   }

//   void _confirmAudioRecording() {
//     setState(() {
//       _audioPath = _tempAudioPath;
//       _tempAudioPath = null;
//       _audioStatus = AudioRecordingStatus.idle;
//     });
//     _playerController?.dispose();
//     _playerController = null;
//   }

//   void _deleteAudio() {
//     setState(() {
//       _audioPath = null;
//       _audioStatus = AudioRecordingStatus.idle;
//     });
//   }

//   void _deleteVideo() {
//     setState(() {
//       _videoPath = null;
//     });
//   }

//   Widget _buildMediaSection(BuildContext context, bool isKeyboardVisible) {
//     if (_audioStatus == AudioRecordingStatus.recording) {
//       return Container(
//         padding: const EdgeInsets.all(16),
//         height: 132,
//         decoration: BoxDecoration(
//           color: const Color(0xFF2B2B2B),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Recording Audio...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400,
//                 fontFamily: 'SpaceGrotesk',
//               ),
//             ),
//             const SizedBox(height: 8),
//             SizedBox(
//               height: 64,
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: _stopAudioRecording,
//                     child: Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF9196FF),
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                       child: const CircleAvatar(
//                         radius: 24,
//                         backgroundColor: Colors.transparent,
//                         child: Icon(
//                           Icons.mic_none,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: LayoutBuilder(
//                       builder: (context, constraints) {
//                         return AudioWaveforms(
//                           recorderController: recorderController,
//                           size: Size(constraints.maxWidth, 40),
//                           waveStyle: const WaveStyle(
//                             waveColor: Colors.white,
//                             showDurationLabel: false,
//                             spacing: 9.5,
//                             waveThickness: 4,
//                             scaleFactor: 22.0,
//                             middleLineColor: Colors.transparent,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   StreamBuilder<Duration>(
//                     stream: recorderController.onCurrentDuration,
//                     builder: (context, snapshot) {
//                       final duration = snapshot.data ?? Duration.zero;
//                       return Text(
//                         _formatDuration(duration),
//                         style: const TextStyle(
//                           color: Color(0xFF9196FF),
//                           fontSize: 16,
//                           fontWeight: FontWeight.w400,
//                           fontFamily: 'SpaceGrotesk',
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_audioStatus == AudioRecordingStatus.done &&
//         _tempAudioPath != null &&
//         _audioPath == null) {
//       if (_playerController == null) {
//         _playerController = PlayerController();
//         _playerController!.preparePlayer(
//           path: _tempAudioPath!,
//           shouldExtractWaveform: true,
//         );
//       } else if (_playerController != null &&
//           _playerController!.playerState == PlayerState.stopped) {
//         _playerController!.preparePlayer(
//           path: _tempAudioPath!,
//           shouldExtractWaveform: true,
//         );
//       }

//       return Container(
//         padding: const EdgeInsets.all(16),
//         height: 132,
//         decoration: BoxDecoration(
//           color: const Color(0xFF2B2B2B),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Recording Audio...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400,
//                 fontFamily: 'SpaceGrotesk',
//               ),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               height: 64,
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: _confirmAudioRecording,
//                     child: Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF5961FF),
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                       child: const CircleAvatar(
//                         radius: 24,
//                         backgroundColor: Colors.transparent,
//                         child: Icon(Icons.check, color: Colors.white, size: 20),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: _playerController != null
//                         ? LayoutBuilder(
//                             builder: (context, constraints) {
//                               return AudioFileWaveforms(
//                                 size: Size(constraints.maxWidth, 40),
//                                 playerController: _playerController!,
//                                 playerWaveStyle: const PlayerWaveStyle(
//                                   fixedWaveColor: Colors.grey,
//                                   liveWaveColor: Colors.white,
//                                   spacing: 9.5,
//                                   waveThickness: 4,
//                                   scaleFactor: 50.0,
//                                   seekLineColor: Colors.transparent,
//                                 ),
//                               );
//                             },
//                           )
//                         : const SizedBox(
//                             height: 40,
//                             child: Center(child: CircularProgressIndicator()),
//                           ),
//                   ),
//                   const SizedBox(width: 12),
//                   StreamBuilder<Duration>(
//                     stream: recorderController.onCurrentDuration,
//                     initialData: Duration.zero,
//                     builder: (context, snapshot) {
//                       final duration = snapshot.data ?? Duration.zero;
//                       return Text(
//                         _formatDuration(duration),
//                         style: const TextStyle(
//                           color: Color(0xFF9196FF),
//                           fontSize: 16,
//                           fontWeight: FontWeight.w400,
//                           fontFamily: 'SpaceGrotesk',
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_audioPath != null) {
//       return MediaPlaybackWidget(
//         type: MediaType.audio,
//         filePath: _audioPath!,
//         isKeyboardVisible: isKeyboardVisible,
//         onDelete: _deleteAudio,
//       );
//     }

//     if (_videoPath != null) {
//       return MediaPlaybackWidget(
//         type: MediaType.video,
//         filePath: _videoPath!,
//         isKeyboardVisible: isKeyboardVisible,
//         onDelete: _deleteVideo,
//       );
//     }

//     return const SizedBox.shrink();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Update keyboard visibility
//     final viewInsets = MediaQuery.of(context).viewInsets;
//     final isKeyboardVisible = viewInsets.bottom > 0;
//     if (_isKeyboardVisible != isKeyboardVisible) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           setState(() {
//             _isKeyboardVisible = isKeyboardVisible;
//           });
//         }
//       });
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFF252331),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child:
//                     _audioStatus == AudioRecordingStatus.idle &&
//                         _audioPath == null &&
//                         _videoPath == null
//                     ? Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Tap the mic to start recording',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                           const SizedBox(height: 20),
//                           IconButton(
//                             onPressed: _startRecording,
//                             icon: const Icon(Icons.mic),
//                             color: Colors.white,
//                             iconSize: 48,
//                           ),
//                         ],
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: _buildMediaSection(context, _isKeyboardVisible),
//             ),
//             if (_audioStatus == AudioRecordingStatus.idle &&
//                 _audioPath == null &&
//                 _videoPath == null)
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       onPressed: _startRecording,
//                       icon: const Icon(Icons.mic),
//                       color: Colors.white,
//                       iconSize: 28,
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MediaPlaybackWidget extends StatefulWidget {
//   final MediaType type;
//   final String filePath;
//   final bool isKeyboardVisible;
//   final VoidCallback onDelete;

//   const MediaPlaybackWidget({
//     super.key,
//     required this.type,
//     required this.filePath,
//     required this.isKeyboardVisible,
//     required this.onDelete,
//   });

//   @override
//   State<MediaPlaybackWidget> createState() => _MediaPlaybackWidgetState();
// }

// class _MediaPlaybackWidgetState extends State<MediaPlaybackWidget> {
//   // For Video - Note: video_player package needed
//   // VideoPlayerController? _videoController;
//   final Duration _videoDuration = Duration.zero;

//   // For Audio
//   PlayerController? _audioController;
//   Duration _audioDuration = Duration.zero;
//   bool _isAudioPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.type == MediaType.video) {
//       // _initVideoPlayer();
//       // Video player initialization would go here if video_player package is added
//     } else {
//       _initAudioPlayer();
//     }
//   }

//   // Future<void> _initVideoPlayer() async {
//   //   _videoController = VideoPlayerController.file(File(widget.filePath));
//   //   await _videoController!.initialize();
//   //   setState(() {
//   //     _videoDuration = _videoController!.value.duration;
//   //   });
//   // }

//   Future<void> _initAudioPlayer() async {
//     _audioController = PlayerController();
//     await _audioController!.preparePlayer(
//       path: widget.filePath,
//       shouldExtractWaveform: true,
//       noOfSamples: 100,
//     );
//     final duration = await _audioController!.getDuration(DurationType.max);
//     setState(() {
//       _audioDuration = Duration(milliseconds: duration);
//     });
//     _audioController!.onPlayerStateChanged.listen((state) {
//       setState(() {
//         _isAudioPlaying = state == PlayerState.playing;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // _videoController?.dispose();
//     _audioController?.dispose();
//     super.dispose();
//   }

//   void _toggleAudioPlayback() {
//     if (_isAudioPlaying) {
//       _audioController?.pausePlayer();
//     } else {
//       _audioController?.startPlayer();
//     }
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: widget.isKeyboardVisible ? 64 : 132,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2B2B2B),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: widget.type == MediaType.audio
//           ? widget.isKeyboardVisible
//                 ? _buildAudioPlayerWhenKeyboardVisible()
//                 : _buildAudioPlayer()
//           : _buildVideoPlayer(),
//     );
//   }

//   Widget _buildAudioPlayerWhenKeyboardVisible() {
//     return Container(
//       height: 64,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const SizedBox(width: 10),
//                 GestureDetector(
//                   onTap: _toggleAudioPlayback,
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF5961FF),
//                       borderRadius: BorderRadius.circular(100),
//                     ),
//                     child: CircleAvatar(
//                       radius: 24,
//                       backgroundColor: Colors.transparent,
//                       child: Icon(
//                         _isAudioPlaying
//                             ? Icons.pause_rounded
//                             : Icons.play_arrow_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Audio Recorded',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w400,
//                     fontSize: 16,
//                     fontFamily: 'SpaceGrotesk',
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   ' • ${_formatDuration(_audioDuration)}',
//                   style: TextStyle(color: Colors.grey[400]),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: widget.onDelete,
//                   child: const Icon(
//                     Icons.delete_outline,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAudioPlayer() {
//     if (_audioController == null) {
//       return const SizedBox(
//         height: 132,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Column(
//       children: [
//         Container(
//           height: 44,
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Audio Recorded',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w400,
//                   fontSize: 16,
//                   fontFamily: 'SpaceGrotesk',
//                   color: Colors.white,
//                 ),
//               ),
//               Text(
//                 ' • ${_formatDuration(_audioDuration)}',
//                 style: TextStyle(color: Colors.grey[400]),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: widget.onDelete,
//                 child: const Icon(
//                   Icons.delete_outline,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 10),
//             ],
//           ),
//         ),
//         Container(
//           height: 64,
//           child: Row(
//             children: [
//               GestureDetector(
//                 onTap: _toggleAudioPlayback,
//                 child: Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF5961FF),
//                     borderRadius: BorderRadius.circular(100),
//                   ),
//                   child: CircleAvatar(
//                     radius: 24,
//                     backgroundColor: Colors.transparent,
//                     child: Icon(
//                       _isAudioPlaying ? Icons.pause : Icons.play_arrow,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _audioController != null
//                     ? AudioFileWaveforms(
//                         size: const Size(260, 30.0),
//                         playerController: _audioController!,
//                         playerWaveStyle: const PlayerWaveStyle(
//                           fixedWaveColor: Colors.grey,
//                           seekLineThickness: 0,
//                           seekLineColor: Colors.transparent,
//                           liveWaveColor: Colors.white,
//                           spacing: 8,
//                           scaleFactor: 170.0,
//                           waveThickness: 4,
//                         ),
//                       )
//                     : Container(
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha: 0.1),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: const Center(
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildVideoPlayer() {
//     return Row(
//       children: [
//         // Thumbnail placeholder
//         SizedBox(
//           width: 50,
//           height: 50,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               color: Colors.black,
//               child: const Center(
//                 child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         // Title and Duration
//         Expanded(
//           child: Text(
//             'Video Recorded • ${_formatDuration(_videoDuration)}',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: widget.onDelete,
//           child: const Icon(
//             Icons.delete_outline,
//             color: Colors.white,
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: 10),
//       ],
//     );
//   }
// }
