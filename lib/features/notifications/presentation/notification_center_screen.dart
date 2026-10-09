import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../domain/notification_model.dart';
import 'notification_controller.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationControllerProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationControllerProvider);
    final notifications = state.filteredNotifications;
    final unreadCount = state.unreadCount;
    final activeFilter = state.activeFilter;

    ref.listen<NotificationState>(notificationControllerProvider, (previous, next) {
      if (next.statusNotice != null && next.statusNotice != previous?.statusNotice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.statusNotice!),
            backgroundColor: AppColors.primaryDark,
            duration: const Duration(seconds: 2),
          ),
        );
        ref.read(notificationControllerProvider.notifier).clearNotice();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Notifications',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.emergency,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount NEW',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              try {
                context.go('/patient/home');
              } catch (_) {}
            }
          },
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                ref.read(notificationControllerProvider.notifier).markAllAsRead();
              },
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Read All'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(notificationControllerProvider.notifier).loadNotifications();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Adherence Alert Simulator Banner
                _buildSimulatorCard(ref),
                const SizedBox(height: 16),

                // Category Filter Tabs
                _buildFilterChips(ref, activeFilter),
                const SizedBox(height: 16),

                // Notifications List
                if (notifications.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'All Caught Up!',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No notifications found in this category.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...notifications.map((item) => _buildNotificationCard(context, ref, item)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatorCard(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.alarm_on_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adherence Reminders Engine',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryDark,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Simulate incoming scheduled dose push alert',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(notificationControllerProvider.notifier)
                  .simulateAdherenceAlert(
                    medicineName: 'Metoprolol Tartrate',
                    dosage: '25mg',
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Test Alert',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, NotificationCategory? activeFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: activeFilter == null,
            onSelected: (_) {
              ref.read(notificationControllerProvider.notifier).setFilter(null);
            },
            selectedColor: AppColors.primaryLight,
            labelStyle: AppTextStyles.labelMedium.copyWith(
              color: activeFilter == null ? AppColors.primaryDark : AppColors.textSecondaryLight,
              fontWeight: activeFilter == null ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          ...NotificationCategory.values.map((cat) {
            final isSelected = activeFilter == cat;
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ChoiceChip(
                avatar: Icon(cat.icon, size: 16, color: isSelected ? cat.color : AppColors.textSecondaryLight),
                label: Text(cat.label),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(notificationControllerProvider.notifier).setFilter(cat);
                },
                selectedColor: cat.color.withValues(alpha: 0.15),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? cat.color : AppColors.textSecondaryLight,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationModel item,
  ) {
    final cat = item.type;
    final isUnread = !item.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? cat.color.withValues(alpha: 0.4) : AppColors.borderLight,
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: cat.color.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: () {
          if (isUnread) {
            ref.read(notificationControllerProvider.notifier).markAsRead(item.id);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat.icon, color: cat.color, size: 20),
              ),
              const SizedBox(width: 12),

              // Title & Message Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: cat.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isUnread ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.formattedTimeAgo,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textMutedLight,
                            fontSize: 11,
                          ),
                        ),
                        Row(
                          children: [
                            if (isUnread)
                              TextButton(
                                onPressed: () {
                                  ref.read(notificationControllerProvider.notifier).markAsRead(item.id);
                                },
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Mark read',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            IconButton(
                              onPressed: () {
                                ref.read(notificationControllerProvider.notifier).deleteNotification(item.id);
                              },
                              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMutedLight),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Dismiss',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
