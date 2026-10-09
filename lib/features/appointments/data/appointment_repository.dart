import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/appointment_model.dart';

class AppointmentRepository {
  final ApiClient client;

  AppointmentRepository({required this.client});

  Future<List<AppointmentModel>> getAppointments({
    String? status,
    bool? upcomingOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (upcomingOnly != null) queryParams['upcomingOnly'] = upcomingOnly.toString();

      final response = await client.dio.get(
        ApiEndpoints.appointments,
        queryParameters: queryParams,
      );
      final List data = response.data['data'] as List? ?? [];
      return data.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      final response = await client.dio.get(ApiEndpoints.appointmentDetails(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return AppointmentModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<AppointmentModel> bookAppointment(Map<String, dynamic> payload) async {
    try {
      final response = await client.dio.post(
        ApiEndpoints.appointments,
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AppointmentModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<AppointmentModel> cancelAppointment(String id, {String? reason}) async {
    try {
      final response = await client.dio.patch(
        ApiEndpoints.updateAppointmentStatus(id),
        data: {
          'status': 'CANCELLED',
          if (reason != null && reason.isNotEmpty) 'cancellationReason': reason,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AppointmentModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<AppointmentModel> updateStatus(String id, String status) async {
    try {
      final response = await client.dio.patch(
        ApiEndpoints.updateAppointmentStatus(id),
        data: {'status': status},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AppointmentModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AppointmentRepository(client: client);
});
