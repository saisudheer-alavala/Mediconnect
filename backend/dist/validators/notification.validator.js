"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notificationQuerySchema = exports.createNotificationSchema = void 0;
const zod_1 = require("zod");
const client_1 = require("@prisma/client");
exports.createNotificationSchema = zod_1.z.object({
    title: zod_1.z.string().trim().min(2, 'Title must be at least 2 characters').max(150),
    message: zod_1.z.string().trim().min(2, 'Message must be at least 2 characters').max(500),
    type: zod_1.z.nativeEnum(client_1.NotificationType, {
        errorMap: () => ({ message: 'Invalid notification type' }),
    }).default(client_1.NotificationType.SYSTEM),
    targetUserId: zod_1.z.string().uuid().optional(),
});
exports.notificationQuerySchema = zod_1.z.object({
    unreadOnly: zod_1.z.enum(['true', 'false']).optional(),
    type: zod_1.z.nativeEnum(client_1.NotificationType).optional(),
});
