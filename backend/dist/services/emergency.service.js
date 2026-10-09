"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.emergencyService = exports.EmergencyService = void 0;
const emergency_repository_1 = require("../repositories/emergency.repository");
class EmergencyService {
    async getEmergencyProfile(userId) {
        const patient = await emergency_repository_1.emergencyRepository.findPatientProfileByUserId(userId);
        if (!patient) {
            throw new Error('Patient medical profile not found.');
        }
        return emergency_repository_1.emergencyRepository.getEmergencyProfile(patient.id);
    }
    async getEmergencyContacts(userId) {
        const patient = await emergency_repository_1.emergencyRepository.findPatientProfileByUserId(userId);
        if (!patient) {
            throw new Error('Patient profile not found.');
        }
        return emergency_repository_1.emergencyRepository.getEmergencyContacts(patient.id);
    }
    async addEmergencyContact(userId, input) {
        const patient = await emergency_repository_1.emergencyRepository.findPatientProfileByUserId(userId);
        if (!patient) {
            throw new Error('Patient profile not found.');
        }
        return emergency_repository_1.emergencyRepository.addEmergencyContact(patient.id, input);
    }
    async updateEmergencyContact(userId, contactId, input) {
        const patient = await emergency_repository_1.emergencyRepository.findPatientProfileByUserId(userId);
        if (!patient) {
            throw new Error('Patient profile not found.');
        }
        return emergency_repository_1.emergencyRepository.updateEmergencyContact(patient.id, contactId, input);
    }
    async deleteEmergencyContact(userId, contactId) {
        const patient = await emergency_repository_1.emergencyRepository.findPatientProfileByUserId(userId);
        if (!patient) {
            throw new Error('Patient profile not found.');
        }
        return emergency_repository_1.emergencyRepository.deleteEmergencyContact(patient.id, contactId);
    }
    async updateMedicalProfile(userId, input) {
        const patient = await emergency_repository_1.emergencyRepository.findPatientProfileByUserId(userId);
        if (!patient) {
            throw new Error('Patient profile not found.');
        }
        return emergency_repository_1.emergencyRepository.updateMedicalProfile(patient.id, input);
    }
}
exports.EmergencyService = EmergencyService;
exports.emergencyService = new EmergencyService();
