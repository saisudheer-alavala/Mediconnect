import { z } from 'zod';

const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;

function timeToMinutes(timeStr: string): number {
  const [h, m] = timeStr.split(':').map(Number);
  return h * 60 + m;
}

export const dayScheduleItemSchema = z
  .object({
    dayOfWeek: z
      .number()
      .int()
      .min(0, 'Day of week must be between 0 (Sunday) and 6 (Saturday)')
      .max(6, 'Day of week must be between 0 (Sunday) and 6 (Saturday)'),
    startTime: z.string().regex(timeRegex, 'Start time must be in HH:mm format (e.g. 09:00)'),
    endTime: z.string().regex(timeRegex, 'End time must be in HH:mm format (e.g. 17:00)'),
    slotDurationMinutes: z
      .number()
      .int()
      .min(10, 'Slot duration must be at least 10 minutes')
      .max(120, 'Slot duration cannot exceed 120 minutes')
      .default(30),
    breakStartTime: z.string().regex(timeRegex, 'Break start must be in HH:mm format').optional().nullable(),
    breakEndTime: z.string().regex(timeRegex, 'Break end must be in HH:mm format').optional().nullable(),
    isActive: z.boolean().default(true),
  })
  .refine(
    (item) => {
      if (!item.isActive) return true;
      return timeToMinutes(item.startTime) < timeToMinutes(item.endTime);
    },
    {
      message: 'Start time must be strictly earlier than end time',
      path: ['endTime'],
    }
  )
  .refine(
    (item) => {
      if (!item.isActive) return true;
      if (!item.breakStartTime && !item.breakEndTime) return true;
      if (item.breakStartTime && !item.breakEndTime) return false;
      if (!item.breakStartTime && item.breakEndTime) return false;

      const bStart = timeToMinutes(item.breakStartTime!);
      const bEnd = timeToMinutes(item.breakEndTime!);
      const wStart = timeToMinutes(item.startTime);
      const wEnd = timeToMinutes(item.endTime);

      return bStart < bEnd && bStart >= wStart && bEnd <= wEnd;
    },
    {
      message: 'Break interval must be within working hours with breakStartTime < breakEndTime',
      path: ['breakEndTime'],
    }
  );

export const updateScheduleSchema = z.union([
  z.object({
    schedule: z.array(dayScheduleItemSchema).min(1, 'At least 1 day configuration required').max(7),
  }),
  z.array(dayScheduleItemSchema).min(1, 'At least 1 day configuration required').max(7),
]);

export type DayScheduleItemInput = z.infer<typeof dayScheduleItemSchema>;
export type UpdateScheduleInput = z.infer<typeof updateScheduleSchema>;
