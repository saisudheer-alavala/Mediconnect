import 'package:intl/intl.dart';

class RatingBreakdownModel {
  final int stars5;
  final int stars4;
  final int stars3;
  final int stars2;
  final int stars1;

  const RatingBreakdownModel({
    this.stars5 = 0,
    this.stars4 = 0,
    this.stars3 = 0,
    this.stars2 = 0,
    this.stars1 = 0,
  });

  double percentageFor(int stars, int total) {
    if (total == 0) return 0.0;
    final count = switch (stars) {
      5 => stars5,
      4 => stars4,
      3 => stars3,
      2 => stars2,
      1 => stars1,
      _ => 0,
    };
    return count / total;
  }

  factory RatingBreakdownModel.fromJson(Map<String, dynamic> json) {
    return RatingBreakdownModel(
      stars5: json['stars5'] as int? ?? 0,
      stars4: json['stars4'] as int? ?? 0,
      stars3: json['stars3'] as int? ?? 0,
      stars2: json['stars2'] as int? ?? 0,
      stars1: json['stars1'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stars5': stars5,
      'stars4': stars4,
      'stars3': stars3,
      'stars2': stars2,
      'stars1': stars1,
    };
  }
}

class RatingSummaryModel {
  final String doctorId;
  final double averageRating;
  final int totalReviews;
  final RatingBreakdownModel ratingBreakdown;

  const RatingSummaryModel({
    required this.doctorId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
  });

  factory RatingSummaryModel.empty(String doctorId) {
    return RatingSummaryModel(
      doctorId: doctorId,
      averageRating: 0.0,
      totalReviews: 0,
      ratingBreakdown: const RatingBreakdownModel(),
    );
  }

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    return RatingSummaryModel(
      doctorId: json['doctorId'] as String? ?? '',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      ratingBreakdown: json['ratingBreakdown'] != null
          ? RatingBreakdownModel.fromJson(json['ratingBreakdown'] as Map<String, dynamic>)
          : const RatingBreakdownModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingBreakdown': ratingBreakdown.toJson(),
    };
  }
}

class ReviewModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String? appointmentId;
  final int rating;
  final String? title;
  final String comment;
  final bool isVerified;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    this.appointmentId,
    required this.rating,
    this.title,
    required this.comment,
    this.isVerified = true,
    required this.createdAt,
  });

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(createdAt);
  }

  String get initials {
    if (patientName.trim().isEmpty) return 'P';
    final parts = patientName.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String patientName = 'Verified Patient';
    if (json['patient'] != null && json['patient'] is Map) {
      patientName = json['patient']['fullName'] as String? ?? patientName;
    } else if (json['patientName'] != null) {
      patientName = json['patientName'] as String;
    }

    return ReviewModel(
      id: json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: patientName,
      appointmentId: json['appointmentId'] as String?,
      rating: json['rating'] as int? ?? 5,
      title: json['title'] as String?,
      comment: json['comment'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'appointmentId': appointmentId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? patientName,
    String? appointmentId,
    int? rating,
    String? title,
    String? comment,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      appointmentId: appointmentId ?? this.appointmentId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
