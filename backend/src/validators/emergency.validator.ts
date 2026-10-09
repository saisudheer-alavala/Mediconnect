import { z } from 'zod';

export const createEmergencyContactSchema = z.object({
  name: z.string().trim().min(2, 'Name must be at least 2 characters').max(100),
  relationship: z.string().trim().min(2, 'Relationship must be at least 2 characters').max(50),
  phone: z.string().trim().min(7, 'Phone number must be at least 7 characters').max(20),
  isPrimary: z.boolean().optional().default(false),
});

export const updateEmergencyContactSchema = createEmergencyContactSchema.partial();

export const updateMedicalIdSchema = z.object({
  bloodGroup: z.string().trim().max(10).optional(),
  allergies: z.string().trim().max(500).optional(),
  chronicDiseases: z.string().trim().max(500).optional(),
});

export type CreateEmergencyContactInput = z.infer<typeof createEmergencyContactSchema>;
export type UpdateEmergencyContactInput = z.infer<typeof updateEmergencyContactSchema>;
export type UpdateMedicalIdInput = z.infer<typeof updateMedicalIdSchema>;
