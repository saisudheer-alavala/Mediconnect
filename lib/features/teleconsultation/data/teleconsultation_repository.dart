import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/teleconsultation_model.dart';

class TeleconsultationRepository {
  final ApiClient client;

  TeleconsultationRepository({required this.client});

  Future<TeleconsultationSessionModel> getTeleconsultationSession(String appointmentId) async {
    try {
      final response = await client.dio.get('/appointments/$appointmentId/teleconsultation');
      final data = response.data['data'] as Map<String, dynamic>;
      return TeleconsultationSessionModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final teleconsultationRepositoryProvider = Provider<TeleconsultationRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TeleconsultationRepository(client: client);
});
