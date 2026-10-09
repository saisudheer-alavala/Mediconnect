"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notificationRepository = exports.NotificationRepository = void 0;
const database_1 = require("../config/database");
class NotificationRepository {
    async getUserNotifications(userId, unreadOnly, type) {
        const where = { userId };
        if (unreadOnly) {
            where.isRead = false;
        }
        if (type) {
            where.type = type;
        }
        return database_1.prisma.notification.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            take: 50,
        });
    }
    async getUnreadCount(userId) {
        return database_1.prisma.notification.count({
            where: { userId, isRead: false },
        });
    }
    async markAsRead(notificationId, userId) {
        return database_1.prisma.notification.update({
            where: { id: notificationId },
            data: { isRead: true },
        });
    }
    async markAllAsRead(userId) {
        const result = await database_1.prisma.notification.updateMany({
            where: { userId, isRead: false },
            data: { isRead: true },
        });
        return result.count;
    }
    async createNotification(userId, input) {
        return database_1.prisma.notification.create({
            data: {
                userId,
                title: input.title,
                message: input.message,
                type: input.type,
            },
        });
    }
    async deleteNotification(notificationId, userId) {
        await database_1.prisma.notification.deleteMany({
            where: { id: notificationId, userId },
        });
    }
}
exports.NotificationRepository = NotificationRepository;
exports.notificationRepository = new NotificationRepository();
