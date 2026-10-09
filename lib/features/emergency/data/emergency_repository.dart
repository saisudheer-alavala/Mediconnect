import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/emergency_model.dart';

class EmergencyRepository {
  final ApiClient client;

  EmergencyRepository({required this.client});

  Future<MedicalIdModel> getEmergencyProfile() async {
    try {
      final response = await client.dio.get(ApiEndpoints.emergencyProfile);
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicalIdModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<MedicalIdModel> updateMedicalProfile({
    String? bloodGroup,
    String? allergies,
    String? chronicDiseases,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (bloodGroup != null) body['bloodGroup'] = bloodGroup;
      if (allergies != null) body['allergies'] = allergies;
      if (chronicDiseases != null) body['chronicDiseases'] = chronicDiseases;

      final response = await client.dio.put(
        ApiEndpoints.emergencyProfile,
        data: body,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicalIdModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<List<EmergencyContactModel>> getContacts() async {
    try {
      final response = await client.dio.get(ApiEndpoints.emergencyContacts);
      final List data = response.data['data'] as List? ?? [];
      return data
          .map((c) => EmergencyContactModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<EmergencyContactModel> addContact({
    required String name,
    required String relationship,
    required String phone,
    bool isPrimary = false,
  }) async {
    try {
      final response = await client.dio.post(
        ApiEndpoints.emergencyContacts,
        data: {
          'name': name,
          'relationship': relationship,
          'phone': phone,
          'isPrimary': isPrimary,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return EmergencyContactModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<EmergencyContactModel> updateContact({
    required String contactId,
    String? name,
    String? relationship,
    String? phone,
    bool? isPrimary,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (relationship != null) body['relationship'] = relationship;
      if (phone != null) body['phone'] = phone;
      if (isPrimary != null) body['isPrimary'] = isPrimary;

      final response = await client.dio.put(
        ApiEndpoints.emergencyContactDetails(contactId),
        data: body,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return EmergencyContactModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await client.dio.delete(ApiEndpoints.emergencyContactDetails(contactId));
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return EmergencyRepository(client: client);
});
