import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/teleconsultation/data/teleconsultation_repository.dart';
import 'package:mediconnect/features/teleconsultation/domain/teleconsultation_model.dart';
import 'package:mediconnect/features/teleconsultation/presentation/teleconsultation_room_screen.dart';
import 'package:mediconnect/features/teleconsultation/presentation/waiting_room_screen.dart';

class _FakeTeleconsultationRepository extends TeleconsultationRepository {
  _FakeTeleconsultationRepository()
      : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<TeleconsultationSessionModel> getTeleconsultationSession(String appointmentId) async {
    return TeleconsultationSessionModel(
      appointmentId: appointmentId,
      channelName: 'room-widget-$appointmentId',
      token: 'sample-widget-token',
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

void main() {
  group('WaitingRoomScreen Widget Tests', () {
    testWidgets('renders doctor summary, media diagnostics, and emergency disclaimer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            teleconsultationRepositoryProvider.overrideWithValue(_FakeTeleconsultationRepository()),
          ],
          child: const MaterialApp(
            home: WaitingRoomScreen(appointmentId: 'appt-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app bar & title
      expect(find.text('Consultation Waiting Room'), findsOneWidget);

      // Verify doctor card
      expect(find.text('Dr. Sarah Jenkins'), findsWidgets);
      expect(find.text('Cardiology'), findsWidgets);
      expect(find.text('Online'), findsOneWidget);

      // Verify device diagnostics
      expect(find.text('Microphone Input'), findsOneWidget);
      expect(find.text('High-Definition Camera'), findsOneWidget);
      expect(find.text('End-to-End Encryption & Latency'), findsOneWidget);

      // Verify emergency disclaimer
      expect(find.textContaining('Teleconsultation Emergency Boundary'), findsOneWidget);

      // Test pre-call toggle
      final micToggle = find.byKey(const Key('waiting_room_mic_toggle'));
      expect(micToggle, findsOneWidget);
      await tester.tap(micToggle);
      await tester.pumpAndSettle();

      // CTA button
      expect(find.byKey(const Key('enter_consultation_button')), findsOneWidget);
    });
  });

  group('TeleconsultationRoomScreen Widget Tests', () {
    testWidgets('renders active consultation call UI, PiP tile, notes drawer and end call dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            teleconsultationRepositoryProvider.overrideWithValue(_FakeTeleconsultationRepository()),
          ],
          child: const MaterialApp(
            home: TeleconsultationRoomScreen(appointmentId: 'appt-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify remote participant & status
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('Speaking • High Fidelity Audio'), findsOneWidget);

      // Verify local PiP tile
      expect(find.byKey(const Key('local_pip_tile')), findsOneWidget);

      // Verify security and encryption badge
      expect(find.text('E2EE 256-Bit'), findsOneWidget);

      // Verify in-call floating controls
      expect(find.byKey(const Key('call_mute_toggle')), findsOneWidget);
      expect(find.byKey(const Key('call_video_toggle')), findsOneWidget);
      expect(find.byKey(const Key('call_camera_switch')), findsOneWidget);
      expect(find.byKey(const Key('call_notes_toggle')), findsOneWidget);
      expect(find.byKey(const Key('end_call_button')), findsOneWidget);

      // Open clinical notes drawer
      await tester.tap(find.byKey(const Key('call_notes_toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Live Clinical Notes'), findsOneWidget);

      // Tap End Call button to trigger confirmation prompt
      await tester.tap(find.byKey(const Key('end_call_button')));
      await tester.pumpAndSettle();

      expect(find.text('End Consultation'), findsOneWidget);
      expect(find.text('Return to Call'), findsOneWidget);
      expect(find.text('Conclude Consultation'), findsOneWidget);
    });
  });
}
