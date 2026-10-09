class TeleconsultationSessionModel {
  final String appointmentId;
  final String channelName;
  final String token;
  final String doctorName;
  final String doctorSpecialization;
  final String patientName;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final bool isDoctorJoined;
  final bool isPatientJoined;
  final String status;

  const TeleconsultationSessionModel({
    required this.appointmentId,
    required this.channelName,
    required this.token,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.patientName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    this.isDoctorJoined = true,
    this.isPatientJoined = true,
    this.status = 'CONFIRMED',
  });

  String get timeSlotString => '$startTime - $endTime';

  factory TeleconsultationSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime apptDate = DateTime.now();
    if (json['appointmentDate'] != null) {
      apptDate = DateTime.parse(json['appointmentDate'] as String);
    }

    return TeleconsultationSessionModel(
      appointmentId: json['appointmentId'] as String? ?? '',
      channelName: json['channelName'] as String? ?? 'consultation-room',
      token: json['token'] as String? ?? 'token-sample',
      doctorName: json['doctorName'] as String? ?? 'Dr. Specialist',
      doctorSpecialization: json['doctorSpecialization'] as String? ?? 'General Practice',
      patientName: json['patientName'] as String? ?? 'Verified Patient',
      appointmentDate: apptDate,
      startTime: json['startTime'] as String? ?? '10:00',
      endTime: json['endTime'] as String? ?? '10:30',
      isDoctorJoined: json['isDoctorJoined'] as bool? ?? true,
      isPatientJoined: json['isPatientJoined'] as bool? ?? true,
      status: json['status'] as String? ?? 'CONFIRMED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'channelName': channelName,
      'token': token,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'patientName': patientName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isDoctorJoined': isDoctorJoined,
      'isPatientJoined': isPatientJoined,
      'status': status,
    };
  }
}
