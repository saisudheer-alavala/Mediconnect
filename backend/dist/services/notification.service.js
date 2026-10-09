"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notificationService = exports.NotificationService = void 0;
const notification_repository_1 = require("../repositories/notification.repository");
class NotificationService {
    async getMyNotifications(userId, unreadOnly, type) {
        return notification_repository_1.notificationRepository.getUserNotifications(userId, unreadOnly, type);
    }
    async getUnreadCount(userId) {
        const count = await notification_repository_1.notificationRepository.getUnreadCount(userId);
        return { unreadCount: count };
    }
    async markAsRead(userId, notificationId) {
        return notification_repository_1.notificationRepository.markAsRead(notificationId, userId);
    }
    async markAllAsRead(userId) {
        const updatedCount = await notification_repository_1.notificationRepository.markAllAsRead(userId);
        return { updatedCount };
    }
    async createNotification(userId, input) {
        const targetId = input.targetUserId ?? userId;
        return notification_repository_1.notificationRepository.createNotification(targetId, input);
    }
    async deleteNotification(userId, notificationId) {
        await notification_repository_1.notificationRepository.deleteNotification(notificationId, userId);
    }
}
exports.NotificationService = NotificationService;
exports.notificationService = new NotificationService();
