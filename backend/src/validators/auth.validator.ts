import { z } from 'zod';
import { Gender } from '@prisma/client';

export const patientRegisterSchema = z.object({
  email: z.string().email('Valid email address is required'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Za-z]/, 'Password must contain at least one letter')
    .regex(/[0-9]/, 'Password must contain at least one number'),
  fullName: z.string().min(2, 'Full name must be at least 2 characters'),
  phone: z.string().optional(),
  dateOfBirth: z.string().optional(),
  gender: z.nativeEnum(Gender).optional(),
});

export const doctorRegisterSchema = z.object({
  email: z.string().email('Valid email address is required'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Za-z]/, 'Password must contain at least one letter')
    .regex(/[0-9]/, 'Password must contain at least one number'),
  fullName: z.string().min(2, 'Full name must be at least 2 characters'),
  phone: z.string().optional(),
  specializationName: z.string().min(2, 'Medical specialization is required'),
  qualification: z.string().min(2, 'Medical qualification is required (e.g. MBBS, MD)'),
  licenseNumber: z.string().min(3, 'Medical license / registration number is required'),
  experienceYears: z.coerce.number().int().min(0, 'Experience must be 0 or more years'),
  clinicName: z.string().min(2, 'Clinic or hospital name is required'),
  clinicAddress: z.string().optional(),
});

export const loginSchema = z.object({
  email: z.string().email('Valid email address is required'),
  password: z.string().min(1, 'Password is required'),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

export type PatientRegisterInput = z.infer<typeof patientRegisterSchema>;
export type DoctorRegisterInput = z.infer<typeof doctorRegisterSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshTokenInput = z.infer<typeof refreshTokenSchema>;
