import { NotificationType } from '@prisma/client';
import { notificationRepository } from '../repositories/notification.repository';
import { CreateNotificationInput } from '../validators/notification.validator';

export class NotificationService {
  async getMyNotifications(
    userId: string,
    unreadOnly?: boolean,
    type?: NotificationType
  ) {
    return notificationRepository.getUserNotifications(userId, unreadOnly, type);
  }

  async getUnreadCount(userId: string) {
    const count = await notificationRepository.getUnreadCount(userId);
    return { unreadCount: count };
  }

  async markAsRead(userId: string, notificationId: string) {
    return notificationRepository.markAsRead(notificationId, userId);
  }

  async markAllAsRead(userId: string) {
    const updatedCount = await notificationRepository.markAllAsRead(userId);
    return { updatedCount };
  }

  async createNotification(userId: string, input: CreateNotificationInput) {
    const targetId = input.targetUserId ?? userId;
    return notificationRepository.createNotification(targetId, input);
  }

  async deleteNotification(userId: string, notificationId: string) {
    await notificationRepository.deleteNotification(notificationId, userId);
  }
}

export const notificationService = new NotificationService();
