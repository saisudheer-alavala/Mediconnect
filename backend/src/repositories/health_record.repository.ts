import { HealthRecord, HealthRecordCategory, PatientProfile, DoctorProfile } from '@prisma/client';
import { prisma } from '../config/database';
import {
  CreateHealthRecordInput,
  UpdateHealthRecordInput,
} from '../validators/health_record.validator';

export class HealthRecordRepository {
  async findPatientProfileByUserId(userId: string): Promise<PatientProfile | null> {
    return prisma.patientProfile.findUnique({
      where: { userId },
    });
  }

  async findDoctorProfileByUserId(userId: string): Promise<DoctorProfile | null> {
    return prisma.doctorProfile.findUnique({
      where: { userId },
    });
  }

  async getRecordsByPatient(
    patientId: string,
    category?: HealthRecordCategory,
    search?: string
  ): Promise<HealthRecord[]> {
    const where: any = { patientId };

    if (category) {
      where.category = category;
    }

    if (search && search.trim().length > 0) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    return prisma.healthRecord.findMany({
      where,
      orderBy: { uploadedAt: 'desc' },
      include: {
        patient: {
          select: {
            fullName: true,
            bloodGroup: true,
          },
        },
      },
    });
  }

  async getRecordById(recordId: string): Promise<HealthRecord | null> {
    return prisma.healthRecord.findUnique({
      where: { id: recordId },
      include: {
        patient: {
          select: {
            fullName: true,
            bloodGroup: true,
          },
        },
      },
    });
  }

  async createRecord(
    patientId: string,
    input: CreateHealthRecordInput
  ): Promise<HealthRecord> {
    return prisma.healthRecord.create({
      data: {
        patientId,
        title: input.title,
        category: input.category,
        description: input.description,
        fileUrl: input.fileUrl,
        fileSize: input.fileSize,
        mimeType: input.mimeType,
        uploadedAt: input.uploadedAt ? new Date(input.uploadedAt) : new Date(),
      },
    });
  }

  async updateRecord(
    recordId: string,
    input: UpdateHealthRecordInput
  ): Promise<HealthRecord> {
    const data: any = { ...input };
    if (input.uploadedAt) {
      data.uploadedAt = new Date(input.uploadedAt);
    }

    return prisma.healthRecord.update({
      where: { id: recordId },
      data,
    });
  }

  async deleteRecord(recordId: string): Promise<void> {
    await prisma.healthRecord.delete({
      where: { id: recordId },
    });
  }
}

export const healthRecordRepository = new HealthRecordRepository();
