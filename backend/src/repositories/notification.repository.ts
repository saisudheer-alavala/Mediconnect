import { Notification, NotificationType } from '@prisma/client';
import { prisma } from '../config/database';
import { CreateNotificationInput } from '../validators/notification.validator';

export class NotificationRepository {
  async getUserNotifications(
    userId: string,
    unreadOnly?: boolean,
    type?: NotificationType
  ): Promise<Notification[]> {
    const where: any = { userId };

    if (unreadOnly) {
      where.isRead = false;
    }

    if (type) {
      where.type = type;
    }

    return prisma.notification.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async getUnreadCount(userId: string): Promise<number> {
    return prisma.notification.count({
      where: { userId, isRead: false },
    });
  }

  async markAsRead(notificationId: string, userId: string): Promise<Notification> {
    return prisma.notification.update({
      where: { id: notificationId },
      data: { isRead: true },
    });
  }

  async markAllAsRead(userId: string): Promise<number> {
    const result = await prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
    return result.count;
  }

  async createNotification(
    userId: string,
    input: CreateNotificationInput
  ): Promise<Notification> {
    return prisma.notification.create({
      data: {
        userId,
        title: input.title,
        message: input.message,
        type: input.type,
      },
    });
  }

  async deleteNotification(notificationId: string, userId: string): Promise<void> {
    await prisma.notification.deleteMany({
      where: { id: notificationId, userId },
    });
  }
}

export const notificationRepository = new NotificationRepository();
