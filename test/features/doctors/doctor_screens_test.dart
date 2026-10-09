import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/doctors/data/doctor_repository.dart';
import 'package:mediconnect/features/doctors/domain/doctor_model.dart';
import 'package:mediconnect/features/doctors/presentation/doctor_details_screen.dart';
import 'package:mediconnect/features/doctors/presentation/doctor_search_screen.dart';
import 'package:mediconnect/features/reviews/data/review_repository.dart';
import 'package:mediconnect/features/reviews/domain/review_model.dart';

const _sampleDoctor = DoctorModel(
  id: 'doc-test-1',
  userId: 'u-1',
  fullName: 'Dr. Sarah Jenkins',
  qualification: 'MBBS, MD (Cardiology)',
  licenseNumber: 'MD-CARD-88321',
  experienceYears: 12,
  clinicName: 'City Heart Hospital',
  clinicAddress: '424 Health Park Blvd, Suite 300',
  consultationFee: 75.0,
  isVerified: true,
  bio: 'Senior consultant cardiologist.',
  specialization: SpecializationModel(id: 'spec-cardio', name: 'Cardiology'),
  availabilities: [
    DoctorAvailabilityModel(
      id: 'av-1',
      doctorId: 'doc-test-1',
      dayOfWeek: 1,
      startTime: '09:00',
      endTime: '17:00',
    ),
  ],
);

class _FakeDoctorRepository extends DoctorRepository {
  _FakeDoctorRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<List<SpecializationModel>> getSpecializations() async {
    return const [
      SpecializationModel(id: 'spec-cardio', name: 'Cardiology', doctorCount: 4),
      SpecializationModel(id: 'spec-derm', name: 'Dermatology', doctorCount: 6),
    ];
  }

  @override
  Future<DoctorModel> getDoctorById(String id) async {
    return _sampleDoctor;
  }
}

class _FakeReviewRepository extends ReviewRepository {
  _FakeReviewRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<List<ReviewModel>> getDoctorReviews(
    String doctorId, {
    int page = 1,
    int limit = 10,
    int? minRating,
  }) async {
    return [];
  }

  @override
  Future<RatingSummaryModel> getDoctorRatingSummary(String doctorId) async {
    return const RatingSummaryModel(
      doctorId: 'doc-test-1',
      averageRating: 4.9,
      totalReviews: 12,
      ratingBreakdown: RatingBreakdownModel(stars5: 10, stars4: 2),
    );
  }
}


void main() {
  group('DoctorSearchScreen Tests', () {
    testWidgets('renders search field, specialization filters and doctor cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorRepositoryProvider.overrideWithValue(_FakeDoctorRepository()),
          ],
          child: const MaterialApp(
            home: DoctorSearchScreen(),
          ),
        ),
      );

      // Verify header and search input
      expect(find.text('Find Doctors & Specialists'), findsOneWidget);
      expect(find.text('Search doctor, specialty, or clinic...'), findsOneWidget);

      // Verify specialization filter chips
      expect(find.widgetWithText(FilterChip, 'All Specialties'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Cardiology'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Dermatology'), findsOneWidget);

      // Verify doctors list initially renders fallback doctors
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('City Heart Hospital'), findsOneWidget);
      expect(find.text('Dr. Marcus Vance'), findsOneWidget);

      // Search for specific doctor
      await tester.enterText(find.byType(TextField), 'Marcus');
      await tester.pump();

      // Only Dr. Marcus Vance should remain
      expect(find.text('Dr. Marcus Vance'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsNothing);
    });
  });

  group('DoctorDetailsScreen Tests', () {
    testWidgets('renders doctor profile details, metrics, and triggers booking CTA', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorRepositoryProvider.overrideWithValue(_FakeDoctorRepository()),
            reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
          ],
          child: const MaterialApp(
            home: DoctorDetailsScreen(doctor: _sampleDoctor),
          ),
        ),
      );

      // Verify title & hero
      expect(find.text('Doctor Profile'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('MBBS, MD (Cardiology)'), findsOneWidget);

      // Verify metrics
      expect(find.text('12+ Yrs'), findsOneWidget);
      expect(find.text('4.9 ★'), findsOneWidget);
      expect(find.text('Verified'), findsWidgets);

      // Verify clinic info & weekly hours
      expect(find.text('City Heart Hospital'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('09:00 - 17:00'), findsOneWidget);

      // Verify booking CTA
      expect(find.text('Book Consultation'), findsOneWidget);
      await tester.tap(find.text('Book Consultation'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
