"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.userRepository = exports.UserRepository = void 0;
const client_1 = require("@prisma/client");
const database_1 = require("../config/database");
class UserRepository {
    /**
     * Find a user by unique email with profiles included
     */
    async findByEmail(email) {
        return database_1.prisma.user.findUnique({
            where: { email: email.toLowerCase() },
            include: {
                patientProfile: true,
                doctorProfile: {
                    include: {
                        specialization: true,
                    },
                },
            },
        });
    }
    /**
     * Find a user by primary ID with profile included
     */
    async findById(id) {
        return database_1.prisma.user.findUnique({
            where: { id },
            include: {
                patientProfile: true,
                doctorProfile: {
                    include: {
                        specialization: true,
                    },
                },
            },
        });
    }
    /**
     * Create a new patient user in a transaction
     */
    async createPatient(params) {
        return database_1.prisma.$transaction(async (tx) => {
            const user = await tx.user.create({
                data: {
                    email: params.email.toLowerCase(),
                    passwordHash: params.passwordHash,
                    phone: params.phone,
                    role: client_1.UserRole.PATIENT,
                },
            });
            await tx.patientProfile.create({
                data: {
                    userId: user.id,
                    fullName: params.fullName,
                    dateOfBirth: params.dateOfBirth,
                    gender: params.gender,
                },
            });
            return user;
        });
    }
    /**
     * Create a new doctor user in a transaction
     */
    async createDoctor(params) {
        return database_1.prisma.$transaction(async (tx) => {
            // Find or create specialization
            const specialization = await tx.specialization.upsert({
                where: { name: params.specializationName },
                update: {},
                create: { name: params.specializationName },
            });
            const user = await tx.user.create({
                data: {
                    email: params.email.toLowerCase(),
                    passwordHash: params.passwordHash,
                    phone: params.phone,
                    role: client_1.UserRole.DOCTOR,
                },
            });
            await tx.doctorProfile.create({
                data: {
                    userId: user.id,
                    fullName: params.fullName,
                    specializationId: specialization.id,
                    qualification: params.qualification,
                    licenseNumber: params.licenseNumber,
                    experienceYears: params.experienceYears,
                    clinicName: params.clinicName,
                    clinicAddress: params.clinicAddress,
                    isVerified: false, // Default false until admin approves
                },
            });
            return user;
        });
    }
}
exports.UserRepository = UserRepository;
exports.userRepository = new UserRepository();
