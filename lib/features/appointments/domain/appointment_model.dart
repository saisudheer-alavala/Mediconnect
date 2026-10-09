import 'package:intl/intl.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final String startTime; // e.g. "10:00"
  final String endTime;   // e.g. "10:30"
  final String status;    // 'PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'NO_SHOW'
  final String? patientNotes;
  final String? cancellationReason;
  final String doctorName;
  final String specializationName;
  final String clinicName;
  final String? clinicAddress;
  final double consultationFee;
  final String? patientName;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.patientNotes,
    this.cancellationReason,
    required this.doctorName,
    required this.specializationName,
    required this.clinicName,
    this.clinicAddress,
    this.consultationFee = 50.0,
    this.patientName,
  });

  bool get isUpcoming => status == 'CONFIRMED' || status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isPending => status == 'PENDING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';

  String get formattedDate => DateFormat('EEE, MMM dd, yyyy').format(appointmentDate);

  String get formattedTimeSlot {
    try {
      final now = DateTime.now();
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      final startDt = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
      final endDt = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
      return '${DateFormat.jm().format(startDt)} - ${DateFormat.jm().format(endDt)}';
    } catch (_) {
      return '$startTime - $endTime';
    }
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    DateTime apptDate = DateTime.now();
    if (json['appointmentDate'] != null) {
      apptDate = DateTime.parse(json['appointmentDate'] as String);
    }

    String docName = 'Specialist Doctor';
    String spec = 'General Practice';
    String clinic = 'Health Center';
    String? address;
    double fee = 50.0;

    if (json['doctor'] != null && json['doctor'] is Map<String, dynamic>) {
      final docMap = json['doctor'] as Map<String, dynamic>;
      docName = docMap['fullName'] as String? ?? docName;
      clinic = docMap['clinicName'] as String? ?? clinic;
      address = docMap['clinicAddress'] as String?;
      if (docMap['consultationFee'] != null) {
        fee = double.tryParse(docMap['consultationFee'].toString()) ?? fee;
      }
      if (docMap['specialization'] != null && docMap['specialization'] is Map<String, dynamic>) {
        spec = (docMap['specialization'] as Map<String, dynamic>)['name'] as String? ?? spec;
      }
    }

    String? patName;
    if (json['patient'] != null && json['patient'] is Map<String, dynamic>) {
      patName = (json['patient'] as Map<String, dynamic>)['fullName'] as String?;
    }

    return AppointmentModel(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      appointmentDate: apptDate,
      startTime: json['startTime'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? '09:30',
      status: json['status'] as String? ?? 'PENDING',
      patientNotes: json['patientNotes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      doctorName: docName,
      specializationName: spec,
      clinicName: clinic,
      clinicAddress: address,
      consultationFee: fee,
      patientName: patName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'patientNotes': patientNotes,
      'cancellationReason': cancellationReason,
      'doctorName': doctorName,
      'specializationName': specializationName,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'consultationFee': consultationFee,
      'patientName': patientName,
    };
  }

  AppointmentModel copyWith({
    String? status,
    String? cancellationReason,
  }) {
    return AppointmentModel(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      appointmentDate: appointmentDate,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      patientNotes: patientNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      doctorName: doctorName,
      specializationName: specializationName,
      clinicName: clinicName,
      clinicAddress: clinicAddress,
      consultationFee: consultationFee,
      patientName: patientName,
    );
  }
}
