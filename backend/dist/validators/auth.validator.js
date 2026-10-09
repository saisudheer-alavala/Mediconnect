"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.refreshTokenSchema = exports.loginSchema = exports.doctorRegisterSchema = exports.patientRegisterSchema = void 0;
const zod_1 = require("zod");
const client_1 = require("@prisma/client");
exports.patientRegisterSchema = zod_1.z.object({
    email: zod_1.z.string().email('Valid email address is required'),
    password: zod_1.z
        .string()
        .min(8, 'Password must be at least 8 characters')
        .regex(/[A-Za-z]/, 'Password must contain at least one letter')
        .regex(/[0-9]/, 'Password must contain at least one number'),
    fullName: zod_1.z.string().min(2, 'Full name must be at least 2 characters'),
    phone: zod_1.z.string().optional(),
    dateOfBirth: zod_1.z.string().optional(),
    gender: zod_1.z.nativeEnum(client_1.Gender).optional(),
});
exports.doctorRegisterSchema = zod_1.z.object({
    email: zod_1.z.string().email('Valid email address is required'),
    password: zod_1.z
        .string()
        .min(8, 'Password must be at least 8 characters')
        .regex(/[A-Za-z]/, 'Password must contain at least one letter')
        .regex(/[0-9]/, 'Password must contain at least one number'),
    fullName: zod_1.z.string().min(2, 'Full name must be at least 2 characters'),
    phone: zod_1.z.string().optional(),
    specializationName: zod_1.z.string().min(2, 'Medical specialization is required'),
    qualification: zod_1.z.string().min(2, 'Medical qualification is required (e.g. MBBS, MD)'),
    licenseNumber: zod_1.z.string().min(3, 'Medical license / registration number is required'),
    experienceYears: zod_1.z.coerce.number().int().min(0, 'Experience must be 0 or more years'),
    clinicName: zod_1.z.string().min(2, 'Clinic or hospital name is required'),
    clinicAddress: zod_1.z.string().optional(),
});
exports.loginSchema = zod_1.z.object({
    email: zod_1.z.string().email('Valid email address is required'),
    password: zod_1.z.string().min(1, 'Password is required'),
});
exports.refreshTokenSchema = zod_1.z.object({
    refreshToken: zod_1.z.string().min(1, 'Refresh token is required'),
});
