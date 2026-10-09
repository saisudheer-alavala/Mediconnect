import { User, UserRole, Gender } from '@prisma/client';
import { prisma } from '../config/database';

export class UserRepository {
  /**
   * Find a user by unique email with profiles included
   */
  async findByEmail(email: string): Promise<(User & { patientProfile: unknown; doctorProfile: unknown }) | null> {
    return prisma.user.findUnique({
      where: { email: email.toLowerCase() },
      include: {
        patientProfile: true,
        doctorProfile: {
          include: {
            specialization: true,
          },
        },
      },
    }) as Promise<(User & { patientProfile: unknown; doctorProfile: unknown }) | null>;
  }

  /**
   * Find a user by primary ID with profile included
   */
  async findById(id: string): Promise<(User & { patientProfile: unknown; doctorProfile: unknown }) | null> {
    return prisma.user.findUnique({
      where: { id },
      include: {
        patientProfile: true,
        doctorProfile: {
          include: {
            specialization: true,
          },
        },
      },
    }) as Promise<(User & { patientProfile: unknown; doctorProfile: unknown }) | null>;
  }

  /**
   * Create a new patient user in a transaction
   */
  async createPatient(params: {
    email: string;
    passwordHash: string;
    phone?: string;
    fullName: string;
    dateOfBirth?: Date;
    gender?: Gender;
  }): Promise<User> {
    return prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          email: params.email.toLowerCase(),
          passwordHash: params.passwordHash,
          phone: params.phone,
          role: UserRole.PATIENT,
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
  async createDoctor(params: {
    email: string;
    passwordHash: string;
    phone?: string;
    fullName: string;
    specializationName: string;
    qualification: string;
    licenseNumber: string;
    experienceYears: number;
    clinicName: string;
    clinicAddress?: string;
  }): Promise<User> {
    return prisma.$transaction(async (tx: any) => {
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
          role: UserRole.DOCTOR,
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

export const userRepository = new UserRepository();
