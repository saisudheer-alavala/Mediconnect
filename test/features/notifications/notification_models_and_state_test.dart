import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/notifications/data/notification_repository.dart';
import 'package:mediconnect/features/notifications/domain/notification_model.dart';
import 'package:mediconnect/features/notifications/presentation/notification_controller.dart';

class _FakeNotificationRepository extends NotificationRepository {
  _FakeNotificationRepository() : super(client: ApiClient(storage: SecureStorageService()));

  final List<NotificationModel> _items = [
    NotificationModel(
      id: 'notif-t-1',
      title: 'Medication Alert: Lisinopril',
      message: 'Take 10mg tablet.',
      type: NotificationCategory.medicine,
      isRead: false,
      createdAt: DateTime(2026, 10, 8),
    ),
    NotificationModel(
      id: 'notif-t-2',
      title: 'Appointment Reminder',
      message: 'Consultation at 2 PM.',
      type: NotificationCategory.appointment,
      isRead: true,
      createdAt: DateTime(2026, 10, 7),
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false, String? type}) async {
    return List.from(_items);
  }

  @override
  Future<int> getUnreadCount() async {
    return _items.where((n) => !n.isRead).length;
  }

  @override
  Future<NotificationModel> markAsRead(String id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final updated = _items[idx].copyWith(isRead: true);
      _items[idx] = updated;
      return updated;
    }
    return _items.first;
  }

  @override
  Future<int> markAllAsRead() async {
    int count = 0;
    for (int i = 0; i < _items.length; i++) {
      if (!_items[i].isRead) {
        _items[i] = _items[i].copyWith(isRead: true);
        count++;
      }
    }
    return count;
  }

  @override
  Future<void> deleteNotification(String id) async {
    _items.removeWhere((n) => n.id == id);
  }
}

void main() {
  group('NotificationDomainModel Unit Tests', () {
    test('NotificationModel serialization, copyWith, and helpers', () {
      final now = DateTime(2026, 10, 8);
      final notif = NotificationModel(
        id: 'n-1',
        title: 'Dose Reminder',
        message: 'Take Metformin 500mg',
        type: NotificationCategory.medicine,
        isRead: false,
        createdAt: now,
      );

      final json = notif.toJson();
      expect(json['id'], 'n-1');
      expect(json['type'], 'MEDICINE');
      expect(json['title'], 'Dose Reminder');
      expect(json['isRead'], false);

      final parsed = NotificationModel.fromJson(json);
      expect(parsed.id, 'n-1');
      expect(parsed.type, NotificationCategory.medicine);
      expect(parsed.formattedTimeAgo.isNotEmpty, true);

      final updated = parsed.copyWith(isRead: true);
      expect(updated.isRead, true);
    });

    test('NotificationCategory server key mapping and fallbacks', () {
      expect(NotificationCategory.fromServer('MEDICINE'), NotificationCategory.medicine);
      expect(NotificationCategory.fromServer('APPOINTMENT'), NotificationCategory.appointment);
      expect(NotificationCategory.fromServer('SYSTEM'), NotificationCategory.system);
      expect(NotificationCategory.fromServer('UNKNOWN'), NotificationCategory.system);
      expect(NotificationCategory.fromServer(null), NotificationCategory.system);
    });
  });

  group('NotificationController State Management Tests', () {
    test('initializes with default notifications and unread counter', () {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
        ],
      );

      final state = container.read(notificationControllerProvider);
      expect(state.notifications.isNotEmpty, true);
      expect(state.unreadCount, greaterThan(0));
      expect(state.activeFilter, isNull);
    });

    test('markAsRead updates item and decrements unreadCount', () async {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
        ],
      );

      final notifier = container.read(notificationControllerProvider.notifier);
      await notifier.loadNotifications();
      final unread = container.read(notificationControllerProvider).notifications.firstWhere((n) => !n.isRead);
      final beforeCount = container.read(notificationControllerProvider).unreadCount;

      await notifier.markAsRead(unread.id);
      final afterState = container.read(notificationControllerProvider);
      expect(afterState.unreadCount, beforeCount - 1);
      expect(afterState.notifications.firstWhere((n) => n.id == unread.id).isRead, true);
    });

    test('markAllAsRead sets all items to read and unreadCount to 0', () async {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
        ],
      );

      final notifier = container.read(notificationControllerProvider.notifier);
      await notifier.loadNotifications();

      await notifier.markAllAsRead();
      final afterState = container.read(notificationControllerProvider);
      expect(afterState.unreadCount, 0);
      expect(afterState.notifications.every((n) => n.isRead), true);
    });

    test('deleteNotification removes item and updates count', () async {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
        ],
      );

      final notifier = container.read(notificationControllerProvider.notifier);
      await notifier.loadNotifications();
      final target = container.read(notificationControllerProvider).notifications.first;

      await notifier.deleteNotification(target.id);
      final afterState = container.read(notificationControllerProvider);
      expect(afterState.notifications.any((n) => n.id == target.id), false);
    });

    test('setFilter narrows filteredNotifications', () async {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
        ],
      );

      final notifier = container.read(notificationControllerProvider.notifier);
      await notifier.loadNotifications();

      notifier.setFilter(NotificationCategory.medicine);
      final filteredState = container.read(notificationControllerProvider);
      expect(
        filteredState.filteredNotifications.every((n) => n.type == NotificationCategory.medicine),
        true,
      );

      notifier.setFilter(null);
      final clearedState = container.read(notificationControllerProvider);
      expect(clearedState.activeFilter, isNull);
    });

    test('simulateAdherenceAlert prepends alert and increments unreadCount', () {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
        ],
      );

      final notifier = container.read(notificationControllerProvider.notifier);
      final initialUnread = container.read(notificationControllerProvider).unreadCount;

      notifier.simulateAdherenceAlert(
        medicineName: 'Carvedilol',
        dosage: '12.5mg',
      );

      final updatedState = container.read(notificationControllerProvider);
      expect(updatedState.unreadCount, initialUnread + 1);
      expect(updatedState.notifications.first.title, contains('Carvedilol'));
      expect(updatedState.notifications.first.type, NotificationCategory.medicine);
      expect(updatedState.notifications.first.isRead, false);
    });
  });
}
