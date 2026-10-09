import { z } from 'zod';
import { AppointmentStatus } from '@prisma/client';

export const createAppointmentSchema = z.object({
  doctorId: z.string().uuid('Invalid Doctor ID'),
  appointmentDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, {
    message: 'Appointment date must be formatted as YYYY-MM-DD',
  }),
  startTime: z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, {
    message: 'Start time must be formatted as HH:mm (24-hour format)',
  }),
  patientNotes: z.string().trim().max(500, 'Notes cannot exceed 500 characters').optional().nullable(),
});

export const updateAppointmentStatusSchema = z.object({
  status: z.nativeEnum(AppointmentStatus, {
    errorMap: () => ({ message: 'Status must be CONFIRMED, COMPLETED, CANCELLED, or NO_SHOW' }),
  }),
  cancellationReason: z.string().trim().max(250).optional().nullable(),
});

export const queryAppointmentsSchema = z.object({
  status: z.nativeEnum(AppointmentStatus).optional(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  upcomingOnly: z
    .enum(['true', 'false'])
    .optional()
    .transform((val) => val === 'true'),
});

export type CreateAppointmentInput = z.infer<typeof createAppointmentSchema>;
export type UpdateAppointmentStatusInput = z.infer<typeof updateAppointmentStatusSchema>;
export type QueryAppointmentsInput = z.infer<typeof queryAppointmentsSchema>;
