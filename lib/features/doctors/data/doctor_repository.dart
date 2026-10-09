import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/doctor_model.dart';

class DoctorRepository {
  final ApiClient client;

  DoctorRepository({required this.client});

  Future<List<SpecializationModel>> getSpecializations() async {
    try {
      final response = await client.dio.get(ApiEndpoints.specializations);
      final List data = response.data['data'] as List? ?? [];
      return data.map((e) => SpecializationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<List<DoctorModel>> getDoctors({
    String? search,
    String? specializationId,
    double? minFee,
    double? maxFee,
    int? minExperience,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (specializationId != null) queryParams['specializationId'] = specializationId;
      if (minFee != null) queryParams['minFee'] = minFee;
      if (maxFee != null) queryParams['maxFee'] = maxFee;
      if (minExperience != null) queryParams['minExperience'] = minExperience;

      final response = await client.dio.get(
        ApiEndpoints.doctors,
        queryParameters: queryParams,
      );
      final data = response.data['data'];
      final List doctorsList = (data is Map<String, dynamic> ? data['doctors'] : data) as List? ?? [];
      return doctorsList.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<DoctorModel> getDoctorById(String id) async {
    try {
      final response = await client.dio.get(ApiEndpoints.doctorDetails(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return DoctorModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<List<DoctorSlotModel>> getAvailableSlots(String doctorId, String date) async {
    try {
      final response = await client.dio.get(
        ApiEndpoints.doctorSlots(doctorId),
        queryParameters: {'date': date},
      );
      final List data = response.data['data'] as List? ?? [];
      return data.map((e) => DoctorSlotModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return DoctorRepository(client: client);
});
