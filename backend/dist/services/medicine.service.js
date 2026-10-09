"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.medicineService = exports.MedicineService = void 0;
const client_1 = require("@prisma/client");
const medicine_repository_1 = require("../repositories/medicine.repository");
class MedicineService {
    /**
     * Helper to ensure user is a patient and get their patient profile ID
     */
    async getPatientId(userId) {
        const profile = await medicine_repository_1.medicineRepository.findPatientProfileByUserId(userId);
        if (!profile) {
            throw new Error('Patient profile not found for this account.');
        }
        return profile.id;
    }
    /**
     * Create a new medicine regimen
     */
    async createMedicine(userId, data) {
        const patientId = await this.getPatientId(userId);
        // Business validation: endDate cannot precede startDate
        if (data.endDate) {
            const start = new Date(data.startDate);
            const end = new Date(data.endDate);
            if (end < start) {
                throw new Error('Medicine end date cannot be earlier than start date.');
            }
        }
        return medicine_repository_1.medicineRepository.createMedicine(patientId, data);
    }
    /**
     * Get all medicines for a patient
     */
    async getMedicines(userId, activeOnly = false) {
        const patientId = await this.getPatientId(userId);
        return medicine_repository_1.medicineRepository.findMedicinesByPatient(patientId, activeOnly);
    }
    /**
     * Get single medicine details
     */
    async getMedicineById(userId, medicineId) {
        const patientId = await this.getPatientId(userId);
        const medicine = await medicine_repository_1.medicineRepository.findMedicineById(medicineId, patientId);
        if (!medicine) {
            throw new Error('Medicine regimen not found.');
        }
        return medicine;
    }
    /**
     * Update existing medicine
     */
    async updateMedicine(userId, medicineId, data) {
        const patientId = await this.getPatientId(userId);
        if (data.startDate && data.endDate) {
            const start = new Date(data.startDate);
            const end = new Date(data.endDate);
            if (end < start) {
                throw new Error('Medicine end date cannot be earlier than start date.');
            }
        }
        return medicine_repository_1.medicineRepository.updateMedicine(medicineId, patientId, data);
    }
    /**
     * Discontinue medicine
     */
    async deleteMedicine(userId, medicineId) {
        const patientId = await this.getPatientId(userId);
        return medicine_repository_1.medicineRepository.deactivateMedicine(medicineId, patientId);
    }
    /**
     * Get today's scheduled dose checklist with live adherence statuses
     */
    async getTodayMedicines(userId, dateStr) {
        const patientId = await this.getPatientId(userId);
        const targetDate = dateStr ? new Date(dateStr) : new Date();
        return medicine_repository_1.medicineRepository.getTodaySchedule(patientId, targetDate);
    }
    /**
     * Log dose adherence
     */
    async logDose(userId, medicineId, data) {
        const patientId = await this.getPatientId(userId);
        // Verify medicine belongs to patient
        const medicine = await medicine_repository_1.medicineRepository.findMedicineById(medicineId, patientId);
        if (!medicine) {
            throw new Error('Medicine regimen not found or does not belong to you.');
        }
        return medicine_repository_1.medicineRepository.logDose(patientId, medicineId, data);
    }
    /**
     * Generate adherence metrics for the past N days
     */
    async getAdherenceReport(userId, days = 7) {
        const patientId = await this.getPatientId(userId);
        const sinceDate = new Date();
        sinceDate.setDate(sinceDate.getDate() - days);
        const logs = await medicine_repository_1.medicineRepository.getAdherenceLogs(patientId, sinceDate);
        const totalDoses = logs.length;
        const takenDoses = logs.filter((l) => l.status === client_1.DoseStatus.TAKEN).length;
        const skippedDoses = logs.filter((l) => l.status === client_1.DoseStatus.SKIPPED).length;
        const missedDoses = logs.filter((l) => l.status === client_1.DoseStatus.MISSED).length;
        const adherenceRatePercentage = totalDoses > 0 ? Math.round((takenDoses / totalDoses) * 1000) / 10 : 100.0;
        return {
            totalDoses,
            takenDoses,
            skippedDoses,
            missedDoses,
            adherenceRatePercentage,
            periodDays: days,
        };
    }
}
exports.MedicineService = MedicineService;
exports.medicineService = new MedicineService();
