import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/schedule_model.dart';

class ScheduleRepository {
  final ApiClient client;

  ScheduleRepository({required this.client});

  Future<List<DoctorDayScheduleModel>> getSchedule() async {
    try {
      final response = await client.dio.get(ApiEndpoints.doctorSchedule);
      final List data = response.data['data'] as List? ?? [];
      return data
          .map((e) => DoctorDayScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<List<DoctorDayScheduleModel>> updateSchedule(
    List<DoctorDayScheduleModel> items,
  ) async {
    try {
      final response = await client.dio.put(
        ApiEndpoints.doctorSchedule,
        data: {
          'schedule': items.map((e) => e.toJson()).toList(),
        },
      );
      final List data = response.data['data'] as List? ?? [];
      return data
          .map((e) => DoctorDayScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ScheduleRepository(client: client);
});
