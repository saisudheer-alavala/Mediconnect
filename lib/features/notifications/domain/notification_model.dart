import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

enum NotificationCategory {
  medicine('MEDICINE', 'Medication', Icons.medication_rounded, AppColors.secondary),
  appointment('APPOINTMENT', 'Appointment', Icons.calendar_month_rounded, AppColors.primary),
  system('SYSTEM', 'System Alert', Icons.notifications_active_rounded, AppColors.accent);

  final String serverKey;
  final String label;
  final IconData icon;
  final Color color;

  const NotificationCategory(this.serverKey, this.label, this.icon, this.color);

  static NotificationCategory fromServer(String? key) {
    if (key == null) return NotificationCategory.system;
    return NotificationCategory.values.firstWhere(
      (e) => e.serverKey.toUpperCase() == key.toUpperCase(),
      orElse: () => NotificationCategory.system,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationCategory type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  String get formattedTimeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      type: NotificationCategory.fromServer(json['type'] as String?),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.serverKey,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
