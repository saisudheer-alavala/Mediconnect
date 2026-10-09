import { prisma } from '../config/database';
import {
  UpdatePatientProfileInput,
  UpdateDoctorProfileInput,
} from '../validators/profile.validator';

export class ProfileRepository {
  /**
   * Fetch full user profile with linked patient or doctor domain model
   */
  async getProfile(userId: string) {
    return prisma.user.findUnique({
      where: { id: userId },
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
   * Update patient profile and associated phone number on user model
   */
  async updatePatient(userId: string, data: UpdatePatientProfileInput) {
    return prisma.$transaction(async (tx) => {
      if (data.phone !== undefined) {
        await tx.user.update({
          where: { id: userId },
          data: { phone: data.phone },
        });
      }

      const dateOfBirth = data.dateOfBirth ? new Date(data.dateOfBirth) : undefined;

      await tx.patientProfile.update({
        where: { userId },
        data: {
          fullName: data.fullName,
          dateOfBirth,
          gender: data.gender,
          bloodGroup: data.bloodGroup,
          allergies: data.allergies,
          chronicDiseases: data.chronicDiseases,
        },
      });

      return tx.user.findUnique({
        where: { id: userId },
        include: {
          patientProfile: true,
          doctorProfile: {
            include: {
              specialization: true,
            },
          },
        },
      });
    });
  }

  /**
   * Update doctor profile and associated phone number on user model
   */
  async updateDoctor(userId: string, data: UpdateDoctorProfileInput) {
    return prisma.$transaction(async (tx) => {
      if (data.phone !== undefined) {
        await tx.user.update({
          where: { id: userId },
          data: { phone: data.phone },
        });
      }

      await tx.doctorProfile.update({
        where: { userId },
        data: {
          fullName: data.fullName,
          qualification: data.qualification,
          experienceYears: data.experienceYears,
          clinicName: data.clinicName,
          clinicAddress: data.clinicAddress,
          consultationFee: data.consultationFee,
          bio: data.bio,
          avatarUrl: data.avatarUrl,
        },
      });

      return tx.user.findUnique({
        where: { id: userId },
        include: {
          patientProfile: true,
          doctorProfile: {
            include: {
              specialization: true,
            },
          },
        },
      });
    });
  }

  /**
   * Update password hash for user
   */
  async updatePassword(userId: string, passwordHash: string) {
    return prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });
  }

  /**
   * Deactivate user account (soft delete for safety)
   */
  async deactivateUser(userId: string) {
    return prisma.user.update({
      where: { id: userId },
      data: { isActive: false },
    });
  }
}

export const profileRepository = new ProfileRepository();
