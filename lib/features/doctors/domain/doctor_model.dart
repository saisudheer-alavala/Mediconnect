class SpecializationModel {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final int doctorCount;

  const SpecializationModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.doctorCount = 0,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    int count = 0;
    if (json['_count'] != null && json['_count']['doctors'] != null) {
      count = (json['_count']['doctors'] as num).toInt();
    }
    return SpecializationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      doctorCount: count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'doctorCount': doctorCount,
    };
  }
}

class DoctorAvailabilityModel {
  final String id;
  final String doctorId;
  final int dayOfWeek; // 0 = Sun, 1 = Mon, ..., 6 = Sat
  final String startTime; // e.g. "09:00"
  final String endTime;   // e.g. "17:00"
  final int slotDurationMinutes;
  final String? breakStartTime;
  final String? breakEndTime;
  final bool isActive;

  const DoctorAvailabilityModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.slotDurationMinutes = 30,
    this.breakStartTime,
    this.breakEndTime,
    this.isActive = true,
  });

  String get dayName {
    switch (dayOfWeek) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return '';
    }
  }

  factory DoctorAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return DoctorAvailabilityModel(
      id: json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
      startTime: json['startTime'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? '17:00',
      slotDurationMinutes: (json['slotDurationMinutes'] as num?)?.toInt() ?? 30,
      breakStartTime: json['breakStartTime'] as String?,
      breakEndTime: json['breakEndTime'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
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

class DoctorModel {
  final String id;
  final String userId;
  final String fullName;
  final String qualification;
  final String licenseNumber;
  final int experienceYears;
  final String clinicName;
  final String? clinicAddress;
  final double consultationFee;
  final bool isVerified;
  final String? bio;
  final String? avatarUrl;
  final SpecializationModel? specialization;
  final List<DoctorAvailabilityModel> availabilities;

  const DoctorModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.qualification,
    required this.licenseNumber,
    required this.experienceYears,
    required this.clinicName,
    this.clinicAddress,
    required this.consultationFee,
    this.isVerified = false,
    this.bio,
    this.avatarUrl,
    this.specialization,
    this.availabilities = const [],
  });

  String get specializationName => specialization?.name ?? 'General Physician';

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    double fee = 50.0;
    if (json['consultationFee'] != null) {
      fee = double.tryParse(json['consultationFee'].toString()) ?? 50.0;
    }

    return DoctorModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      clinicName: json['clinicName'] as String? ?? '',
      clinicAddress: json['clinicAddress'] as String?,
      consultationFee: fee,
      isVerified: json['isVerified'] as bool? ?? false,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      specialization: json['specialization'] != null
          ? SpecializationModel.fromJson(json['specialization'] as Map<String, dynamic>)
          : null,
      availabilities: (json['availabilities'] as List<dynamic>?)
              ?.map((e) => DoctorAvailabilityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'qualification': qualification,
      'licenseNumber': licenseNumber,
      'experienceYears': experienceYears,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'consultationFee': consultationFee,
      'isVerified': isVerified,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'specialization': specialization?.toJson(),
      'availabilities': availabilities.map((a) => a.toJson()).toList(),
    };
  }
}

class DoctorSlotModel {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  const DoctorSlotModel({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory DoctorSlotModel.fromJson(Map<String, dynamic> json) {
    return DoctorSlotModel(
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }
}
