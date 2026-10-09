import { z } from 'zod';

export const searchDoctorSchema = z.object({
  search: z.string().trim().optional(),
  specializationId: z.string().uuid().optional(),
  minFee: z.coerce.number().min(0).optional(),
  maxFee: z.coerce.number().min(0).optional(),
  minExperience: z.coerce.number().min(0).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export const slotsQuerySchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, {
    message: 'Date must be formatted as YYYY-MM-DD',
  }),
});

export type SearchDoctorInput = z.infer<typeof searchDoctorSchema>;
export type SlotsQueryInput = z.infer<typeof slotsQuerySchema>;
