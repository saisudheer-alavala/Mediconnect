import { EmergencyContact, PatientProfile } from '@prisma/client';
import { prisma } from '../config/database';
import {
  CreateEmergencyContactInput,
  UpdateEmergencyContactInput,
  UpdateMedicalIdInput,
} from '../validators/emergency.validator';

export class EmergencyRepository {
  async findPatientProfileByUserId(userId: string): Promise<PatientProfile | null> {
    return prisma.patientProfile.findUnique({
      where: { userId },
    });
  }

  async getEmergencyProfile(patientId: string) {
    return prisma.patientProfile.findUnique({
      where: { id: patientId },
      select: {
        id: true,
        fullName: true,
        bloodGroup: true,
        allergies: true,
        chronicDiseases: true,
        emergencyContacts: {
          orderBy: [{ isPrimary: 'desc' }, { createdAt: 'asc' }],
        },
      },
    });
  }

  async getEmergencyContacts(patientId: string): Promise<EmergencyContact[]> {
    return prisma.emergencyContact.findMany({
      where: { patientId },
      orderBy: [{ isPrimary: 'desc' }, { createdAt: 'asc' }],
    });
  }

  async addEmergencyContact(patientId: string, input: CreateEmergencyContactInput): Promise<EmergencyContact> {
    if (input.isPrimary) {
      // Demote existing primary contacts if this one is primary
      await prisma.emergencyContact.updateMany({
        where: { patientId, isPrimary: true },
        data: { isPrimary: false },
      });
    }

    return prisma.emergencyContact.create({
      data: {
        patientId,
        name: input.name,
        relationship: input.relationship,
        phone: input.phone,
        isPrimary: input.isPrimary ?? false,
      },
    });
  }

  async updateEmergencyContact(
    patientId: string,
    contactId: string,
    input: UpdateEmergencyContactInput
  ): Promise<EmergencyContact> {
    if (input.isPrimary) {
      await prisma.emergencyContact.updateMany({
        where: { patientId, isPrimary: true },
        data: { isPrimary: false },
      });
    }

    return prisma.emergencyContact.update({
      where: { id: contactId },
      data: input,
    });
  }

  async deleteEmergencyContact(patientId: string, contactId: string): Promise<void> {
    await prisma.emergencyContact.deleteMany({
      where: { id: contactId, patientId },
    });
  }

  async updateMedicalProfile(patientId: string, input: UpdateMedicalIdInput): Promise<PatientProfile> {
    return prisma.patientProfile.update({
      where: { id: patientId },
      data: input,
    });
  }
}

export const emergencyRepository = new EmergencyRepository();
