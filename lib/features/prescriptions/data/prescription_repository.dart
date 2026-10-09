import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/prescription_model.dart';

class PrescriptionRepository {
  final ApiClient client;

  PrescriptionRepository({required this.client});

  Future<List<PrescriptionModel>> getPrescriptions() async {
    try {
      final response = await client.dio.get('${ApiEndpoints.prescriptions}/my');
      final List data = response.data['data'] as List? ?? [];
      return data.map((e) => PrescriptionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<PrescriptionModel> getPrescriptionById(String id) async {
    try {
      final response = await client.dio.get(ApiEndpoints.prescriptionDetails(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return PrescriptionModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<PrescriptionModel> getPrescriptionByAppointmentId(String appointmentId) async {
    try {
      final response = await client.dio.get(ApiEndpoints.prescriptionByAppointment(appointmentId));
      final data = response.data['data'] as Map<String, dynamic>;
      return PrescriptionModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<PrescriptionModel> issuePrescription(Map<String, dynamic> payload) async {
    try {
      final response = await client.dio.post(
        ApiEndpoints.prescriptions,
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return PrescriptionModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final prescriptionRepositoryProvider = Provider<PrescriptionRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PrescriptionRepository(client: client);
});
