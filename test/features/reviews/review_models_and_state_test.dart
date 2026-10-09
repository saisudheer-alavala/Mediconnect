import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/reviews/data/review_repository.dart';
import 'package:mediconnect/features/reviews/domain/review_model.dart';
import 'package:mediconnect/features/reviews/presentation/review_controller.dart';

class _FakeReviewRepository extends ReviewRepository {
  _FakeReviewRepository() : super(client: ApiClient(storage: SecureStorageService()));

  final List<ReviewModel> _items = [
    ReviewModel(
      id: 'rev-t-1',
      doctorId: 'doc-123',
      patientId: 'pat-1',
      patientName: 'Sarah Connor',
      rating: 5,
      title: 'Excellent care',
      comment: 'Very thorough explanation of diagnostic findings.',
      isVerified: true,
      createdAt: DateTime(2026, 10, 5),
    ),
    ReviewModel(
      id: 'rev-t-2',
      doctorId: 'doc-123',
      patientId: 'pat-2',
      patientName: 'John Doe',
      rating: 4,
      title: 'Prompt and helpful',
      comment: 'Consultation was on time and medication instructions were clear.',
      isVerified: false,
      createdAt: DateTime(2026, 10, 4),
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
      doctorId: 'doc-123',
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
      id: 'rev-new-99',
      doctorId: doctorId,
      patientId: 'pat-me',
      patientName: 'Test Patient',
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

void main() {
  group('ReviewDomainModel Unit Tests', () {
    test('ReviewModel serialization, formatting and initials', () {
      final now = DateTime(2026, 10, 8);
      final review = ReviewModel(
        id: 'rev-10',
        doctorId: 'doc-1',
        patientId: 'pat-1',
        patientName: 'Marcus Aurelius',
        rating: 5,
        title: 'Masterful Consultation',
        comment: 'Great wisdom and clinical clarity.',
        isVerified: true,
        createdAt: now,
      );

      final json = review.toJson();
      expect(json['id'], 'rev-10');
      expect(json['rating'], 5);
      expect(json['title'], 'Masterful Consultation');
      expect(review.initials, 'MA');
      expect(review.formattedDate, 'Oct 08, 2026');

      final fromJson = ReviewModel.fromJson(json);
      expect(fromJson.id, 'rev-10');
      expect(fromJson.patientName, 'Marcus Aurelius');
      expect(fromJson.isVerified, true);
    });

    test('RatingBreakdownModel percentage calculations', () {
      const breakdown = RatingBreakdownModel(
        stars5: 8,
        stars4: 2,
        stars3: 0,
        stars2: 0,
        stars1: 0,
      );

      expect(breakdown.percentageFor(5, 10), 0.8);
      expect(breakdown.percentageFor(4, 10), 0.2);
      expect(breakdown.percentageFor(3, 10), 0.0);
      expect(breakdown.percentageFor(5, 0), 0.0);
    });

    test('RatingSummaryModel serialization and empty factory', () {
      final empty = RatingSummaryModel.empty('doc-empty');
      expect(empty.totalReviews, 0);
      expect(empty.averageRating, 0.0);

      const summary = RatingSummaryModel(
        doctorId: 'doc-1',
        averageRating: 4.8,
        totalReviews: 12,
        ratingBreakdown: RatingBreakdownModel(stars5: 10, stars4: 2),
      );

      final json = summary.toJson();
      expect(json['averageRating'], 4.8);
      expect(json['totalReviews'], 12);

      final reconstructed = RatingSummaryModel.fromJson(json);
      expect(reconstructed.averageRating, 4.8);
      expect(reconstructed.ratingBreakdown.stars5, 10);
    });
  });

  group('DoctorReviewsController State Management Tests', () {
    test('initializes with fallback reviews and summary', () {
      final container = ProviderContainer(
        overrides: [
          reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
        ],
      );

      final state = container.read(doctorReviewsControllerProvider);
      expect(state.reviews.isNotEmpty, true);
      expect(state.summary.averageRating, greaterThan(0));
      expect(state.activeRatingFilter, isNull);
    });

    test('loadReviewsAndSummary fetches from repository and updates state', () async {
      final container = ProviderContainer(
        overrides: [
          reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
        ],
      );

      final notifier = container.read(doctorReviewsControllerProvider.notifier);
      await notifier.loadReviewsAndSummary('doc-123');

      final state = container.read(doctorReviewsControllerProvider);
      expect(state.currentDoctorId, 'doc-123');
      expect(state.reviews.length, 2);
      expect(state.reviews.first.patientName, 'Sarah Connor');
      expect(state.summary.averageRating, 4.5);
    });

    test('setFilter filters reviews by star count and toggles off', () async {
      final container = ProviderContainer(
        overrides: [
          reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
        ],
      );

      final notifier = container.read(doctorReviewsControllerProvider.notifier);
      await notifier.loadReviewsAndSummary('doc-123');

      notifier.setFilter(5);
      var state = container.read(doctorReviewsControllerProvider);
      expect(state.activeRatingFilter, 5);
      expect(state.filteredReviews.length, 1);
      expect(state.filteredReviews.first.rating, 5);

      // Tapping same filter clears it
      notifier.setFilter(5);
      state = container.read(doctorReviewsControllerProvider);
      expect(state.activeRatingFilter, isNull);
      expect(state.filteredReviews.length, 2);
    });

    test('submitReview prepends review and recalculates summary score', () async {
      final container = ProviderContainer(
        overrides: [
          reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
        ],
      );

      final notifier = container.read(doctorReviewsControllerProvider.notifier);
      await notifier.loadReviewsAndSummary('doc-123');

      final success = await notifier.submitReview(
        doctorId: 'doc-123',
        rating: 5,
        title: 'Life saving guidance',
        comment: 'Doctor immediately detected drug interaction in my regimen.',
      );

      expect(success, true);
      final state = container.read(doctorReviewsControllerProvider);
      expect(state.reviews.length, 3);
      expect(state.reviews.first.title, 'Life saving guidance');
      expect(state.reviews.first.rating, 5);
      expect(state.summary.totalReviews, 3);
      expect(state.summary.ratingBreakdown.stars5, 2);
      expect(state.successMessage, isNotNull);
    });
  });
}
