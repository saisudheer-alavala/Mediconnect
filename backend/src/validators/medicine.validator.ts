import { z } from 'zod';
import { DoseStatus } from '@prisma/client';

export const createMedicineSchema = z.object({
  name: z.string().trim().min(1, 'Medicine name is required').max(100, 'Name too long'),
  dosage: z.string().trim().min(1, 'Dosage is required (e.g., 500mg, 1 tablet)').max(50),
  frequency: z.string().trim().min(1, 'Frequency is required (e.g., Twice daily)').max(50),
  instructions: z.string().trim().max(250).optional(),
  startDate: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: 'Start date must be a valid ISO date',
  }),
  endDate: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), {
      message: 'End date must be a valid ISO date',
    })
    .optional()
    .nullable(),
  reminders: z
    .array(
      z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, {
        message: 'Reminder time must be in HH:mm 24-hour format (e.g., "08:00", "20:00")',
      })
    )
    .min(1, 'At least one reminder time is required'),
});

export const updateMedicineSchema = z.object({
  name: z.string().trim().min(1).max(100).optional(),
  dosage: z.string().trim().min(1).max(50).optional(),
  frequency: z.string().trim().min(1).max(50).optional(),
  instructions: z.string().trim().max(250).optional().nullable(),
  startDate: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), {
      message: 'Start date must be a valid ISO date',
    })
    .optional(),
  endDate: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), {
      message: 'End date must be a valid ISO date',
    })
    .optional()
    .nullable(),
  isActive: z.boolean().optional(),
  reminders: z
    .array(
      z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, {
        message: 'Reminder time must be in HH:mm 24-hour format',
      })
    )
    .min(1)
    .optional(),
});

export const logDoseSchema = z.object({
  scheduledTime: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: 'Scheduled time must be a valid ISO date string',
  }),
  status: z.nativeEnum(DoseStatus, {
    errorMap: () => ({ message: 'Status must be TAKEN, SKIPPED, or MISSED' }),
  }),
  takenTime: z
    .string()
    .refine((val) => !isNaN(Date.parse(val)), {
      message: 'Taken time must be a valid ISO date string',
    })
    .optional()
    .nullable(),
  notes: z.string().max(250).optional().nullable(),
});

export type CreateMedicineInput = z.infer<typeof createMedicineSchema>;
export type UpdateMedicineInput = z.infer<typeof updateMedicineSchema>;
export type LogDoseInput = z.infer<typeof logDoseSchema>;
