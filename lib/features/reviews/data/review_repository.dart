import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/review_model.dart';

class ReviewRepository {
  final ApiClient client;

  ReviewRepository({required this.client});

  Future<List<ReviewModel>> getDoctorReviews(
    String doctorId, {
    int page = 1,
    int limit = 10,
    int? minRating,
  }) async {
    try {
      final Map<String, dynamic> query = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (minRating != null) {
        query['minRating'] = minRating.toString();
      }

      final response = await client.dio.get(
        ApiEndpoints.doctorReviews(doctorId),
        queryParameters: query,
      );

      final dynamic raw = response.data['data'];
      final List list = (raw is Map && raw['reviews'] is List)
          ? raw['reviews'] as List
          : (raw is List ? raw : []);

      return list
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<RatingSummaryModel> getDoctorRatingSummary(String doctorId) async {
    try {
      final response = await client.dio.get(ApiEndpoints.doctorRatingSummary(doctorId));
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return RatingSummaryModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<ReviewModel> submitReview(
    String doctorId, {
    required int rating,
    String? title,
    required String comment,
    String? appointmentId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'rating': rating,
        'comment': comment,
      };
      if (title != null && title.trim().isNotEmpty) {
        body['title'] = title.trim();
      }
      if (appointmentId != null && appointmentId.trim().isNotEmpty) {
        body['appointmentId'] = appointmentId.trim();
      }

      final response = await client.dio.post(
        ApiEndpoints.submitDoctorReview(doctorId),
        data: body,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final reviewData = (data['review'] != null && data['review'] is Map)
          ? data['review'] as Map<String, dynamic>
          : data;

      return ReviewModel.fromJson(reviewData);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReviewRepository(client: client);
});
