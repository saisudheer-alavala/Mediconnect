import 'dart:math';

class DoctorDayScheduleModel {
  final String? id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;
  final String? breakStartTime;
  final String? breakEndTime;
  final bool isActive;

  const DoctorDayScheduleModel({
    this.id,
    required this.dayOfWeek,
    this.startTime = '09:00',
    this.endTime = '17:00',
    this.slotDurationMinutes = 30,
    this.breakStartTime,
    this.breakEndTime,
    this.isActive = true,
  });

  String get dayName {
    return switch (dayOfWeek) {
      1 => 'Monday',
      2 => 'Tuesday',
      3 => 'Wednesday',
      4 => 'Thursday',
      5 => 'Friday',
      6 => 'Saturday',
      0 => 'Sunday',
      _ => 'Day $dayOfWeek',
    };
  }

  String get shortDayName {
    return switch (dayOfWeek) {
      1 => 'Mon',
      2 => 'Tue',
      3 => 'Wed',
      4 => 'Thu',
      5 => 'Fri',
      6 => 'Sat',
      0 => 'Sun',
      _ => '$dayOfWeek',
    };
  }

  static int _timeToMinutes(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
    } catch (_) {}
    return 0;
  }

  int get calculatedSlotCount {
    if (!isActive) return 0;
    final startMin = _timeToMinutes(startTime);
    final endMin = _timeToMinutes(endTime);
    if (endMin <= startMin) return 0;

    int totalMinutes = endMin - startMin;
    if (breakStartTime != null && breakEndTime != null) {
      final bStart = _timeToMinutes(breakStartTime!);
      final bEnd = _timeToMinutes(breakEndTime!);
      if (bEnd > bStart && bStart >= startMin && bEnd <= endMin) {
        totalMinutes -= (bEnd - bStart);
      }
    }

    if (slotDurationMinutes <= 0) return 0;
    return max(0, totalMinutes ~/ slotDurationMinutes);
  }

  DoctorDayScheduleModel copyWith({
    String? id,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    int? slotDurationMinutes,
    String? breakStartTime,
    String? breakEndTime,
    bool? isActive,
    bool clearBreak = false,
  }) {
    return DoctorDayScheduleModel(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      breakStartTime: clearBreak ? null : (breakStartTime ?? this.breakStartTime),
      breakEndTime: clearBreak ? null : (breakEndTime ?? this.breakEndTime),
      isActive: isActive ?? this.isActive,
    );
  }

  factory DoctorDayScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorDayScheduleModel(
      id: json['id'] as String?,
      dayOfWeek: json['dayOfWeek'] as int? ?? 1,
      startTime: json['startTime'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? '17:00',
      slotDurationMinutes: json['slotDurationMinutes'] as int? ?? 30,
      breakStartTime: json['breakStartTime'] as String?,
      breakEndTime: json['breakEndTime'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'slotDurationMinutes': slotDurationMinutes,
      'breakStartTime': breakStartTime,
      'breakEndTime': breakEndTime,
      'isActive': isActive,
    };
  }
}
