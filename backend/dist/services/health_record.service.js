"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.healthRecordService = exports.HealthRecordService = void 0;
const client_1 = require("@prisma/client");
const health_record_repository_1 = require("../repositories/health_record.repository");
class HealthRecordService {
    async getMyRecords(user, query) {
        if (user.role === client_1.UserRole.PATIENT) {
            const patient = await health_record_repository_1.healthRecordRepository.findPatientProfileByUserId(user.userId);
            if (!patient) {
                throw new Error('Patient profile not found.');
            }
            return health_record_repository_1.healthRecordRepository.getRecordsByPatient(patient.id, query.category, query.search);
        }
        if (user.role === client_1.UserRole.DOCTOR || user.role === client_1.UserRole.ADMIN) {
            if (!query.patientId) {
                throw new Error('Doctor or Admin query must specify patientId parameter.');
            }
            return health_record_repository_1.healthRecordRepository.getRecordsByPatient(query.patientId, query.category, query.search);
        }
        throw new Error('Unauthorized role for accessing health records.');
    }
    async getRecordById(user, recordId) {
        const record = await health_record_repository_1.healthRecordRepository.getRecordById(recordId);
        if (!record) {
            throw new Error('Health record not found.');
        }
        if (user.role === client_1.UserRole.PATIENT) {
            const patient = await health_record_repository_1.healthRecordRepository.findPatientProfileByUserId(user.userId);
            if (!patient || record.patientId !== patient.id) {
                throw new Error('Unauthorized access to this health record.');
            }
        }
        return record;
    }
    async createRecord(user, input, targetPatientId) {
        let patientId = targetPatientId;
        if (user.role === client_1.UserRole.PATIENT) {
            const patient = await health_record_repository_1.healthRecordRepository.findPatientProfileByUserId(user.userId);
            if (!patient) {
                throw new Error('Patient profile not found.');
            }
            patientId = patient.id;
        }
        else if (!patientId) {
            throw new Error('Target patientId must be provided by clinician.');
        }
        return health_record_repository_1.healthRecordRepository.createRecord(patientId, input);
    }
    async updateRecord(user, recordId, input) {
        const record = await health_record_repository_1.healthRecordRepository.getRecordById(recordId);
        if (!record) {
            throw new Error('Health record not found.');
        }
        if (user.role === client_1.UserRole.PATIENT) {
            const patient = await health_record_repository_1.healthRecordRepository.findPatientProfileByUserId(user.userId);
            if (!patient || record.patientId !== patient.id) {
                throw new Error('Unauthorized to modify this health record.');
            }
        }
        return health_record_repository_1.healthRecordRepository.updateRecord(recordId, input);
    }
    async deleteRecord(user, recordId) {
        const record = await health_record_repository_1.healthRecordRepository.getRecordById(recordId);
        if (!record) {
            throw new Error('Health record not found.');
        }
        if (user.role === client_1.UserRole.PATIENT) {
            const patient = await health_record_repository_1.healthRecordRepository.findPatientProfileByUserId(user.userId);
            if (!patient || record.patientId !== patient.id) {
                throw new Error('Unauthorized to delete this health record.');
            }
        }
        await health_record_repository_1.healthRecordRepository.deleteRecord(recordId);
    }
}
exports.HealthRecordService = HealthRecordService;
exports.healthRecordService = new HealthRecordService();
