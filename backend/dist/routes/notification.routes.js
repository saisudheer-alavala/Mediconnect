"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notificationRoutes = void 0;
const express_1 = require("express");
const notification_controller_1 = require("../controllers/notification.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const notification_validator_1 = require("../validators/notification.validator");
const router = (0, express_1.Router)();
// Protect all notification routes
router.use(auth_middleware_1.authenticateJwt);
// Notification endpoints
router.get('/', notification_controller_1.notificationController.getMyNotifications);
router.get('/unread-count', notification_controller_1.notificationController.getUnreadCount);
router.patch('/read-all', notification_controller_1.notificationController.markAllAsRead);
router.patch('/:id/read', notification_controller_1.notificationController.markAsRead);
router.post('/', (0, validate_middleware_1.validateRequest)(notification_validator_1.createNotificationSchema), notification_controller_1.notificationController.createNotification);
router.delete('/:id', notification_controller_1.notificationController.deleteNotification);
exports.notificationRoutes = router;
