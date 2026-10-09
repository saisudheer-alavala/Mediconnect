import 'package:flutter/material.dart';

class EmergencyContactModel {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final bool isPrimary;
  final DateTime? createdAt;

  const EmergencyContactModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.isPrimary = false,
    this.createdAt,
  });

  EmergencyContactModel copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phone,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return EmergencyContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'isPrimary': isPrimary,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}

class MedicalIdModel {
  final String id;
  final String fullName;
  final String bloodGroup;
  final String allergies;
  final String chronicDiseases;
  final List<EmergencyContactModel> emergencyContacts;

  const MedicalIdModel({
    required this.id,
    required this.fullName,
    required this.bloodGroup,
    required this.allergies,
    required this.chronicDiseases,
    this.emergencyContacts = const [],
  });

  MedicalIdModel copyWith({
    String? id,
    String? fullName,
    String? bloodGroup,
    String? allergies,
    String? chronicDiseases,
    List<EmergencyContactModel>? emergencyContacts,
  }) {
    return MedicalIdModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  factory MedicalIdModel.fromJson(Map<String, dynamic> json) {
    final contactsList = (json['emergencyContacts'] as List? ?? [])
        .map((c) => EmergencyContactModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return MedicalIdModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Patient',
      bloodGroup: json['bloodGroup'] as String? ?? 'Unknown',
      allergies: json['allergies'] as String? ?? 'None reported',
      chronicDiseases: json['chronicDiseases'] as String? ?? 'None reported',
      emergencyContacts: contactsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
    };
  }
}

class FirstAidProtocolModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final List<String> steps;

  const FirstAidProtocolModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.steps,
  });

  static List<FirstAidProtocolModel> get standardProtocols => const [
        FirstAidProtocolModel(
          id: 'cpr',
          title: 'Adult CPR (Cardiac Arrest)',
          subtitle: 'Hands-only cardiopulmonary resuscitation',
          icon: Icons.favorite_rounded,
          themeColor: Color(0xFFDC2626),
          steps: [
            'Check responsiveness and call Emergency (911/112) immediately.',
            'Place the heel of your hand on the center of the chest and interlock other hand.',
            'Push hard and fast at 100–120 compressions/min (to the rhythm of "Stayin Alive").',
            'Allow the chest to recoil fully between compressions.',
            'If AED is available, turn on and follow voice instructions promptly.',
          ],
        ),
        FirstAidProtocolModel(
          id: 'stroke',
          title: 'Stroke Identification (F.A.S.T)',
          subtitle: 'Rapid assessment for cerebrovascular accident',
          icon: Icons.psychology_rounded,
          themeColor: Color(0xFFEA580C),
          steps: [
            'F - Face Drooping: Ask person to smile. Does one side of the face droop?',
            'A - Arm Weakness: Ask person to raise both arms. Does one arm drift downward?',
            'S - Speech Difficulty: Ask them to repeat a simple phrase. Is speech slurred?',
            'T - Time to call 911/112: If any of these signs appear, call emergency immediately.',
            'Note the exact time symptoms first presented for medical responders.',
          ],
        ),
        FirstAidProtocolModel(
          id: 'anaphylaxis',
          title: 'Severe Anaphylaxis Response',
          subtitle: 'Immediate acute allergic reaction intervention',
          icon: Icons.warning_amber_rounded,
          themeColor: Color(0xFF9333EA),
          steps: [
            'Administer Epinephrine auto-injector (EpiPen) into the outer mid-thigh.',
            'Hold the auto-injector firmly in place for 3 full seconds.',
            'Call emergency services (911/112) immediately after administering.',
            'Lay the patient flat with legs elevated unless they have breathing difficulty.',
            'If symptoms persist after 5–15 minutes, prepare a second dose if available.',
          ],
        ),
        FirstAidProtocolModel(
          id: 'choking',
          title: 'Choking (Heimlich Maneuver)',
          subtitle: 'Relieving acute foreign airway obstruction',
          icon: Icons.air_rounded,
          themeColor: Color(0xFF2563EB),
          steps: [
            'Confirm choking: Ask "Are you choking?". If they cannot speak or cough, act immediately.',
            'Stand behind the person and wrap arms around their waist.',
            'Form a fist with one hand just above the person\'s navel.',
            'Grasp the fist with your other hand and perform quick, upward abdominal thrusts.',
            'Repeat thrusts until the object is expelled or the person becomes unconscious.',
          ],
        ),
      ];
}
