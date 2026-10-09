import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/medicine_model.dart';

class MedicineRepository {
  final ApiClient client;

  MedicineRepository({required this.client});

  Future<List<MedicineModel>> getMedicines({bool activeOnly = false}) async {
    try {
      final response = await client.dio.get(
        ApiEndpoints.medicines,
        queryParameters: {'activeOnly': activeOnly},
      );
      final List data = response.data['data'] as List? ?? [];
      return data.map((e) => MedicineModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<List<TodayDoseItem>> getTodayMedicines({String? date}) async {
    try {
      final response = await client.dio.get(
        ApiEndpoints.todayMedicines,
        queryParameters: date != null ? {'date': date} : null,
      );
      final List data = response.data['data'] as List? ?? [];
      return data.map((e) => TodayDoseItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<AdherenceReportModel> getAdherenceReport({int days = 7}) async {
    try {
      final response = await client.dio.get(
        ApiEndpoints.medicineAdherence,
        queryParameters: {'days': days},
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return AdherenceReportModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<MedicineModel> createMedicine(Map<String, dynamic> payload) async {
    try {
      final response = await client.dio.post(
        ApiEndpoints.medicines,
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicineModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<MedicineModel> updateMedicine(String id, Map<String, dynamic> payload) async {
    try {
      final response = await client.dio.put(
        ApiEndpoints.medicineDetails(id),
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicineModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<void> deleteMedicine(String id) async {
    try {
      await client.dio.delete(ApiEndpoints.medicineDetails(id));
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<void> logDose(
    String medicineId, {
    required DateTime scheduledTime,
    required String status,
    String? notes,
    DateTime? takenTime,
  }) async {
    try {
      final payload = <String, dynamic>{
        'scheduledTime': scheduledTime.toIso8601String(),
        'status': status,
      };
      if (notes != null) payload['notes'] = notes;
      if (takenTime != null) payload['takenTime'] = takenTime.toIso8601String();

      await client.dio.post(
        ApiEndpoints.logMedicineDose(medicineId),
        data: payload,
      );
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return MedicineRepository(client: client);
});
