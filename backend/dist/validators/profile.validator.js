"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivateAccountSchema = exports.changePasswordSchema = exports.updateDoctorProfileSchema = exports.updatePatientProfileSchema = void 0;
const zod_1 = require("zod");
const client_1 = require("@prisma/client");
exports.updatePatientProfileSchema = zod_1.z.object({
    fullName: zod_1.z.string().min(2, 'Full name must be at least 2 characters').optional(),
    phone: zod_1.z.string().optional(),
    dateOfBirth: zod_1.z.string().optional(),
    gender: zod_1.z.nativeEnum(client_1.Gender).optional(),
    bloodGroup: zod_1.z.string().optional(),
    allergies: zod_1.z.string().optional(),
    chronicDiseases: zod_1.z.string().optional(),
});
exports.updateDoctorProfileSchema = zod_1.z.object({
    fullName: zod_1.z.string().min(2, 'Full name must be at least 2 characters').optional(),
    phone: zod_1.z.string().optional(),
    qualification: zod_1.z.string().min(2, 'Qualification is required').optional(),
    experienceYears: zod_1.z.coerce.number().int().min(0, 'Experience must be 0 or greater').optional(),
    clinicName: zod_1.z.string().min(2, 'Clinic name is required').optional(),
    clinicAddress: zod_1.z.string().optional(),
    consultationFee: zod_1.z.coerce.number().min(0, 'Fee must be non-negative').optional(),
    bio: zod_1.z.string().optional(),
    avatarUrl: zod_1.z.string().url('Must be a valid URL').optional().or(zod_1.z.literal('')),
});
exports.changePasswordSchema = zod_1.z.object({
    currentPassword: zod_1.z.string().min(1, 'Current password is required'),
    newPassword: zod_1.z
        .string()
        .min(8, 'New password must be at least 8 characters')
        .regex(/[A-Za-z]/, 'New password must contain at least one letter')
        .regex(/[0-9]/, 'New password must contain at least one number'),
});
exports.deactivateAccountSchema = zod_1.z.object({
    password: zod_1.z.string().min(1, 'Password is required to deactivate account'),
    confirm: zod_1.z.boolean().refine((val) => val === true, {
        message: 'You must confirm account deactivation',
    }),
});
