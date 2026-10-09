enum UserRole {
  patient,
  doctor,
  admin;

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'DOCTOR':
        return UserRole.doctor;
      case 'ADMIN':
        return UserRole.admin;
      case 'PATIENT':
      default:
        return UserRole.patient;
    }
  }

  String toServerString() {
    switch (this) {
      case UserRole.doctor:
        return 'DOCTOR';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.patient:
        return 'PATIENT';
    }
  }
}

class PatientProfileModel {
  final String id;
  final String fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? allergies;
  final String? chronicDiseases;

  const PatientProfileModel({
    required this.id,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.allergies,
    this.chronicDiseases,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      allergies: json['allergies'] as String?,
      chronicDiseases: json['chronicDiseases'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'chronicDiseases': chronicDiseases,
      };
}

class DoctorProfileModel {
  final String id;
  final String fullName;
  final String qualification;
  final String licenseNumber;
  final int experienceYears;
  final String clinicName;
  final String? clinicAddress;
  final String? specializationName;
  final bool isVerified;
  final String? bio;
  final double? consultationFee;
  final String? avatarUrl;

  const DoctorProfileModel({
    required this.id,
    required this.fullName,
    required this.qualification,
    required this.licenseNumber,
    required this.experienceYears,
    required this.clinicName,
    this.clinicAddress,
    this.specializationName,
    this.isVerified = false,
    this.bio,
    this.consultationFee,
    this.avatarUrl,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    String? specName;
    if (json['specialization'] != null && json['specialization'] is Map) {
      specName = json['specialization']['name'] as String?;
    }

    double? fee;
    if (json['consultationFee'] != null) {
      fee = double.tryParse(json['consultationFee'].toString());
    }

    return DoctorProfileModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      qualification: json['qualification'] as String,
      licenseNumber: json['licenseNumber'] as String,
      experienceYears: json['experienceYears'] as int? ?? 0,
      clinicName: json['clinicName'] as String,
      clinicAddress: json['clinicAddress'] as String?,
      specializationName: specName,
      isVerified: json['isVerified'] as bool? ?? false,
      bio: json['bio'] as String?,
      consultationFee: fee,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'qualification': qualification,
        'licenseNumber': licenseNumber,
        'experienceYears': experienceYears,
        'clinicName': clinicName,
        'clinicAddress': clinicAddress,
        'isVerified': isVerified,
        'bio': bio,
        'consultationFee': consultationFee,
        'avatarUrl': avatarUrl,
      };
}

class UserModel {
  final String id;
  final String email;
  final UserRole role;
  final String? phone;
  final bool isActive;
  final PatientProfileModel? patientProfile;
  final DoctorProfileModel? doctorProfile;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.phone,
    this.isActive = true,
    this.patientProfile,
    this.doctorProfile,
  });

  String get displayName {
    if (doctorProfile != null) {
      return doctorProfile!.fullName;
    }
    if (patientProfile != null) {
      return patientProfile!.fullName;
    }
    return email.split('@').first;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'PATIENT'),
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      patientProfile: json['patientProfile'] != null
          ? PatientProfileModel.fromJson(json['patientProfile'] as Map<String, dynamic>)
          : null,
      doctorProfile: json['doctorProfile'] != null
          ? DoctorProfileModel.fromJson(json['doctorProfile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role.toServerString(),
        'phone': phone,
        'isActive': isActive,
        'patientProfile': patientProfile?.toJson(),
        'doctorProfile': doctorProfile?.toJson(),
      };
}

class AuthTokensModel {
  final String accessToken;
  final String refreshToken;

  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
