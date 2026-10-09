import { Router } from 'express';
import { notificationController } from '../controllers/notification.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validate.middleware';
import { createNotificationSchema } from '../validators/notification.validator';

const router = Router();

// Protect all notification routes
router.use(authenticateJwt);

// Notification endpoints
router.get('/', notificationController.getMyNotifications);
router.get('/unread-count', notificationController.getUnreadCount);
router.patch('/read-all', notificationController.markAllAsRead);
router.patch('/:id/read', notificationController.markAsRead);
router.post(
  '/',
  validateRequest(createNotificationSchema),
  notificationController.createNotification
);
router.delete('/:id', notificationController.deleteNotification);

export const notificationRoutes = router;
