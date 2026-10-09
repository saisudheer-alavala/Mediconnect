import { z } from 'zod';
import { NotificationType } from '@prisma/client';

export const createNotificationSchema = z.object({
  title: z.string().trim().min(2, 'Title must be at least 2 characters').max(150),
  message: z.string().trim().min(2, 'Message must be at least 2 characters').max(500),
  type: z.nativeEnum(NotificationType, {
    errorMap: () => ({ message: 'Invalid notification type' }),
  }).default(NotificationType.SYSTEM),
  targetUserId: z.string().uuid().optional(),
});

export const notificationQuerySchema = z.object({
  unreadOnly: z.enum(['true', 'false']).optional(),
  type: z.nativeEnum(NotificationType).optional(),
});

export type CreateNotificationInput = z.infer<typeof createNotificationSchema>;
export type NotificationQueryInput = z.infer<typeof notificationQuerySchema>;
