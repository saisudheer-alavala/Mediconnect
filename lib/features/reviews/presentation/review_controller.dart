import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/review_repository.dart';
import '../domain/review_model.dart';

class DoctorReviewsState {
  final String? currentDoctorId;
  final List<ReviewModel> reviews;
  final RatingSummaryModel summary;
  final bool isLoading;
  final bool isSubmitting;
  final int? activeRatingFilter;
  final String? errorMessage;
  final String? successMessage;

  const DoctorReviewsState({
    this.currentDoctorId,
    required this.reviews,
    required this.summary,
    this.isLoading = false,
    this.isSubmitting = false,
    this.activeRatingFilter,
    this.errorMessage,
    this.successMessage,
  });

  List<ReviewModel> get filteredReviews {
    if (activeRatingFilter == null) return reviews;
    return reviews.where((r) => r.rating == activeRatingFilter).toList();
  }

  DoctorReviewsState copyWith({
    String? currentDoctorId,
    List<ReviewModel>? reviews,
    RatingSummaryModel? summary,
    bool? isLoading,
    bool? isSubmitting,
    int? activeRatingFilter,
    bool clearRatingFilter = false,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return DoctorReviewsState(
      currentDoctorId: currentDoctorId ?? this.currentDoctorId,
      reviews: reviews ?? this.reviews,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      activeRatingFilter: clearRatingFilter ? null : (activeRatingFilter ?? this.activeRatingFilter),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class DoctorReviewsController extends Notifier<DoctorReviewsState> {
  static List<ReviewModel> buildFallbackReviews(String doctorId) {
    final now = DateTime.now();
    return [
      ReviewModel(
        id: 'rev-1',
        doctorId: doctorId,
        patientId: 'pat-1',
        patientName: 'Eleanor Vance',
        rating: 5,
        title: 'Outstanding clinical expertise',
        comment:
            'Dr. Jenkins provided an exceptionally clear consultation. She adjusted my blood pressure regimen and explained all timing guidelines.',
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ReviewModel(
        id: 'rev-2',
        doctorId: doctorId,
        patientId: 'pat-2',
        patientName: 'David Miller',
        rating: 5,
        title: 'Thorough and punctual',
        comment:
            'Very punctual teleconsultation. Reviewing the digital prescription in-app right after the call made medicine pickup frictionless.',
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      ReviewModel(
        id: 'rev-3',
        doctorId: doctorId,
        patientId: 'pat-3',
        patientName: 'Amina Patel',
        rating: 4,
        title: 'Great communication',
        comment:
            'Appreciated how carefully the doctor listened to my symptoms and cross-referenced with my previous vitals history.',
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }

  static RatingSummaryModel buildFallbackSummary(String doctorId) {
    return RatingSummaryModel(
      doctorId: doctorId,
      averageRating: 4.8,
      totalReviews: 3,
      ratingBreakdown: const RatingBreakdownModel(
        stars5: 2,
        stars4: 1,
        stars3: 0,
        stars2: 0,
        stars1: 0,
      ),
    );
  }

  @override
  DoctorReviewsState build() {
    const defaultDoctorId = 'doc-default';
    return DoctorReviewsState(
      currentDoctorId: defaultDoctorId,
      reviews: buildFallbackReviews(defaultDoctorId),
      summary: buildFallbackSummary(defaultDoctorId),
    );
  }

  Future<void> loadReviewsAndSummary(String doctorId) async {
    state = state.copyWith(
      currentDoctorId: doctorId,
      isLoading: true,
      clearMessages: true,
      reviews: buildFallbackReviews(doctorId),
      summary: buildFallbackSummary(doctorId),
    );

    try {
      final repo = ref.read(reviewRepositoryProvider);
      final results = await Future.wait([
        repo.getDoctorReviews(doctorId),
        repo.getDoctorRatingSummary(doctorId),
      ]);

      final reviews = results[0] as List<ReviewModel>;
      final summary = results[1] as RatingSummaryModel;

      state = state.copyWith(
        isLoading: false,
        reviews: reviews.isNotEmpty ? reviews : state.reviews,
        summary: summary.totalReviews > 0 ? summary : state.summary,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setFilter(int? stars) {
    if (state.activeRatingFilter == stars) {
      state = state.copyWith(clearRatingFilter: true);
    } else {
      state = state.copyWith(activeRatingFilter: stars);
    }
  }

  void clearNotice() {
    state = state.copyWith(clearMessages: true);
  }

  Future<bool> submitReview({
    required String doctorId,
    required int rating,
    String? title,
    required String comment,
    String? appointmentId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearMessages: true);

    try {
      final repo = ref.read(reviewRepositoryProvider);
      final newReview = await repo.submitReview(
        doctorId,
        rating: rating,
        title: title,
        comment: comment,
        appointmentId: appointmentId,
      );

      // Prepend review and update summary
      final updatedReviews = [newReview, ...state.reviews];
      final newTotal = state.summary.totalReviews + 1;
      final currentSum = state.summary.averageRating * state.summary.totalReviews;
      final newAvg = double.parse(((currentSum + rating) / newTotal).toStringAsFixed(1));

      final bd = state.summary.ratingBreakdown;
      final updatedBd = RatingBreakdownModel(
        stars5: bd.stars5 + (rating == 5 ? 1 : 0),
        stars4: bd.stars4 + (rating == 4 ? 1 : 0),
        stars3: bd.stars3 + (rating == 3 ? 1 : 0),
        stars2: bd.stars2 + (rating == 2 ? 1 : 0),
        stars1: bd.stars1 + (rating == 1 ? 1 : 0),
      );

      state = state.copyWith(
        isSubmitting: false,
        reviews: updatedReviews,
        summary: RatingSummaryModel(
          doctorId: doctorId,
          averageRating: newAvg,
          totalReviews: newTotal,
          ratingBreakdown: updatedBd,
        ),
        successMessage: 'Thank you! Your verified review has been submitted.',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

final doctorReviewsControllerProvider =
    NotifierProvider<DoctorReviewsController, DoctorReviewsState>(
  DoctorReviewsController.new,
);
