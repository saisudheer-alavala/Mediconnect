import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/notification_model.dart';

class NotificationRepository {
  final ApiClient client;

  NotificationRepository({required this.client});

  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> query = {};
      if (unreadOnly) query['unreadOnly'] = 'true';
      if (type != null && type.isNotEmpty) query['type'] = type;

      final response = await client.dio.get(
        ApiEndpoints.notifications,
        queryParameters: query.isNotEmpty ? query : null,
      );
      final List data = response.data['data'] as List? ?? [];
      return data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await client.dio.get(ApiEndpoints.unreadNotificationsCount);
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return (data['unreadCount'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<NotificationModel> markAsRead(String id) async {
    try {
      final response = await client.dio.patch(ApiEndpoints.markNotificationRead(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return NotificationModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<int> markAllAsRead() async {
    try {
      final response = await client.dio.patch(ApiEndpoints.markAllNotificationsRead);
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return (data['updatedCount'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await client.dio.delete(ApiEndpoints.deleteNotification(id));
    } catch (e) {
      throw client.handleDioError(e);
    }
  }

  Future<NotificationModel> createNotification(Map<String, dynamic> payload) async {
    try {
      final response = await client.dio.post(
        ApiEndpoints.notifications,
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return NotificationModel.fromJson(data);
    } catch (e) {
      throw client.handleDioError(e);
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationRepository(client: client);
});
