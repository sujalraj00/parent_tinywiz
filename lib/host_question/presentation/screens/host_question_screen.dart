import 'dart:ui';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_tinywiz/host_question/logic/host_question_cubit.dart';
import 'package:parent_tinywiz/host_question/logic/host_question_state.dart';
import 'package:parent_tinywiz/host_question/presentation/widgets/media_playback_widget.dart';
import 'package:parent_tinywiz/host_question/presentation/widgets/next_button.dart';

class HostQuestionScreen extends StatefulWidget {
  static const routeName = '/host-question';
  const HostQuestionScreen({super.key});

  @override
  State<HostQuestionScreen> createState() => _HostQuestionScreenState();
}

class _HostQuestionScreenState extends State<HostQuestionScreen> {
  final FocusNode _textFieldFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _textFieldKey = GlobalKey();
  PlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.addListener(_onTextFieldFocus);
  }

  @override
  void dispose() {
    _textFieldFocusNode.removeListener(_onTextFieldFocus);
    _textFieldFocusNode.dispose();
    _scrollController.dispose();
    _playerController?.dispose();
    super.dispose();
  }

  void _onTextFieldFocus() {
    if (_textFieldFocusNode.hasFocus) {
      // Scroll to text field when it gets focus
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_textFieldKey.currentContext != null) {
          Scrollable.ensureVisible(
            _textFieldKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Widget _buildContent() {
    bool isAudioPresent =
        context.read<HostQuestionCubit>().state.audioStatus ==
            AudioRecordingStatus.recording ||
        context.read<HostQuestionCubit>().state.audioStatus ==
            AudioRecordingStatus.done;

    final viewInsets = MediaQuery.of(context).viewInsets;
    final keyboardHeight = viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    bool isAudioAndKeyboardVisible = isAudioPresent && isKeyboardVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Text(
          '02',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFFFFFFF).withOpacity(0.24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us something about your child ?',
          style: TextStyle(
            fontSize: isKeyboardVisible ? 14 : 24,
            fontWeight: FontWeight.w700,
            letterSpacing: isKeyboardVisible ? 0 : -2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          (isKeyboardVisible &&
                  (context.read<HostQuestionCubit>().state.audioStatus ==
                          AudioRecordingStatus.done ||
                      context.read<HostQuestionCubit>().state.audioStatus ==
                          AudioRecordingStatus.recording))
              ? ''
              : 'Tell us about your intent and what motivates you to join this community.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFFFFFFF).withOpacity(0.48),
          ),
        ),
        SizedBox(
          height:
              (isKeyboardVisible &&
                  (context.read<HostQuestionCubit>().state.audioStatus ==
                          AudioRecordingStatus.done ||
                      context.read<HostQuestionCubit>().state.audioStatus ==
                          AudioRecordingStatus.recording))
              ? 0
              : (isAudioPresent ? 8 : 16),
        ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: TextField(
            key: _textFieldKey,
            focusNode: _textFieldFocusNode,
            decoration: InputDecoration(
              hintText: isKeyboardVisible ? '' : '/ Start typing here',
              hintStyle: TextStyle(
                fontSize: 20,
                letterSpacing: -1,
                fontWeight: FontWeight.w400,
                color: Color(0xFFFFFFFF).withOpacity(0.24),
              ),
            ),
            maxLength: 600,
            maxLines: isAudioAndKeyboardVisible
                ? 3 // Audio present AND keyboard visibl
                : (isKeyboardVisible ? 3 : (isAudioPresent ? 5 : 12)),
            onChanged: (value) {
              context.read<HostQuestionCubit>().descriptionChanged(value);
            },
          ),
        ),
        SizedBox(height: isAudioPresent ? 8 : 10),

        _buildMediaSection(context, isKeyboardVisible),

        SizedBox(height: isKeyboardVisible ? 8 : (isAudioPresent ? 8 : 14)),

        _buildBottomControls(),
        SizedBox(height: isKeyboardVisible ? 0 : 14),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF).withOpacity(0.08),
              ),
              child: AppBar(
                toolbarHeight: 56,
                //  backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const BackButton(color: Colors.white),
                // --- PROGRESS BAR ADDED ---
                // title: const WavyProgressIndicator(
                //   progress: 1.0, // 100% for screen 2 of 2
                // ),
                // --------------------------
                // actions: [
                //   IconButton(
                //     icon: const Icon(Icons.close, color: Colors.white),
                //     onPressed: () => Navigator.of(context).pop(),
                //   ),
                // ],
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              const Spacer(flex: 1),
              Flexible(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, bool isKeyboardVisible) {
    final cubit = context.read<HostQuestionCubit>();

    return BlocBuilder<HostQuestionCubit, HostQuestionState>(
      builder: (context, state) {
        if (state.audioStatus == AudioRecordingStatus.recording) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: 132,
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFFFFFFFF).withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recording Audio...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 64,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          cubit.stopAudioRecording();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          // padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF9196FF),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.mic_none,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // IconButton(
                      //   icon: const Icon(
                      //     Icons.mic_none,
                      //     color: Colors.redAccent,
                      //     size: 30,
                      //   ),
                      //   onPressed: () {
                      //     cubit.stopAudioRecording();
                      //   },
                      // ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return AudioWaveforms(
                              recorderController: cubit.recorderController,
                              size: Size(constraints.maxWidth, 40),
                              waveStyle: const WaveStyle(
                                waveColor: Colors.white,
                                showDurationLabel: false,
                                spacing: 9.5,
                                waveThickness: 4,
                                scaleFactor: 22.0,
                                middleLineColor: Colors.transparent,
                              ),
                            );
                          },
                        ),
                      ),

                      // const SizedBox(width: 12),
                      StreamBuilder<Duration>(
                        stream: cubit.recorderController.onCurrentDuration,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          return Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              color: Color(0xFF9196FF),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          // ------------------------
        }

        if (state.audioStatus == AudioRecordingStatus.done &&
            state.tempAudioPath != null &&
            state.audioPath == null) {
          if (_playerController == null) {
            _playerController = PlayerController();
            _playerController!.preparePlayer(
              path: state.tempAudioPath!,
              shouldExtractWaveform: true,
            );
          } else if (_playerController != null &&
              _playerController!.playerState == PlayerState.stopped) {
            _playerController!.preparePlayer(
              path: state.tempAudioPath!,
              shouldExtractWaveform: true,
            );
          }

          return Container(
            padding: const EdgeInsets.all(16),
            height: 132,
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFFFFFFFF).withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recording Audio...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 64,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          cubit.confirmAudioRecording();
                          // Dispose player controller as it will be handled by MediaPlaybackWidget
                          _playerController?.dispose();
                          _playerController = null;
                        },
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
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _playerController != null
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  return AudioFileWaveforms(
                                    size: Size(constraints.maxWidth, 40),
                                    playerController: _playerController!,
                                    playerWaveStyle: const PlayerWaveStyle(
                                      fixedWaveColor: Colors.grey,
                                      liveWaveColor: Colors.white,
                                      spacing: 9.5,
                                      waveThickness: 4,
                                      scaleFactor: 50.0,
                                      seekLineColor: Colors.transparent,
                                    ),
                                  );
                                },
                              )
                            : SizedBox(
                                height: 40,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      StreamBuilder<Duration>(
                        stream: cubit.recorderController.onCurrentDuration,
                        initialData: Duration.zero,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          return Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              color: Color(0xFF9196FF),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (state.audioPath != null) {
          // audio playback
          return MediaPlaybackWidget(
            type: MediaType.audio,
            filePath: state.audioPath!,
            isKeyboardVisible: isKeyboardVisible,
            onDelete: () {
              cubit.deleteAudio();
            },
          );
        }

        if (state.videoPath != null) {
          // Video Playback
          return MediaPlaybackWidget(
            type: MediaType.video,
            filePath: state.videoPath!,
            isKeyboardVisible: isKeyboardVisible,
            onDelete: () {
              cubit.deleteVideo();
            },
          );
        }

        // when nothing is record
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomControls() {
    return BlocBuilder<HostQuestionCubit, HostQuestionState>(
      buildWhen: (prev, current) =>
          prev.canRecord != current.canRecord ||
          prev.audioStatus != current.audioStatus ||
          prev.isVideoRecording != current.isVideoRecording ||
          prev.audioPath != current.audioPath ||
          prev.videoPath != current.videoPath,
      builder: (context, state) {
        final canRecord = state.canRecord;
        final isAudioRecording =
            state.audioStatus == AudioRecordingStatus.recording;
        final isVideoRecording = state.isVideoRecording;
        final hasAudio = state.audioPath != null;
        final hasVideo = state.videoPath != null;

        final micIconColor = hasVideo && !hasAudio ? Colors.grey : Colors.white;
        final cameraIconColor = hasAudio && !hasVideo
            ? Colors.grey
            : Colors.white;
        final micHasGradient = isAudioRecording;

        final cameraHasGradient = isVideoRecording;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: !hasAudio
                  ? Row(
                      children: [
                        Container(
                          width: 112,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFFFFFFF).withOpacity(0.08),
                              width: 1.3,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Mike Button
                              GestureDetector(
                                onTap:
                                    canRecord &&
                                        !isAudioRecording &&
                                        !isVideoRecording
                                    ? () => context
                                          .read<HostQuestionCubit>()
                                          .startAudioRecording()
                                    : null,
                                child: Container(
                                  width: 54,
                                  height: 56,
                                  decoration: micHasGradient
                                      ? BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                          gradient: const RadialGradient(
                                            radius: 4,
                                            colors: [
                                              Color(0xFF222222),
                                              Color(0xFF999999),
                                              Color(0xFF222222),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 40,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Center(
                                      child: Icon(
                                        Icons.mic_none,
                                        size: 20,
                                        color: micIconColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                indent: 18,
                                endIndent: 18,
                                color: Color(0xFFFFFFFF).withOpacity(0.08),
                                width: 1,
                              ),

                              GestureDetector(
                                onTap:
                                    canRecord &&
                                        !isAudioRecording &&
                                        !isVideoRecording
                                    ? () => context
                                          .read<HostQuestionCubit>()
                                          .recordVideo()
                                    : null,
                                child: Container(
                                  width: 54,
                                  height: 56,
                                  decoration: cameraHasGradient
                                      ? BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                          gradient: const RadialGradient(
                                            radius: 4,
                                            colors: [
                                              Color(0xFF222222),
                                              Color(0xFF999999),
                                              Color(0xFF222222),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 40,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: cameraIconColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: NextButton(isEnabled: true, onPressed: () {}),
              ),
            ),
          ],
        );
      },
    );
  }
}
