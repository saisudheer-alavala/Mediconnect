import { z } from 'zod';

export const prescriptionMedicineSchema = z.object({
  medicineName: z.string().trim().min(1, 'Medicine name is required').max(100),
  dosage: z.string().trim().min(1, 'Dosage is required').max(50),
  frequency: z.string().trim().min(1, 'Frequency is required').max(50),
  durationDays: z.number().int().min(1, 'Duration must be at least 1 day').max(365, 'Duration cannot exceed 365 days'),
  instructions: z.string().trim().max(255).optional(),
});

export const createPrescriptionSchema = z.object({
  appointmentId: z.string().uuid('Invalid appointment ID format').optional(),
  patientId: z.string().uuid('Invalid patient ID format'),
  diagnosis: z.string().trim().min(2, 'Diagnosis must be at least 2 characters').max(255),
  generalInstructions: z.string().trim().max(1000).optional(),
  medicines: z.array(prescriptionMedicineSchema).min(1, 'Prescription must contain at least one medicine'),
});

export type CreatePrescriptionInput = z.infer<typeof createPrescriptionSchema>;
export type PrescriptionMedicineInput = z.infer<typeof prescriptionMedicineSchema>;
