import { emergencyRepository } from '../repositories/emergency.repository';
import {
  CreateEmergencyContactInput,
  UpdateEmergencyContactInput,
  UpdateMedicalIdInput,
} from '../validators/emergency.validator';

export class EmergencyService {
  async getEmergencyProfile(userId: string) {
    const patient = await emergencyRepository.findPatientProfileByUserId(userId);
    if (!patient) {
      throw new Error('Patient medical profile not found.');
    }
    return emergencyRepository.getEmergencyProfile(patient.id);
  }

  async getEmergencyContacts(userId: string) {
    const patient = await emergencyRepository.findPatientProfileByUserId(userId);
    if (!patient) {
      throw new Error('Patient profile not found.');
    }
    return emergencyRepository.getEmergencyContacts(patient.id);
  }

  async addEmergencyContact(userId: string, input: CreateEmergencyContactInput) {
    const patient = await emergencyRepository.findPatientProfileByUserId(userId);
    if (!patient) {
      throw new Error('Patient profile not found.');
    }
    return emergencyRepository.addEmergencyContact(patient.id, input);
  }

  async updateEmergencyContact(userId: string, contactId: string, input: UpdateEmergencyContactInput) {
    const patient = await emergencyRepository.findPatientProfileByUserId(userId);
    if (!patient) {
      throw new Error('Patient profile not found.');
    }
    return emergencyRepository.updateEmergencyContact(patient.id, contactId, input);
  }

  async deleteEmergencyContact(userId: string, contactId: string) {
    const patient = await emergencyRepository.findPatientProfileByUserId(userId);
    if (!patient) {
      throw new Error('Patient profile not found.');
    }
    return emergencyRepository.deleteEmergencyContact(patient.id, contactId);
  }

  async updateMedicalProfile(userId: string, input: UpdateMedicalIdInput) {
    const patient = await emergencyRepository.findPatientProfileByUserId(userId);
    if (!patient) {
      throw new Error('Patient profile not found.');
    }
    return emergencyRepository.updateMedicalProfile(patient.id, input);
  }
}

export const emergencyService = new EmergencyService();
