import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum HealthRecordType {
  bloodTest('BLOOD_TEST', 'Blood Test', Icons.bloodtype_rounded, Color(0xFFDC2626)),
  prescription('PRESCRIPTION', 'Prescription', Icons.receipt_long_rounded, Color(0xFF0284C7)),
  xRay('X_RAY', 'X-Ray', Icons.medical_information_rounded, Color(0xFF0D9488)),
  scan('SCAN', 'MRI / CT Scan', Icons.document_scanner_rounded, Color(0xFF7C3AED)),
  dischargeSummary('DISCHARGE_SUMMARY', 'Discharge Summary', Icons.assignment_rounded, Color(0xFFD97706)),
  other('OTHER', 'General Record', Icons.folder_shared_rounded, Color(0xFF475569));

  final String serverKey;
  final String label;
  final IconData icon;
  final Color color;

  const HealthRecordType(this.serverKey, this.label, this.icon, this.color);

  static HealthRecordType fromServer(String? key) {
    if (key == null) return HealthRecordType.other;
    return HealthRecordType.values.firstWhere(
      (e) => e.serverKey.toUpperCase() == key.toUpperCase(),
      orElse: () => HealthRecordType.other,
    );
  }
}

class HealthRecordModel {
  final String id;
  final String patientId;
  final String title;
  final HealthRecordType category;
  final String? description;
  final String fileUrl;
  final int? fileSize;
  final String? mimeType;
  final DateTime uploadedAt;
  final String? patientName;

  const HealthRecordModel({
    required this.id,
    required this.patientId,
    required this.title,
    required this.category,
    this.description,
    required this.fileUrl,
    this.fileSize,
    this.mimeType = 'application/pdf',
    required this.uploadedAt,
    this.patientName,
  });

  String get formattedDate => DateFormat('MMM dd, yyyy').format(uploadedAt);
  String get formattedTime => DateFormat('hh:mm a').format(uploadedAt);

  String get formattedFileSize {
    if (fileSize == null || fileSize == 0) return 'Document';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    DateTime date = DateTime.now();
    if (json['uploadedAt'] != null) {
      date = DateTime.tryParse(json['uploadedAt'] as String) ?? date;
    }

    String? patName;
    if (json['patient'] != null && json['patient'] is Map<String, dynamic>) {
      patName = (json['patient'] as Map<String, dynamic>)['fullName'] as String?;
    }

    return HealthRecordModel(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      title: json['title'] as String? ?? 'Medical Document',
      category: HealthRecordType.fromServer(json['category'] as String?),
      description: json['description'] as String?,
      fileUrl: json['fileUrl'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String? ?? 'application/pdf',
      uploadedAt: date,
      patientName: patName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'title': title,
      'category': category.serverKey,
      'description': description,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  HealthRecordModel copyWith({
    String? id,
    String? patientId,
    String? title,
    HealthRecordType? category,
    String? description,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
    DateTime? uploadedAt,
    String? patientName,
  }) {
    return HealthRecordModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      patientName: patientName ?? this.patientName,
    );
  }
}

class VitalMetricModel {
  final String id;
  final String label;
  final String value;
  final String unit;
  final String status;
  final DateTime recordedAt;
  final IconData icon;
  final Color statusColor;

  const VitalMetricModel({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    required this.recordedAt,
    required this.icon,
    this.statusColor = const Color(0xFF16A34A),
  });

  String get formattedDate => DateFormat('MMM dd').format(recordedAt);

  static List<VitalMetricModel> get defaultVitals => [
        VitalMetricModel(
          id: 'v-1',
          label: 'Blood Pressure',
          value: '118/78',
          unit: 'mmHg',
          status: 'NORMAL',
          recordedAt: DateTime.now().subtract(const Duration(hours: 4)),
          icon: Icons.speed_rounded,
          statusColor: const Color(0xFF16A34A),
        ),
        VitalMetricModel(
          id: 'v-2',
          label: 'Heart Rate',
          value: '72',
          unit: 'bpm',
          status: 'RESTING',
          recordedAt: DateTime.now().subtract(const Duration(hours: 4)),
          icon: Icons.favorite_rounded,
          statusColor: const Color(0xFF0284C7),
        ),
        VitalMetricModel(
          id: 'v-3',
          label: 'Blood Glucose',
          value: '94',
          unit: 'mg/dL',
          status: 'FASTING',
          recordedAt: DateTime.now().subtract(const Duration(days: 1)),
          icon: Icons.water_drop_rounded,
          statusColor: const Color(0xFF0D9488),
        ),
        VitalMetricModel(
          id: 'v-4',
          label: 'Oxygen (SpO2)',
          value: '99',
          unit: '%',
          status: 'OPTIMAL',
          recordedAt: DateTime.now().subtract(const Duration(days: 1)),
          icon: Icons.air_rounded,
          statusColor: const Color(0xFF7C3AED),
        ),
      ];
}
