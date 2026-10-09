import 'package:intl/intl.dart';

class PrescriptionMedicineModel {
  final String id;
  final String medicineName;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String? instructions;

  const PrescriptionMedicineModel({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    this.instructions,
  });

  factory PrescriptionMedicineModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedicineModel(
      id: json['id'] as String? ?? '',
      medicineName: json['medicineName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 1,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'durationDays': durationDays,
      'instructions': instructions,
    };
  }
}

class PrescriptionModel {
  final String id;
  final String? appointmentId;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String qualification;
  final String licenseNumber;
  final String clinicName;
  final String? clinicAddress;
  final String? patientName;
  final String diagnosis;
  final String? generalInstructions;
  final DateTime issuedAt;
  final List<PrescriptionMedicineModel> medicines;

  const PrescriptionModel({
    required this.id,
    this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    this.qualification = 'MBBS, MD',
    this.licenseNumber = 'LIC-MED-100',
    required this.clinicName,
    this.clinicAddress,
    this.patientName,
    required this.diagnosis,
    this.generalInstructions,
    required this.issuedAt,
    this.medicines = const [],
  });

  String get formattedIssuedDate => DateFormat('EEE, MMM dd, yyyy').format(issuedAt);
  int get totalMedicinesCount => medicines.length;

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime date = DateTime.now();
    if (json['issuedAt'] != null) {
      date = DateTime.parse(json['issuedAt'] as String);
    }

    String docName = 'Specialist Doctor';
    String spec = 'General Practice';
    String qual = 'MBBS, MD';
    String lic = 'LIC-MED-VERIFIED';
    String clinic = 'MediCare Clinic';
    String? address;

    if (json['doctor'] != null && json['doctor'] is Map<String, dynamic>) {
      final docMap = json['doctor'] as Map<String, dynamic>;
      docName = docMap['fullName'] as String? ?? docName;
      clinic = docMap['clinicName'] as String? ?? clinic;
      address = docMap['clinicAddress'] as String?;
      qual = docMap['qualification'] as String? ?? qual;
      lic = docMap['licenseNumber'] as String? ?? lic;
      if (docMap['specialization'] != null && docMap['specialization'] is Map<String, dynamic>) {
        spec = (docMap['specialization'] as Map<String, dynamic>)['name'] as String? ?? spec;
      }
    }

    String? patName;
    if (json['patient'] != null && json['patient'] is Map<String, dynamic>) {
      patName = (json['patient'] as Map<String, dynamic>)['fullName'] as String?;
    }

    final rawMeds = json['medicines'] as List? ?? [];
    final medsList = rawMeds
        .map((m) => PrescriptionMedicineModel.fromJson(m as Map<String, dynamic>))
        .toList();

    return PrescriptionModel(
      id: json['id'] as String? ?? '',
      appointmentId: json['appointmentId'] as String?,
      patientId: json['patientId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: docName,
      doctorSpecialization: spec,
      qualification: qual,
      licenseNumber: lic,
      clinicName: clinic,
      clinicAddress: address,
      patientName: patName,
      diagnosis: json['diagnosis'] as String? ?? 'General Health Consultation',
      generalInstructions: json['generalInstructions'] as String?,
      issuedAt: date,
      medicines: medsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'qualification': qualification,
      'licenseNumber': licenseNumber,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'patientName': patientName,
      'diagnosis': diagnosis,
      'generalInstructions': generalInstructions,
      'issuedAt': issuedAt.toIso8601String(),
      'medicines': medicines.map((m) => m.toJson()).toList(),
    };
  }
}
