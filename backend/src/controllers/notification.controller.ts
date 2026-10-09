import { Request, Response } from 'express';
import { NotificationType } from '@prisma/client';
import { notificationService } from '../services/notification.service';
import { successResponse, errorResponse } from '../utils/api_response';

export class NotificationController {
  async getMyNotifications(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const unreadOnly = req.query.unreadOnly === 'true';
      const type = req.query.type as NotificationType | undefined;

      const list = await notificationService.getMyNotifications(userId, unreadOnly, type);
      successResponse(res, list, 'Notifications retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve notifications', 'GET_NOTIFICATIONS_ERROR', 400);
    }
  }

  async getUnreadCount(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const result = await notificationService.getUnreadCount(userId);
      successResponse(res, result, 'Unread count retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve unread count', 'GET_UNREAD_COUNT_ERROR', 400);
    }
  }

  async markAsRead(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const updated = await notificationService.markAsRead(userId, id);
      successResponse(res, updated, 'Notification marked as read');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to mark notification as read', 'MARK_READ_ERROR', 400);
    }
  }

  async markAllAsRead(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const result = await notificationService.markAllAsRead(userId);
      successResponse(res, result, 'All notifications marked as read');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to mark all as read', 'MARK_ALL_READ_ERROR', 400);
    }
  }

  async createNotification(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const created = await notificationService.createNotification(userId, req.body);
      successResponse(res, created, 'Notification created successfully', 201);
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to create notification', 'CREATE_NOTIFICATION_ERROR', 400);
    }
  }

  async deleteNotification(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      await notificationService.deleteNotification(userId, id);
      successResponse(res, null, 'Notification removed successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to delete notification', 'DELETE_NOTIFICATION_ERROR', 400);
    }
  }
}

export const notificationController = new NotificationController();
