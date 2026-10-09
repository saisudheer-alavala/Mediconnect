import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';
import '../domain/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final NotificationCategory? activeFilter;
  final bool isLoading;
  final String? statusNotice;

  const NotificationState({
    required this.notifications,
    required this.unreadCount,
    this.activeFilter,
    this.isLoading = false,
    this.statusNotice,
  });

  List<NotificationModel> get filteredNotifications {
    if (activeFilter == null) return notifications;
    return notifications.where((n) => n.type == activeFilter).toList();
  }

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    NotificationCategory? activeFilter,
    bool clearFilter = false,
    bool? isLoading,
    String? statusNotice,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      isLoading: isLoading ?? this.isLoading,
      statusNotice: statusNotice,
    );
  }
}

class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    final now = DateTime.now();

    final fallbackList = [
      NotificationModel(
        id: 'notif-1',
        title: 'Medication Reminder: Amoxicillin 500mg',
        message: 'Time for your scheduled afternoon dose (1 tablet after lunch).',
        type: NotificationCategory.medicine,
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      NotificationModel(
        id: 'notif-2',
        title: 'Teleconsultation Session Confirmed',
        message: 'Dr. Sarah Jenkins has confirmed your appointment for today at 10:30 AM.',
        type: NotificationCategory.appointment,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif-3',
        title: 'Digital Prescription Issued',
        message: 'Dr. Marcus Vance issued prescription #RX-88402 with 2 imported medicines.',
        type: NotificationCategory.system,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 'notif-4',
        title: 'Regimen Refill Alert: Atorvastatin',
        message: 'You have only 4 days of doses remaining in your current regimen.',
        type: NotificationCategory.medicine,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    final unread = fallbackList.where((n) => !n.isRead).length;

    return NotificationState(
      notifications: fallbackList,
      unreadCount: unread,
    );
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final list = await repo.getNotifications();
      if (list.isNotEmpty) {
        final unread = list.where((n) => !n.isRead).length;
        state = state.copyWith(
          isLoading: false,
          notifications: list,
          unreadCount: unread,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> markAsRead(String id) async {
    final updatedList = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final newUnread = updatedList.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updatedList, unreadCount: newUnread);

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsRead(id);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    final updatedList = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: 0,
      statusNotice: 'All notifications marked as read.',
    );

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead();
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    final updatedList = state.notifications.where((n) => n.id != id).toList();
    final newUnread = updatedList.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: newUnread,
      statusNotice: 'Notification removed.',
    );

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.deleteNotification(id);
    } catch (_) {}
  }

  void setFilter(NotificationCategory? category) {
    if (category == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(activeFilter: category);
    }
  }

  void simulateAdherenceAlert({
    required String medicineName,
    required String dosage,
  }) {
    final newAlert = NotificationModel(
      id: 'notif-sim-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Medication Adherence Alert: $medicineName',
      message: 'Time for your scheduled $dosage dose. Please take with water and log adherence.',
      type: NotificationCategory.medicine,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final updated = [newAlert, ...state.notifications];
    final unread = updated.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: updated,
      unreadCount: unread,
      statusNotice: 'Adherence reminder received for $medicineName.',
    );
  }

  void clearNotice() {
    state = state.copyWith(statusNotice: null);
  }
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(() {
  return NotificationController();
});
