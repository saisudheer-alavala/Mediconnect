import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/schedule_repository.dart';
import '../domain/schedule_model.dart';

class DoctorScheduleState {
  final List<DoctorDayScheduleModel> schedule;
  final bool isLoading;
  final bool isSaving;
  final String? statusNotice;
  final String? errorMessage;
  final bool isModified;

  const DoctorScheduleState({
    required this.schedule,
    this.isLoading = false,
    this.isSaving = false,
    this.statusNotice,
    this.errorMessage,
    this.isModified = false,
  });

  int get totalWeeklySlots {
    return schedule.fold(0, (sum, day) => sum + day.calculatedSlotCount);
  }

  int get activeDaysCount {
    return schedule.where((d) => d.isActive).length;
  }

  DoctorScheduleState copyWith({
    List<DoctorDayScheduleModel>? schedule,
    bool? isLoading,
    bool? isSaving,
    String? statusNotice,
    String? errorMessage,
    bool? isModified,
    bool clearNotice = false,
    bool clearError = false,
  }) {
    return DoctorScheduleState(
      schedule: schedule ?? this.schedule,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      statusNotice: clearNotice ? null : (statusNotice ?? this.statusNotice),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isModified: isModified ?? this.isModified,
    );
  }
}

class DoctorScheduleController extends Notifier<DoctorScheduleState> {
  static List<DoctorDayScheduleModel> defaultWeeklySchedule() {
    return const [
      DoctorDayScheduleModel(
        dayOfWeek: 1, // Monday
        startTime: '09:00',
        endTime: '17:00',
        slotDurationMinutes: 30,
        breakStartTime: '13:00',
        breakEndTime: '14:00',
        isActive: true,
      ),
      DoctorDayScheduleModel(
        dayOfWeek: 2, // Tuesday
        startTime: '09:00',
        endTime: '17:00',
        slotDurationMinutes: 30,
        breakStartTime: '13:00',
        breakEndTime: '14:00',
        isActive: true,
      ),
      DoctorDayScheduleModel(
        dayOfWeek: 3, // Wednesday
        startTime: '09:00',
        endTime: '17:00',
        slotDurationMinutes: 30,
        breakStartTime: '13:00',
        breakEndTime: '14:00',
        isActive: true,
      ),
      DoctorDayScheduleModel(
        dayOfWeek: 4, // Thursday
        startTime: '09:00',
        endTime: '17:00',
        slotDurationMinutes: 30,
        breakStartTime: '13:00',
        breakEndTime: '14:00',
        isActive: true,
      ),
      DoctorDayScheduleModel(
        dayOfWeek: 5, // Friday
        startTime: '09:00',
        endTime: '17:00',
        slotDurationMinutes: 30,
        breakStartTime: '13:00',
        breakEndTime: '14:00',
        isActive: true,
      ),
      DoctorDayScheduleModel(
        dayOfWeek: 6, // Saturday
        startTime: '10:00',
        endTime: '14:00',
        slotDurationMinutes: 30,
        breakStartTime: null,
        breakEndTime: null,
        isActive: false,
      ),
      DoctorDayScheduleModel(
        dayOfWeek: 0, // Sunday
        startTime: '10:00',
        endTime: '14:00',
        slotDurationMinutes: 30,
        breakStartTime: null,
        breakEndTime: null,
        isActive: false,
      ),
    ];
  }

  @override
  DoctorScheduleState build() {
    return DoctorScheduleState(
      schedule: defaultWeeklySchedule(),
    );
  }

  Future<void> loadSchedule() async {
    state = state.copyWith(isLoading: true, clearNotice: true, clearError: true);
    try {
      final repo = ref.read(scheduleRepositoryProvider);
      final items = await repo.getSchedule();
      if (items.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          schedule: items,
          isModified: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleDay(int dayOfWeek, bool active) {
    final updated = state.schedule.map((d) {
      if (d.dayOfWeek == dayOfWeek) {
        return d.copyWith(isActive: active);
      }
      return d;
    }).toList();

    state = state.copyWith(schedule: updated, isModified: true);
  }

  void updateWorkingHours(int dayOfWeek, String start, String end) {
    final updated = state.schedule.map((d) {
      if (d.dayOfWeek == dayOfWeek) {
        return d.copyWith(startTime: start, endTime: end);
      }
      return d;
    }).toList();

    state = state.copyWith(schedule: updated, isModified: true);
  }

  void updateSlotDuration(int dayOfWeek, int duration) {
    final updated = state.schedule.map((d) {
      if (d.dayOfWeek == dayOfWeek) {
        return d.copyWith(slotDurationMinutes: duration);
      }
      return d;
    }).toList();

    state = state.copyWith(schedule: updated, isModified: true);
  }

  void updateBreak(int dayOfWeek, String? breakStart, String? breakEnd) {
    final updated = state.schedule.map((d) {
      if (d.dayOfWeek == dayOfWeek) {
        if (breakStart == null || breakEnd == null) {
          return d.copyWith(clearBreak: true);
        }
        return d.copyWith(breakStartTime: breakStart, breakEndTime: breakEnd);
      }
      return d;
    }).toList();

    state = state.copyWith(schedule: updated, isModified: true);
  }

  void clearNotice() {
    state = state.copyWith(clearNotice: true, clearError: true);
  }

  Future<bool> saveSchedule() async {
    state = state.copyWith(isSaving: true, clearNotice: true, clearError: true);
    try {
      final repo = ref.read(scheduleRepositoryProvider);
      final updated = await repo.updateSchedule(state.schedule);
      state = state.copyWith(
        isSaving: false,
        schedule: updated.isNotEmpty ? updated : state.schedule,
        isModified: false,
        statusNotice: 'Weekly working hours saved successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

final doctorScheduleControllerProvider =
    NotifierProvider<DoctorScheduleController, DoctorScheduleState>(
  DoctorScheduleController.new,
);
