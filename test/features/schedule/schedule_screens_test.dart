import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/schedule/data/schedule_repository.dart';
import 'package:mediconnect/features/schedule/domain/schedule_model.dart';
import 'package:mediconnect/features/schedule/presentation/doctor_schedule_screen.dart';

class _FakeScheduleRepository extends ScheduleRepository {
  _FakeScheduleRepository() : super(client: ApiClient(storage: SecureStorageService()));

  List<DoctorDayScheduleModel> _storedSchedule = [
    const DoctorDayScheduleModel(
      id: 'sch-w-1',
      dayOfWeek: 1, // Monday
      startTime: '09:00',
      endTime: '17:00',
      slotDurationMinutes: 30,
      breakStartTime: '13:00',
      breakEndTime: '14:00',
      isActive: true,
    ),
    const DoctorDayScheduleModel(
      id: 'sch-w-2',
      dayOfWeek: 2, // Tuesday
      startTime: '09:00',
      endTime: '17:00',
      slotDurationMinutes: 30,
      breakStartTime: null,
      breakEndTime: null,
      isActive: true,
    ),
  ];

  @override
  Future<List<DoctorDayScheduleModel>> getSchedule() async {
    return List.from(_storedSchedule);
  }

  @override
  Future<List<DoctorDayScheduleModel>> updateSchedule(
    List<DoctorDayScheduleModel> items,
  ) async {
    _storedSchedule = List.from(items);
    return List.from(_storedSchedule);
  }
}

void main() {
  group('DoctorScheduleScreen Widget Tests', () {
    testWidgets('renders schedule screen with capacity banner, safety notice and days',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
          ],
          child: const MaterialApp(
            home: DoctorScheduleScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Working Hours & Schedule'), findsOneWidget);

      // Verify Capacity Banner
      expect(find.textContaining('Consultation Slots / Week'), findsOneWidget);

      // Verify Safety Notice
      expect(find.textContaining('Schedule modifications update future slot generation'), findsOneWidget);

      // Verify Day names
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);

      // Verify Shift Hours
      expect(find.text('Shift Hours'), findsWidgets);
      expect(find.text('Start'), findsWidgets);
      expect(find.text('End'), findsWidgets);

      // Verify Slot Duration Chips
      expect(find.text('15 mins'), findsWidgets);
      expect(find.text('30 mins'), findsWidgets);
      expect(find.text('45 mins'), findsWidgets);
      expect(find.text('60 mins'), findsWidgets);

      // Verify Save Button
      expect(find.byKey(const Key('save_schedule_button')), findsOneWidget);
    });

    testWidgets('toggling day switch updates day status', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
          ],
          child: const MaterialApp(
            home: DoctorScheduleScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final mondaySwitch = find.byKey(const Key('toggle_day_1'));
      expect(mondaySwitch, findsOneWidget);

      // Toggle Monday off
      await tester.tap(mondaySwitch);
      await tester.pumpAndSettle();

      // Now Monday shows "Day Off · Clinic Closed"
      expect(find.text('Day Off · Clinic Closed'), findsWidgets);
    });

    testWidgets('tapping save button calls repository and shows confirmation notice',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
          ],
          child: const MaterialApp(
            home: DoctorScheduleScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final mondaySwitch = find.byKey(const Key('toggle_day_1'));
      await tester.tap(mondaySwitch);
      await tester.pumpAndSettle();

      final saveButton = find.byKey(const Key('save_schedule_button'));
      expect(find.text('Save Schedule Changes'), findsOneWidget);

      await tester.tap(saveButton);
      await tester.pump();

      // Verify SnackBar shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('saved successfully'), findsOneWidget);
    });
  });
}
