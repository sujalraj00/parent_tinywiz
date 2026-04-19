import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parent_tinywiz/host_question/logic/host_question_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HostQuestionCubit extends Cubit<HostQuestionState> {
  final RecorderController recorderController;
  final ImagePicker _imagePicker;

  HostQuestionCubit()
    : recorderController = RecorderController()
        ..androidEncoder = AndroidEncoder.aac
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100,
      _imagePicker = ImagePicker(),
      super(const HostQuestionState()) {
    print('✅ RecorderController initialized');
  }

  void descriptionChanged(String description) {
    emit(state.copyWith(description: description));
  }

  Future<void> startAudioRecording() async {
    print('🎤 Starting audio recording...');

    // Check permission
    final permissionStatus = await Permission.microphone.request();
    print('🎤 Microphone permission status: $permissionStatus');

    if (permissionStatus.isGranted) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final path =
            '${dir.path}/host_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        print('🎤 Recording path: $path');

        await recorderController.record(path: path);

        print('✅ Recording started successfully');
        emit(state.copyWith(audioStatus: AudioRecordingStatus.recording));
      } catch (e, stackTrace) {
        print('❌ Error starting recording: $e');
        print('   Stack trace: $stackTrace');
        // Emit error state or show error to user
        emit(state.copyWith(audioStatus: AudioRecordingStatus.idle));
      }
    } else {
      print('❌ Microphone permission denied');
      // Could emit an error state here
    }
  }

  Future<void> stopAudioRecording() async {
    print('🛑 Stopping audio recording...');
    try {
      if (recorderController.recorderState == RecorderState.recording) {
        final path = await recorderController.stop(false);
        print('✅ Recording stopped. Path: $path');

        emit(
          state.copyWith(
            audioStatus: AudioRecordingStatus.done,
            tempAudioPath: path,
          ),
        );
      } else {
        print(
          '⚠️ Recorder is not in recording state: ${recorderController.recorderState}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error stopping recording: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  void confirmAudioRecording() {
    if (state.tempAudioPath != null) {
      emit(
        state.copyWith(
          audioPath: state.tempAudioPath,
          tempAudioPath: null,
          clearTempAudio: true,
        ),
      );
    }
  }

  Future<void> cancelAudioRecording() async {
    print('❌ Cancelling audio recording...');
    try {
      if (recorderController.recorderState == RecorderState.recording) {
        await recorderController.stop(false);
      }
      emit(
        state.copyWith(
          audioStatus: AudioRecordingStatus.idle,
          audioDuration: Duration.zero,
          clearTempAudio: true,
        ),
      );
    } catch (e) {
      print('Error cancelling recording: $e');
    }
  }

  void deleteAudio() {
    emit(
      state.copyWith(
        clearAudio: true,
        audioStatus: AudioRecordingStatus.idle,
        audioDuration: Duration.zero,
      ),
    );
  }

  Future<void> recordVideo() async {
    if (await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted) {
      try {
        emit(state.copyWith(isVideoRecording: true));

        final XFile? video = await _imagePicker.pickVideo(
          source: ImageSource.camera,
        );

        if (video != null) {
          emit(state.copyWith(videoPath: video.path, isVideoRecording: false));
        } else {
          emit(state.copyWith(isVideoRecording: false));
        }
      } catch (e) {
        print('Error recording video: $e');
        emit(state.copyWith(isVideoRecording: false));
      }
    } else {
      emit(state.copyWith(isVideoRecording: false));
    }
  }

  void deleteVideo() {
    emit(state.copyWith(clearVideo: true));
  }

  @override
  Future<void> close() {
    recorderController.dispose();
    return super.close();
  }
}
