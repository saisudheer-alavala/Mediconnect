import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/teleconsultation/data/teleconsultation_repository.dart';
import 'package:mediconnect/features/teleconsultation/domain/teleconsultation_model.dart';
import 'package:mediconnect/features/teleconsultation/presentation/teleconsultation_controller.dart';

class _FakeTeleconsultationRepository extends TeleconsultationRepository {
  _FakeTeleconsultationRepository()
      : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<TeleconsultationSessionModel> getTeleconsultationSession(String appointmentId) async {
    return TeleconsultationSessionModel(
      appointmentId: appointmentId,
      channelName: 'room-test-$appointmentId',
      token: 'sample-token',
      doctorName: 'Dr. Jane Smith',
      doctorSpecialization: 'Cardiology',
      patientName: 'Test Patient',
      appointmentDate: DateTime.now(),
      startTime: '10:00',
      endTime: '10:30',
      isDoctorJoined: true,
      isPatientJoined: true,
      status: 'CONFIRMED',
    );
  }
}

void main() {
  group('TeleconsultationSessionModel Tests', () {
    test('fromJson and toJson deserialize and serialize session parameters properly', () {
      final json = {
        'appointmentId': 'appt-test-88',
        'channelName': 'channel-care-88',
        'token': 'rtc-token-xyz',
        'doctorName': 'Dr. Robert Hayes',
        'doctorSpecialization': 'Neurology',
        'patientName': 'Sarah Connor',
        'appointmentDate': '2026-10-08T10:00:00.000Z',
        'startTime': '11:00',
        'endTime': '11:30',
        'isDoctorJoined': true,
        'isPatientJoined': true,
        'status': 'CONFIRMED',
      };

      final session = TeleconsultationSessionModel.fromJson(json);

      expect(session.appointmentId, 'appt-test-88');
      expect(session.channelName, 'channel-care-88');
      expect(session.token, 'rtc-token-xyz');
      expect(session.doctorName, 'Dr. Robert Hayes');
      expect(session.doctorSpecialization, 'Neurology');
      expect(session.patientName, 'Sarah Connor');
      expect(session.timeSlotString, '11:00 - 11:30');
      expect(session.isDoctorJoined, isTrue);

      final outJson = session.toJson();
      expect(outJson['appointmentId'], 'appt-test-88');
      expect(outJson['channelName'], 'channel-care-88');
    });
  });

  group('TeleconsultationController State Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          teleconsultationRepositoryProvider.overrideWithValue(_FakeTeleconsultationRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state initializes with default media settings and fallback session', () {
      final state = container.read(teleconsultationControllerProvider);

      expect(state.session, isNotNull);
      expect(state.isAudioMuted, isFalse);
      expect(state.isVideoOff, isFalse);
      expect(state.isFrontCamera, isTrue);
      expect(state.isCallActive, isFalse);
      expect(state.elapsedSeconds, 0);
      expect(state.formattedElapsedTime, '00:00');
    });

    test('media control toggles flip state flags correctly', () {
      final notifier = container.read(teleconsultationControllerProvider.notifier);

      notifier.toggleAudio();
      expect(container.read(teleconsultationControllerProvider).isAudioMuted, isTrue);
      notifier.toggleAudio();
      expect(container.read(teleconsultationControllerProvider).isAudioMuted, isFalse);

      notifier.toggleVideo();
      expect(container.read(teleconsultationControllerProvider).isVideoOff, isTrue);

      notifier.switchCamera();
      expect(container.read(teleconsultationControllerProvider).isFrontCamera, isFalse);

      notifier.toggleNotesDrawer();
      expect(container.read(teleconsultationControllerProvider).isNotesDrawerOpen, isTrue);
    });

    test('startCall and endCall manage call lifecycle state', () {
      final notifier = container.read(teleconsultationControllerProvider.notifier);

      notifier.startCall();
      expect(container.read(teleconsultationControllerProvider).isCallActive, isTrue);

      notifier.endCall();
      expect(container.read(teleconsultationControllerProvider).isCallActive, isFalse);
    });
  });
}
