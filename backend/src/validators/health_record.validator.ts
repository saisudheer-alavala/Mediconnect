import { z } from 'zod';
import { HealthRecordCategory } from '@prisma/client';

export const createHealthRecordSchema = z.object({
  title: z.string().trim().min(2, 'Title must be at least 2 characters').max(150),
  category: z.nativeEnum(HealthRecordCategory, {
    errorMap: () => ({ message: 'Invalid health record category' }),
  }).default(HealthRecordCategory.OTHER),
  description: z.string().trim().max(1000).optional(),
  fileUrl: z.string().trim().min(1, 'File URL or attachment path is required'),
  fileSize: z.number().int().positive().optional(),
  mimeType: z.string().trim().max(100).optional(),
  uploadedAt: z.string().datetime().optional(),
});

export const updateHealthRecordSchema = createHealthRecordSchema.partial();

export const healthRecordQuerySchema = z.object({
  category: z.nativeEnum(HealthRecordCategory).optional(),
  patientId: z.string().uuid().optional(),
  search: z.string().trim().optional(),
});

export type CreateHealthRecordInput = z.infer<typeof createHealthRecordSchema>;
export type UpdateHealthRecordInput = z.infer<typeof updateHealthRecordSchema>;
export type HealthRecordQueryInput = z.infer<typeof healthRecordQuerySchema>;
