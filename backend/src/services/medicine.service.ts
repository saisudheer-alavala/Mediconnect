import { DoseStatus } from '@prisma/client';
import { medicineRepository, ScheduledDoseItem } from '../repositories/medicine.repository';
import { CreateMedicineInput, UpdateMedicineInput, LogDoseInput } from '../validators/medicine.validator';

export interface AdherenceReport {
  totalDoses: number;
  takenDoses: number;
  skippedDoses: number;
  missedDoses: number;
  adherenceRatePercentage: number;
  periodDays: number;
}

export class MedicineService {
  /**
   * Helper to ensure user is a patient and get their patient profile ID
   */
  private async getPatientId(userId: string): Promise<string> {
    const profile = await medicineRepository.findPatientProfileByUserId(userId);
    if (!profile) {
      throw new Error('Patient profile not found for this account.');
    }
    return profile.id;
  }

  /**
   * Create a new medicine regimen
   */
  async createMedicine(userId: string, data: CreateMedicineInput) {
    const patientId = await this.getPatientId(userId);

    // Business validation: endDate cannot precede startDate
    if (data.endDate) {
      const start = new Date(data.startDate);
      const end = new Date(data.endDate);
      if (end < start) {
        throw new Error('Medicine end date cannot be earlier than start date.');
      }
    }

    return medicineRepository.createMedicine(patientId, data);
  }

  /**
   * Get all medicines for a patient
   */
  async getMedicines(userId: string, activeOnly = false) {
    const patientId = await this.getPatientId(userId);
    return medicineRepository.findMedicinesByPatient(patientId, activeOnly);
  }

  /**
   * Get single medicine details
   */
  async getMedicineById(userId: string, medicineId: string) {
    const patientId = await this.getPatientId(userId);
    const medicine = await medicineRepository.findMedicineById(medicineId, patientId);
    if (!medicine) {
      throw new Error('Medicine regimen not found.');
    }
    return medicine;
  }

  /**
   * Update existing medicine
   */
  async updateMedicine(userId: string, medicineId: string, data: UpdateMedicineInput) {
    const patientId = await this.getPatientId(userId);

    if (data.startDate && data.endDate) {
      const start = new Date(data.startDate);
      const end = new Date(data.endDate);
      if (end < start) {
        throw new Error('Medicine end date cannot be earlier than start date.');
      }
    }

    return medicineRepository.updateMedicine(medicineId, patientId, data);
  }

  /**
   * Discontinue medicine
   */
  async deleteMedicine(userId: string, medicineId: string) {
    const patientId = await this.getPatientId(userId);
    return medicineRepository.deactivateMedicine(medicineId, patientId);
  }

  /**
   * Get today's scheduled dose checklist with live adherence statuses
   */
  async getTodayMedicines(userId: string, dateStr?: string): Promise<ScheduledDoseItem[]> {
    const patientId = await this.getPatientId(userId);
    const targetDate = dateStr ? new Date(dateStr) : new Date();
    return medicineRepository.getTodaySchedule(patientId, targetDate);
  }

  /**
   * Log dose adherence
   */
  async logDose(userId: string, medicineId: string, data: LogDoseInput) {
    const patientId = await this.getPatientId(userId);

    // Verify medicine belongs to patient
    const medicine = await medicineRepository.findMedicineById(medicineId, patientId);
    if (!medicine) {
      throw new Error('Medicine regimen not found or does not belong to you.');
    }

    return medicineRepository.logDose(patientId, medicineId, data);
  }

  /**
   * Generate adherence metrics for the past N days
   */
  async getAdherenceReport(userId: string, days = 7): Promise<AdherenceReport> {
    const patientId = await this.getPatientId(userId);
    const sinceDate = new Date();
    sinceDate.setDate(sinceDate.getDate() - days);

    const logs = await medicineRepository.getAdherenceLogs(patientId, sinceDate);

    const totalDoses = logs.length;
    const takenDoses = logs.filter((l) => l.status === DoseStatus.TAKEN).length;
    const skippedDoses = logs.filter((l) => l.status === DoseStatus.SKIPPED).length;
    const missedDoses = logs.filter((l) => l.status === DoseStatus.MISSED).length;

    const adherenceRatePercentage =
      totalDoses > 0 ? Math.round((takenDoses / totalDoses) * 1000) / 10 : 100.0;

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

export const medicineService = new MedicineService();
