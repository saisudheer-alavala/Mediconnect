import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/doctors/data/doctor_repository.dart';
import 'package:mediconnect/features/doctors/domain/doctor_model.dart';
import 'package:mediconnect/features/doctors/presentation/doctor_details_screen.dart';
import 'package:mediconnect/features/reviews/data/review_repository.dart';
import 'package:mediconnect/features/reviews/domain/review_model.dart';
import 'package:mediconnect/features/reviews/presentation/widgets/rating_breakdown_header.dart';
import 'package:mediconnect/features/reviews/presentation/widgets/review_card.dart';
import 'package:mediconnect/features/reviews/presentation/widgets/write_review_sheet.dart';

class _FakeReviewRepository extends ReviewRepository {
  _FakeReviewRepository() : super(client: ApiClient(storage: SecureStorageService()));

  final List<ReviewModel> _items = [
    ReviewModel(
      id: 'rev-w-1',
      doctorId: 'doc-test-1',
      patientId: 'pat-w-1',
      patientName: 'Alice Springs',
      rating: 5,
      title: 'Top Tier Care',
      comment: 'Very helpful medication titration and explanation.',
      isVerified: true,
      createdAt: DateTime(2026, 10, 8),
    ),
    ReviewModel(
      id: 'rev-w-2',
      doctorId: 'doc-test-1',
      patientId: 'pat-w-2',
      patientName: 'Bob Builder',
      rating: 4,
      title: 'Solid experience',
      comment: 'Pleasant teleconsultation and swift diagnosis.',
      isVerified: true,
      createdAt: DateTime(2026, 10, 7),
    ),
  ];

  @override
  Future<List<ReviewModel>> getDoctorReviews(
    String doctorId, {
    int page = 1,
    int limit = 10,
    int? minRating,
  }) async {
    if (minRating != null) {
      return _items.where((r) => r.rating >= minRating).toList();
    }
    return List.from(_items);
  }

  @override
  Future<RatingSummaryModel> getDoctorRatingSummary(String doctorId) async {
    return const RatingSummaryModel(
      doctorId: 'doc-test-1',
      averageRating: 4.5,
      totalReviews: 2,
      ratingBreakdown: RatingBreakdownModel(
        stars5: 1,
        stars4: 1,
        stars3: 0,
        stars2: 0,
        stars1: 0,
      ),
    );
  }

  @override
  Future<ReviewModel> submitReview(
    String doctorId, {
    required int rating,
    String? title,
    required String comment,
    String? appointmentId,
  }) async {
    final created = ReviewModel(
      id: 'rev-w-created',
      doctorId: doctorId,
      patientId: 'pat-new',
      patientName: 'Verified Patient',
      rating: rating,
      title: title,
      comment: comment,
      appointmentId: appointmentId,
      isVerified: true,
      createdAt: DateTime.now(),
    );
    _items.insert(0, created);
    return created;
  }
}

class _FakeDoctorRepository extends DoctorRepository {
  _FakeDoctorRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<DoctorModel> getDoctorById(String id) async {
    return const DoctorModel(
      id: 'doc-test-1',
      userId: 'u-1',
      fullName: 'Dr. Sarah Jenkins',
      qualification: 'MD, FACC',
      licenseNumber: 'LIC-998822',
      experienceYears: 12,
      clinicName: 'CardioCare Specialists',
      clinicAddress: '450 Health Blvd, Suite 200',
      consultationFee: 120.0,
      isVerified: true,
      bio: 'Board-certified cardiologist specializing in preventive cardiology.',
    );
  }
}

