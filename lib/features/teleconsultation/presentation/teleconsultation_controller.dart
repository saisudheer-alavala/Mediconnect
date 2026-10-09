import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/teleconsultation_repository.dart';
import '../domain/teleconsultation_model.dart';

class TeleconsultationState {
  final TeleconsultationSessionModel? session;
  final bool isLoading;
  final bool isAudioMuted;
  final bool isVideoOff;
  final bool isFrontCamera;
  final bool isNotesDrawerOpen;
  final int elapsedSeconds;
  final bool isCallActive;
  final bool isMicReady;
  final bool isCameraReady;
  final bool isNetworkStable;
  final String? errorMessage;

  const TeleconsultationState({
    this.session,
    this.isLoading = false,
    this.isAudioMuted = false,
    this.isVideoOff = false,
    this.isFrontCamera = true,
    this.isNotesDrawerOpen = false,
    this.elapsedSeconds = 0,
    this.isCallActive = false,
    this.isMicReady = true,
    this.isCameraReady = true,
    this.isNetworkStable = true,
    this.errorMessage,
  });

  String get formattedElapsedTime {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  TeleconsultationState copyWith({
    TeleconsultationSessionModel? session,
    bool? isLoading,
    bool? isAudioMuted,
    bool? isVideoOff,
    bool? isFrontCamera,
    bool? isNotesDrawerOpen,
    int? elapsedSeconds,
    bool? isCallActive,
    bool? isMicReady,
    bool? isCameraReady,
    bool? isNetworkStable,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TeleconsultationState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoOff: isVideoOff ?? this.isVideoOff,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isNotesDrawerOpen: isNotesDrawerOpen ?? this.isNotesDrawerOpen,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isCallActive: isCallActive ?? this.isCallActive,
      isMicReady: isMicReady ?? this.isMicReady,
      isCameraReady: isCameraReady ?? this.isCameraReady,
      isNetworkStable: isNetworkStable ?? this.isNetworkStable,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TeleconsultationController extends Notifier<TeleconsultationState> {
  late final TeleconsultationRepository _repository;
  Timer? _callTimer;

  @override
  TeleconsultationState build() {
    _repository = ref.watch(teleconsultationRepositoryProvider);
    ref.onDispose(() {
      _callTimer?.cancel();
    });

    return TeleconsultationState(
      session: _getFallbackSession('appt-1'),
    );
  }

  Future<void> loadSession(String appointmentId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sess = await _repository.getTeleconsultationSession(appointmentId);
      state = state.copyWith(session: sess, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        session: _getFallbackSession(appointmentId),
        isLoading: false,
      );
    }
  }

  void toggleAudio() {
    state = state.copyWith(isAudioMuted: !state.isAudioMuted);
  }

  void toggleVideo() {
    state = state.copyWith(isVideoOff: !state.isVideoOff);
  }

  void switchCamera() {
    state = state.copyWith(isFrontCamera: !state.isFrontCamera);
  }

  void toggleNotesDrawer() {
    state = state.copyWith(isNotesDrawerOpen: !state.isNotesDrawerOpen);
  }

  void startCall() {
    _callTimer?.cancel();
    state = state.copyWith(
      isCallActive: true,
      elapsedSeconds: 0,
    );

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void endCall() {
    _callTimer?.cancel();
    _callTimer = null;
    state = state.copyWith(isCallActive: false);
  }

  TeleconsultationSessionModel _getFallbackSession(String apptId) {
    return TeleconsultationSessionModel(
      appointmentId: apptId,
      channelName: 'careconnect-room-$apptId',
      token: 'sample-secure-rtc-token-$apptId',
      doctorName: 'Dr. Sarah Jenkins',
      doctorSpecialization: 'Cardiology',
      patientName: 'Alex Mercer',
      appointmentDate: DateTime.now(),
      startTime: '10:30',
      endTime: '11:00',
      isDoctorJoined: true,
      isPatientJoined: true,
      status: 'CONFIRMED',
    );
  }
}

final teleconsultationControllerProvider =
    NotifierProvider<TeleconsultationController, TeleconsultationState>(
  TeleconsultationController.new,
);
