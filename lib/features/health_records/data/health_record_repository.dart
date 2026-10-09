import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/health_record_model.dart';

class HealthRecordRepository {
  final ApiClient client;

  HealthRecordRepository({required this.client});

  Future<List<HealthRecordModel>> getHealthRecords({
    String? category,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> query = {};
      if (category != null && category.isNotEmpty) query['category'] = category;
      if (search != null && search.isNotEmpty) query['search'] = search;

      final response = await client.dio.get(
        ApiEndpoints.healthRecords,
        queryParameters: query.isNotEmpty ? query : null,
      );
      final List data = response.data['data'] as List? ?? [];
      return data
          .map((e) => HealthRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<HealthRecordModel> getHealthRecordById(String id) async {
    try {
      final response = await client.dio.get(ApiEndpoints.healthRecordDetails(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return HealthRecordModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<HealthRecordModel> createHealthRecord(Map<String, dynamic> payload) async {
    try {
      final response = await client.dio.post(
        ApiEndpoints.healthRecords,
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return HealthRecordModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<HealthRecordModel> updateHealthRecord(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await client.dio.put(
        ApiEndpoints.healthRecordDetails(id),
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return HealthRecordModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<void> deleteHealthRecord(String id) async {
    try {
      await client.dio.delete(ApiEndpoints.healthRecordDetails(id));
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final healthRecordRepositoryProvider = Provider<HealthRecordRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return HealthRecordRepository(client: client);
});
