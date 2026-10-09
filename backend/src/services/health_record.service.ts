import { UserRole } from '@prisma/client';
import { healthRecordRepository } from '../repositories/health_record.repository';
import {
  CreateHealthRecordInput,
  UpdateHealthRecordInput,
  HealthRecordQueryInput,
} from '../validators/health_record.validator';

interface AuthUser {
  userId: string;
  role: UserRole;
  email: string;
}

export class HealthRecordService {
  async getMyRecords(user: AuthUser, query: HealthRecordQueryInput) {
    if (user.role === UserRole.PATIENT) {
      const patient = await healthRecordRepository.findPatientProfileByUserId(user.userId);
      if (!patient) {
        throw new Error('Patient profile not found.');
      }
      return healthRecordRepository.getRecordsByPatient(
        patient.id,
        query.category,
        query.search
      );
    }

    if (user.role === UserRole.DOCTOR || user.role === UserRole.ADMIN) {
      if (!query.patientId) {
        throw new Error('Doctor or Admin query must specify patientId parameter.');
      }
      return healthRecordRepository.getRecordsByPatient(
        query.patientId,
        query.category,
        query.search
      );
    }

    throw new Error('Unauthorized role for accessing health records.');
  }

  async getRecordById(user: AuthUser, recordId: string) {
    const record = await healthRecordRepository.getRecordById(recordId);
    if (!record) {
      throw new Error('Health record not found.');
    }

    if (user.role === UserRole.PATIENT) {
      const patient = await healthRecordRepository.findPatientProfileByUserId(user.userId);
      if (!patient || record.patientId !== patient.id) {
        throw new Error('Unauthorized access to this health record.');
      }
    }

    return record;
  }

  async createRecord(user: AuthUser, input: CreateHealthRecordInput, targetPatientId?: string) {
    let patientId = targetPatientId;

    if (user.role === UserRole.PATIENT) {
      const patient = await healthRecordRepository.findPatientProfileByUserId(user.userId);
      if (!patient) {
        throw new Error('Patient profile not found.');
      }
      patientId = patient.id;
    } else if (!patientId) {
      throw new Error('Target patientId must be provided by clinician.');
    }

    return healthRecordRepository.createRecord(patientId, input);
  }

  async updateRecord(user: AuthUser, recordId: string, input: UpdateHealthRecordInput) {
    const record = await healthRecordRepository.getRecordById(recordId);
    if (!record) {
      throw new Error('Health record not found.');
    }

    if (user.role === UserRole.PATIENT) {
      const patient = await healthRecordRepository.findPatientProfileByUserId(user.userId);
      if (!patient || record.patientId !== patient.id) {
        throw new Error('Unauthorized to modify this health record.');
      }
    }

    return healthRecordRepository.updateRecord(recordId, input);
  }

  async deleteRecord(user: AuthUser, recordId: string) {
    const record = await healthRecordRepository.getRecordById(recordId);
    if (!record) {
      throw new Error('Health record not found.');
    }

    if (user.role === UserRole.PATIENT) {
      const patient = await healthRecordRepository.findPatientProfileByUserId(user.userId);
      if (!patient || record.patientId !== patient.id) {
        throw new Error('Unauthorized to delete this health record.');
      }
    }

    await healthRecordRepository.deleteRecord(recordId);
  }
}

export const healthRecordService = new HealthRecordService();
