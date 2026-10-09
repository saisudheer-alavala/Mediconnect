import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/schedule/data/schedule_repository.dart';
import 'package:mediconnect/features/schedule/domain/schedule_model.dart';
import 'package:mediconnect/features/schedule/presentation/schedule_controller.dart';

class _FakeScheduleRepository extends ScheduleRepository {
  _FakeScheduleRepository() : super(client: ApiClient(storage: SecureStorageService()));

  List<DoctorDayScheduleModel> _storedSchedule = [
    const DoctorDayScheduleModel(
      id: 'sch-1',
      dayOfWeek: 1, // Mon
      startTime: '09:00',
      endTime: '17:00',
      slotDurationMinutes: 30,
      breakStartTime: '13:00',
      breakEndTime: '14:00',
      isActive: true,
    ),
    const DoctorDayScheduleModel(
      id: 'sch-2',
      dayOfWeek: 2, // Tue
      startTime: '09:00',
      endTime: '17:00',
      slotDurationMinutes: 30,
      breakStartTime: null,
      breakEndTime: null,
      isActive: false,
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
  group('DoctorDayScheduleModel Unit Tests', () {
    test('serialization and day name formatting', () {
      const day = DoctorDayScheduleModel(
        id: 'day-1',
        dayOfWeek: 1,
        startTime: '08:30',
        endTime: '16:30',
        slotDurationMinutes: 45,
        breakStartTime: '12:00',
        breakEndTime: '13:00',
        isActive: true,
      );

      final json = day.toJson();
      expect(json['id'], 'day-1');
      expect(json['dayOfWeek'], 1);
      expect(json['startTime'], '08:30');
      expect(json['slotDurationMinutes'], 45);

      final parsed = DoctorDayScheduleModel.fromJson(json);
      expect(parsed.id, 'day-1');
      expect(parsed.dayName, 'Monday');
      expect(parsed.shortDayName, 'Mon');
      expect(parsed.isActive, true);
    });

    test('calculatedSlotCount computes slots correctly with lunch break', () {
      // 09:00 to 17:00 (8h = 480m) - 1h lunch (60m) = 420m / 30m = 14 slots
      const withBreak = DoctorDayScheduleModel(
        dayOfWeek: 1,
        startTime: '09:00',
        endTime: '17:00',
        slotDurationMinutes: 30,
        breakStartTime: '13:00',
        breakEndTime: '14:00',
        isActive: true,
      );
      expect(withBreak.calculatedSlotCount, 14);

      // 09:00 to 12:00 (3h = 180m) with 15m slots, no break = 12 slots
      const shortSlots = DoctorDayScheduleModel(
        dayOfWeek: 2,
        startTime: '09:00',
        endTime: '12:00',
        slotDurationMinutes: 15,
        isActive: true,
      );
      expect(shortSlots.calculatedSlotCount, 12);

      // Inactive day generates 0 slots
      final inactive = withBreak.copyWith(isActive: false);
      expect(inactive.calculatedSlotCount, 0);
    });
  });

  group('DoctorScheduleController State Management Tests', () {
    test('initializes with default weekly schedule and 7 days', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
        ],
      );

      final state = container.read(doctorScheduleControllerProvider);
      expect(state.schedule.length, 7);
      expect(state.activeDaysCount, 5); // Mon-Fri active
      expect(state.totalWeeklySlots, greaterThan(0));
      expect(state.isModified, false);
    });

    test('loadSchedule populates state from repository', () async {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
        ],
      );

      final notifier = container.read(doctorScheduleControllerProvider.notifier);
      await notifier.loadSchedule();

      final state = container.read(doctorScheduleControllerProvider);
      expect(state.schedule.length, 2);
      expect(state.schedule.first.id, 'sch-1');
      expect(state.isModified, false);
    });

    test('toggleDay updates active flag and marks isModified true', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
        ],
      );

      final notifier = container.read(doctorScheduleControllerProvider.notifier);
      // Toggle Monday off
      notifier.toggleDay(1, false);

      final state = container.read(doctorScheduleControllerProvider);
      final monday = state.schedule.firstWhere((d) => d.dayOfWeek == 1);
      expect(monday.isActive, false);
      expect(state.isModified, true);
    });

    test('updateWorkingHours and slot duration adjusts slot counts', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
        ],
      );

      final notifier = container.read(doctorScheduleControllerProvider.notifier);
      notifier.updateWorkingHours(1, '08:00', '18:00');
      notifier.updateSlotDuration(1, 60);

      final state = container.read(doctorScheduleControllerProvider);
      final monday = state.schedule.firstWhere((d) => d.dayOfWeek == 1);
      expect(monday.startTime, '08:00');
      expect(monday.endTime, '18:00');
      expect(monday.slotDurationMinutes, 60);
      expect(state.isModified, true);
    });

    test('updateBreak toggles break interval', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
        ],
      );

      final notifier = container.read(doctorScheduleControllerProvider.notifier);
      notifier.updateBreak(1, null, null);

      var state = container.read(doctorScheduleControllerProvider);
      var monday = state.schedule.firstWhere((d) => d.dayOfWeek == 1);
      expect(monday.breakStartTime, isNull);

      notifier.updateBreak(1, '12:30', '13:30');
      state = container.read(doctorScheduleControllerProvider);
      monday = state.schedule.firstWhere((d) => d.dayOfWeek == 1);
      expect(monday.breakStartTime, '12:30');
      expect(monday.breakEndTime, '13:30');
    });

    test('saveSchedule persists changes and shows status notice', () async {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
        ],
      );

      final notifier = container.read(doctorScheduleControllerProvider.notifier);
      notifier.toggleDay(6, true); // activate Saturday
      expect(container.read(doctorScheduleControllerProvider).isModified, true);

      final success = await notifier.saveSchedule();
      expect(success, true);

      final state = container.read(doctorScheduleControllerProvider);
      expect(state.isModified, false);
      expect(state.statusNotice, contains('saved successfully'));
    });
  });
}