void main() {
  group('ReviewCard Widget Tests', () {
    testWidgets('renders review card with patient details, rating, and verified badge',
        (tester) async {
      final review = ReviewModel(
        id: 'r-1',
        doctorId: 'd-1',
        patientId: 'p-1',
        patientName: 'Amina Patel',
        rating: 5,
        title: 'Wonderful Practitioner',
        comment: 'She listened patiently to my concerns and adjusted my medication smoothly.',
        isVerified: true,
        createdAt: DateTime(2026, 10, 8),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );

      expect(find.text('Amina Patel'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('Wonderful Practitioner'), findsOneWidget);
      expect(find.textContaining('listened patiently'), findsOneWidget);
      expect(find.text('AP'), findsOneWidget); // initials
    });
  });

  group('RatingBreakdownHeader Widget Tests', () {
    testWidgets('renders score, breakdown progress, and handles filter tap',
        (tester) async {
      int? tappedFilter;

      const summary = RatingSummaryModel(
        doctorId: 'd-1',
        averageRating: 4.8,
        totalReviews: 24,
        ratingBreakdown: RatingBreakdownModel(
          stars5: 20,
          stars4: 4,
          stars3: 0,
          stars2: 0,
          stars1: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingBreakdownHeader(
              summary: summary,
              activeFilter: null,
              onFilterChanged: (star) {
                tappedFilter = star;
              },
            ),
          ),
        ),
      );

      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('24 reviews'), findsOneWidget);
      expect(find.text('5★'), findsOneWidget);
      expect(find.text('4★'), findsOneWidget);

      await tester.tap(find.text('5★'));
      await tester.pumpAndSettle();

      expect(tappedFilter, 5);
    });
  });

  group('WriteReviewSheet Widget Tests', () {
    testWidgets('validates empty inputs and submits review successfully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WriteReviewSheet(
                doctorId: 'doc-test-1',
                doctorName: 'Dr. Sarah Jenkins',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Write a Review'), findsOneWidget);
      expect(find.textContaining('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.textContaining('Verified patient reviews help others'), findsOneWidget);

      // Verify star rating selector exists
      expect(find.byKey(const Key('star_rating_5')), findsOneWidget);
      expect(find.byKey(const Key('star_rating_4')), findsOneWidget);

      // Tap 4-star
      await tester.tap(find.byKey(const Key('star_rating_4')));
      await tester.pumpAndSettle();
      expect(find.text('4 - Very Good Experience'), findsOneWidget);

      // Tap submit without text -> trigger validation error
      final submitFinder = find.byKey(const Key('submit_review_button'));
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();
      expect(find.text('Please enter your feedback.'), findsOneWidget);

      // Enter short text (< 5 chars) -> trigger length validation
      await tester.enterText(find.byKey(const Key('review_comment_field')), 'Bad');
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();
      expect(find.text('Feedback must be at least 5 characters long.'), findsOneWidget);

      // Enter valid title and feedback
      await tester.enterText(
        find.byKey(const Key('review_title_field')),
        'Great bedside manner',
      );
      await tester.enterText(
        find.byKey(const Key('review_comment_field')),
        'The doctor was kind, courteous, and answered all queries patiently.',
      );

      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();
    });
  });

  group('DoctorDetailsScreen Reviews Integration Tests', () {
    testWidgets('renders reviews section in doctor details screen', (tester) async {
      const doctor = DoctorModel(
        id: 'doc-test-1',
        userId: 'u-1',
        fullName: 'Dr. Sarah Jenkins',
        qualification: 'MD, FACC',
        licenseNumber: 'LIC-998822',
        experienceYears: 12,
        clinicName: 'CardioCare Specialists',
        consultationFee: 120.0,
        isVerified: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
            doctorRepositoryProvider.overrideWithValue(_FakeDoctorRepository()),
          ],
          child: const MaterialApp(
            home: DoctorDetailsScreen(doctor: doctor),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure Patient Reviews section is scrolled into view
      final reviewsSectionFinder = find.text('Patient Reviews');
      await tester.ensureVisible(reviewsSectionFinder);
      await tester.pumpAndSettle();

      expect(reviewsSectionFinder, findsOneWidget);
      expect(find.text('Review'), findsOneWidget); // Write review button
      expect(find.byKey(const Key('write_review_button')), findsOneWidget);
    });
  });
}
