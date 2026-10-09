class MedicineReminderModel {
  final String id;
  final String medicineId;
  final String reminderTime; // e.g. "08:00"

  const MedicineReminderModel({
    required this.id,
    required this.medicineId,
    required this.reminderTime,
  });

  factory MedicineReminderModel.fromJson(Map<String, dynamic> json) {
    return MedicineReminderModel(
      id: json['id'] as String? ?? '',
      medicineId: json['medicineId'] as String? ?? '',
      reminderTime: json['reminderTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'reminderTime': reminderTime,
    };
  }
}

class MedicineModel {
  final String id;
  final String patientId;
  final String name;
  final String dosage;
  final String frequency;
  final String? instructions;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<MedicineReminderModel> reminders;

  const MedicineModel({
    required this.id,
    required this.patientId,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.instructions,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.reminders = const [],
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      instructions: json['instructions'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map((e) => MedicineReminderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'reminders': reminders.map((r) => r.toJson()).toList(),
    };
  }
}

class TodayDoseItem {
  final String medicineId;
  final String medicineName;
  final String dosage;
  final String frequency;
  final String? instructions;
  final String reminderId;
  final String reminderTime;
  final DateTime scheduledTime;
  final String status; // 'PENDING', 'TAKEN', 'SKIPPED', 'MISSED'
  final String? logId;
  final DateTime? takenTime;
  final String? notes;

  const TodayDoseItem({
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    this.instructions,
    required this.reminderId,
    required this.reminderTime,
    required this.scheduledTime,
    required this.status,
    this.logId,
    this.takenTime,
    this.notes,
  });

  bool get isTaken => status == 'TAKEN';
  bool get isSkipped => status == 'SKIPPED';
  bool get isPending => status == 'PENDING';

  factory TodayDoseItem.fromJson(Map<String, dynamic> json) {
    return TodayDoseItem(
      medicineId: json['medicineId'] as String? ?? '',
      medicineName: json['medicineName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      instructions: json['instructions'] as String?,
      reminderId: json['reminderId'] as String? ?? '',
      reminderTime: json['reminderTime'] as String? ?? '',
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'PENDING',
      logId: json['logId'] as String?,
      takenTime: json['takenTime'] != null
          ? DateTime.parse(json['takenTime'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  TodayDoseItem copyWith({
    String? status,
    String? logId,
    DateTime? takenTime,
    String? notes,
  }) {
    return TodayDoseItem(
      medicineId: medicineId,
      medicineName: medicineName,
      dosage: dosage,
      frequency: frequency,
      instructions: instructions,
      reminderId: reminderId,
      reminderTime: reminderTime,
      scheduledTime: scheduledTime,
      status: status ?? this.status,
      logId: logId ?? this.logId,
      takenTime: takenTime ?? this.takenTime,
      notes: notes ?? this.notes,
    );
  }
}

class AdherenceReportModel {
  final int totalDoses;
  final int takenDoses;
  final int skippedDoses;
  final int missedDoses;
  final double adherenceRatePercentage;
  final int periodDays;

  const AdherenceReportModel({
    required this.totalDoses,
    required this.takenDoses,
    required this.skippedDoses,
    required this.missedDoses,
    required this.adherenceRatePercentage,
    required this.periodDays,
  });

  factory AdherenceReportModel.fromJson(Map<String, dynamic> json) {
    return AdherenceReportModel(
      totalDoses: (json['totalDoses'] as num?)?.toInt() ?? 0,
      takenDoses: (json['takenDoses'] as num?)?.toInt() ?? 0,
      skippedDoses: (json['skippedDoses'] as num?)?.toInt() ?? 0,
      missedDoses: (json['missedDoses'] as num?)?.toInt() ?? 0,
      adherenceRatePercentage:
          (json['adherenceRatePercentage'] as num?)?.toDouble() ?? 100.0,
      periodDays: (json['periodDays'] as num?)?.toInt() ?? 7,
    );
  }
}
