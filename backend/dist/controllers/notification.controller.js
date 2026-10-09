"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notificationController = exports.NotificationController = void 0;
const notification_service_1 = require("../services/notification.service");
const api_response_1 = require("../utils/api_response");
class NotificationController {
    async getMyNotifications(req, res) {
        try {
            const userId = req.user.userId;
            const unreadOnly = req.query.unreadOnly === 'true';
            const type = req.query.type;
            const list = await notification_service_1.notificationService.getMyNotifications(userId, unreadOnly, type);
            (0, api_response_1.successResponse)(res, list, 'Notifications retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve notifications', 'GET_NOTIFICATIONS_ERROR', 400);
        }
    }
    async getUnreadCount(req, res) {
        try {
            const userId = req.user.userId;
            const result = await notification_service_1.notificationService.getUnreadCount(userId);
            (0, api_response_1.successResponse)(res, result, 'Unread count retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve unread count', 'GET_UNREAD_COUNT_ERROR', 400);
        }
    }
    async markAsRead(req, res) {
        try {
            const userId = req.user.userId;
            const { id } = req.params;
            const updated = await notification_service_1.notificationService.markAsRead(userId, id);
            (0, api_response_1.successResponse)(res, updated, 'Notification marked as read');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to mark notification as read', 'MARK_READ_ERROR', 400);
        }
    }
    async markAllAsRead(req, res) {
        try {
            const userId = req.user.userId;
            const result = await notification_service_1.notificationService.markAllAsRead(userId);
            (0, api_response_1.successResponse)(res, result, 'All notifications marked as read');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to mark all as read', 'MARK_ALL_READ_ERROR', 400);
        }
    }
    async createNotification(req, res) {
        try {
            const userId = req.user.userId;
            const created = await notification_service_1.notificationService.createNotification(userId, req.body);
            (0, api_response_1.successResponse)(res, created, 'Notification created successfully', 201);
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to create notification', 'CREATE_NOTIFICATION_ERROR', 400);
        }
    }
    async deleteNotification(req, res) {
        try {
            const userId = req.user.userId;
            const { id } = req.params;
            await notification_service_1.notificationService.deleteNotification(userId, id);
            (0, api_response_1.successResponse)(res, null, 'Notification removed successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to delete notification', 'DELETE_NOTIFICATION_ERROR', 400);
        }
    }
}
exports.NotificationController = NotificationController;
exports.notificationController = new NotificationController();
