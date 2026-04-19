import 'package:equatable/equatable.dart';

enum AudioRecordingStatus { idle, recording, done }

class HostQuestionState extends Equatable {
  final String description;
  final String? audioPath;
  final String? videoPath;
  final AudioRecordingStatus audioStatus;
  final Duration audioDuration;
  final bool isVideoRecording;
  final String? tempAudioPath;

  const HostQuestionState({
    this.description = '',
    this.audioPath,
    this.videoPath,
    this.audioStatus = AudioRecordingStatus.idle,
    this.audioDuration = Duration.zero,
    this.isVideoRecording = false,
    this.tempAudioPath,
  });

  bool get hasMedia => audioPath != null || videoPath != null;
  bool get canRecord => audioPath == null && videoPath == null;

  HostQuestionState copyWith({
    String? description,
    String? audioPath,
    String? videoPath,
    AudioRecordingStatus? audioStatus,
    Duration? audioDuration,
    bool? isVideoRecording,
    String? tempAudioPath,
    bool clearAudio = false,
    bool clearVideo = false,
    bool clearTempAudio = false,
  }) {
    return HostQuestionState(
      description: description ?? this.description,
      audioPath: clearAudio ? null : audioPath ?? this.audioPath,
      videoPath: clearVideo ? null : videoPath ?? this.videoPath,
      audioStatus: audioStatus ?? this.audioStatus,
      audioDuration: audioDuration ?? this.audioDuration,
      isVideoRecording: isVideoRecording ?? this.isVideoRecording,
      tempAudioPath: clearTempAudio
          ? null
          : tempAudioPath ?? this.tempAudioPath,
    );
  }

  @override
  List<Object?> get props => [
    description,
    audioPath,
    videoPath,
    audioStatus,
    audioDuration,
    isVideoRecording,
    tempAudioPath,
  ];
}
