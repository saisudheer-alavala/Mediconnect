import { z } from 'zod';
import { Gender } from '@prisma/client';

export const updatePatientProfileSchema = z.object({
  fullName: z.string().min(2, 'Full name must be at least 2 characters').optional(),
  phone: z.string().optional(),
  dateOfBirth: z.string().optional(),
  gender: z.nativeEnum(Gender).optional(),
  bloodGroup: z.string().optional(),
  allergies: z.string().optional(),
  chronicDiseases: z.string().optional(),
});

export const updateDoctorProfileSchema = z.object({
  fullName: z.string().min(2, 'Full name must be at least 2 characters').optional(),
  phone: z.string().optional(),
  qualification: z.string().min(2, 'Qualification is required').optional(),
  experienceYears: z.coerce.number().int().min(0, 'Experience must be 0 or greater').optional(),
  clinicName: z.string().min(2, 'Clinic name is required').optional(),
  clinicAddress: z.string().optional(),
  consultationFee: z.coerce.number().min(0, 'Fee must be non-negative').optional(),
  bio: z.string().optional(),
  avatarUrl: z.string().url('Must be a valid URL').optional().or(z.literal('')),
});

export const changePasswordSchema = z.object({
  currentPassword: z.string().min(1, 'Current password is required'),
  newPassword: z
    .string()
    .min(8, 'New password must be at least 8 characters')
    .regex(/[A-Za-z]/, 'New password must contain at least one letter')
    .regex(/[0-9]/, 'New password must contain at least one number'),
});

export const deactivateAccountSchema = z.object({
  password: z.string().min(1, 'Password is required to deactivate account'),
  confirm: z.boolean().refine((val) => val === true, {
    message: 'You must confirm account deactivation',
  }),
});

export type UpdatePatientProfileInput = z.infer<typeof updatePatientProfileSchema>;
export type UpdateDoctorProfileInput = z.infer<typeof updateDoctorProfileSchema>;
export type ChangePasswordInput = z.infer<typeof changePasswordSchema>;
export type DeactivateAccountInput = z.infer<typeof deactivateAccountSchema>;
