import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/notifications/data/notification_repository.dart';
import 'package:mediconnect/features/notifications/domain/notification_model.dart';
import 'package:mediconnect/features/notifications/presentation/notification_center_screen.dart';

class _FakeNotificationRepository extends NotificationRepository {
  _FakeNotificationRepository() : super(client: ApiClient(storage: SecureStorageService()));

  final List<NotificationModel> _items = [
    NotificationModel(
      id: 'notif-widget-1',
      title: 'Medication Alert: Lisinopril',
      message: 'Take 10mg tablet.',
      type: NotificationCategory.medicine,
      isRead: false,
      createdAt: DateTime(2026, 10, 8),
    ),
    NotificationModel(
      id: 'notif-widget-2',
      title: 'Appointment Reminder',
      message: 'Consultation at 2 PM.',
      type: NotificationCategory.appointment,
      isRead: false,
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
  group('NotificationCenterScreen Widget Tests', () {
    testWidgets('renders notifications screen with unread badge, filters, and items',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.textContaining('NEW'), findsOneWidget);

      // Verify Simulator Card
      expect(find.text('Adherence Reminders Engine'), findsOneWidget);
      expect(find.text('Test Alert'), findsOneWidget);

      // Verify Filter Chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Medication'), findsOneWidget);
      expect(find.text('Appointment'), findsOneWidget);

      // Verify Notification Items
      expect(find.text('Medication Alert: Lisinopril'), findsOneWidget);
      expect(find.text('Appointment Reminder'), findsOneWidget);
    });

    testWidgets('tapping Test Alert simulates live adherence notification', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final testBtn = find.text('Test Alert');
      expect(testBtn, findsOneWidget);
      await tester.tap(testBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('Metoprolol Tartrate'), findsWidgets);
    });

    testWidgets('tapping Read All marks all items as read and clears unread chip',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final readAllBtn = find.text('Read All');
      expect(readAllBtn, findsOneWidget);
      await tester.tap(readAllBtn);
      await tester.pumpAndSettle();

      // Read All button disappears when unreadCount == 0
      expect(find.text('Read All'), findsNothing);
    });

    testWidgets('tapping category filter chip filters notifications list', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository()),
          ],
          child: const MaterialApp(
            home: NotificationCenterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final medChip = find.text('Medication');
      expect(medChip, findsOneWidget);
      await tester.tap(medChip);
      await tester.pumpAndSettle();

      expect(find.text('Medication Alert: Lisinopril'), findsOneWidget);
      expect(find.text('Appointment Reminder'), findsNothing);
    });
  });
}
