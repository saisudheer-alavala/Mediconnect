import { DoseStatus, Medicine, MedicineLog, MedicineReminder, PatientProfile } from '@prisma/client';
import { prisma } from '../config/database';
import { CreateMedicineInput, UpdateMedicineInput, LogDoseInput } from '../validators/medicine.validator';

export interface ScheduledDoseItem {
  medicineId: string;
  medicineName: string;
  dosage: string;
  frequency: string;
  instructions: string | null;
  reminderId: string;
  reminderTime: string;
  scheduledTime: string; // ISO string
  status: 'PENDING' | 'TAKEN' | 'SKIPPED' | 'MISSED';
  logId?: string;
  takenTime?: string | null;
  notes?: string | null;
}

export class MedicineRepository {
  /**
   * Find patient profile corresponding to a user account
   */
  async findPatientProfileByUserId(userId: string): Promise<PatientProfile | null> {
    return prisma.patientProfile.findUnique({
      where: { userId },
    });
  }

  /**
   * Create a new medicine regimen with reminder times
   */
  async createMedicine(
    patientId: string,
    data: CreateMedicineInput
  ): Promise<Medicine & { reminders: MedicineReminder[] }> {
    return prisma.medicine.create({
      data: {
        patientId,
        name: data.name,
        dosage: data.dosage,
        frequency: data.frequency,
        instructions: data.instructions,
        startDate: new Date(data.startDate),
        endDate: data.endDate ? new Date(data.endDate) : null,
        reminders: {
          create: data.reminders.map((time) => ({
            reminderTime: time,
          })),
        },
      },
      include: {
        reminders: true,
      },
    });
  }

  /**
   * List all medicines for a given patient
   */
  async findMedicinesByPatient(
    patientId: string,
    activeOnly = false
  ): Promise<(Medicine & { reminders: MedicineReminder[] })[]> {
    return prisma.medicine.findMany({
      where: {
        patientId,
        ...(activeOnly ? { isActive: true } : {}),
      },
      include: {
        reminders: {
          orderBy: { reminderTime: 'asc' },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Find a specific medicine by ID ensuring it belongs to the patient
   */
  async findMedicineById(
    medicineId: string,
    patientId: string
  ): Promise<(Medicine & { reminders: MedicineReminder[]; logs: MedicineLog[] }) | null> {
    return prisma.medicine.findFirst({
      where: {
        id: medicineId,
        patientId,
      },
      include: {
        reminders: {
          orderBy: { reminderTime: 'asc' },
        },
        logs: {
          orderBy: { scheduledTime: 'desc' },
          take: 10,
        },
      },
    });
  }

  /**
   * Update a medicine and replace reminders if supplied
   */
  async updateMedicine(
    medicineId: string,
    patientId: string,
    data: UpdateMedicineInput
  ): Promise<Medicine & { reminders: MedicineReminder[] }> {
    return prisma.$transaction(async (tx) => {
      // Ensure ownership
      const existing = await tx.medicine.findFirst({
        where: { id: medicineId, patientId },
      });
      if (!existing) {
        throw new Error('Medicine not found or access denied');
      }

      // Update medicine attributes
      const updated = await tx.medicine.update({
        where: { id: medicineId },
        data: {
          name: data.name,
          dosage: data.dosage,
          frequency: data.frequency,
          instructions: data.instructions,
          startDate: data.startDate ? new Date(data.startDate) : undefined,
          endDate: data.endDate !== undefined ? (data.endDate ? new Date(data.endDate) : null) : undefined,
          isActive: data.isActive,
        },
      });

      // Update reminders if array provided
      if (data.reminders) {
        await tx.medicineReminder.deleteMany({
          where: { medicineId },
        });

        await tx.medicineReminder.createMany({
          data: data.reminders.map((time) => ({
            medicineId,
            reminderTime: time,
          })),
        });
      }

      const reminders = await tx.medicineReminder.findMany({
        where: { medicineId },
        orderBy: { reminderTime: 'asc' },
      });

      return {
        ...updated,
        reminders,
      };
    });
  }

  /**
   * Deactivate or delete a medicine
   */
  async deactivateMedicine(medicineId: string, patientId: string): Promise<Medicine> {
    return prisma.medicine.update({
      where: {
        id: medicineId,
        patientId,
      },
      data: {
        isActive: false,
      },
    });
  }

  /**
   * Log dose adherence (taken, skipped, missed)
   */
  async logDose(patientId: string, medicineId: string, data: LogDoseInput): Promise<MedicineLog> {
    const scheduled = new Date(data.scheduledTime);
    const taken = data.status === DoseStatus.TAKEN ? (data.takenTime ? new Date(data.takenTime) : new Date()) : null;

    // Check if a log already exists for this dose time to update or create
    const existingLog = await prisma.medicineLog.findFirst({
      where: {
        medicineId,
        patientId,
        scheduledTime: scheduled,
      },
    });

    if (existingLog) {
      return prisma.medicineLog.update({
        where: { id: existingLog.id },
        data: {
          status: data.status,
          takenTime: taken,
          notes: data.notes,
        },
      });
    }

    return prisma.medicineLog.create({
      data: {
        medicineId,
        patientId,
        scheduledTime: scheduled,
        takenTime: taken,
        status: data.status,
        notes: data.notes,
      },
    });
  }

  /**
   * Fetch today's scheduled doses merged with dose logs
   */
  async getTodaySchedule(patientId: string, targetDate: Date): Promise<ScheduledDoseItem[]> {
    const startOfDay = new Date(targetDate);
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(targetDate);
    endOfDay.setHours(23, 59, 59, 999);

    // 1. Fetch active medicines active on targetDate
    const medicines = await prisma.medicine.findMany({
      where: {
        patientId,
        isActive: true,
        startDate: { lte: endOfDay },
        OR: [{ endDate: null }, { endDate: { gte: startOfDay } }],
      },
      include: {
        reminders: {
          orderBy: { reminderTime: 'asc' },
        },
      },
    });

    // 2. Fetch all logs logged for today
    const logs = await prisma.medicineLog.findMany({
      where: {
        patientId,
        scheduledTime: {
          gte: startOfDay,
          lte: endOfDay,
        },
      },
    });

    // 3. Map into ScheduledDoseItems
    const scheduleItems: ScheduledDoseItem[] = [];

    for (const med of medicines) {
      for (const reminder of med.reminders) {
        const [hours, minutes] = reminder.reminderTime.split(':').map(Number);
        const scheduledTime = new Date(targetDate);
        scheduledTime.setHours(hours, minutes, 0, 0);

        // Find matching log if any (match within same hour/minute)
        const log = logs.find((l) => {
          const lTime = new Date(l.scheduledTime);
          return (
            l.medicineId === med.id &&
            lTime.getHours() === hours &&
            lTime.getMinutes() === minutes
          );
        });

        const status: 'PENDING' | 'TAKEN' | 'SKIPPED' | 'MISSED' = log
          ? (log.status as 'TAKEN' | 'SKIPPED' | 'MISSED')
          : 'PENDING';

        scheduleItems.push({
          medicineId: med.id,
          medicineName: med.name,
          dosage: med.dosage,
          frequency: med.frequency,
          instructions: med.instructions,
          reminderId: reminder.id,
          reminderTime: reminder.reminderTime,
          scheduledTime: scheduledTime.toISOString(),
          status,
          logId: log?.id,
          takenTime: log?.takenTime ? log.takenTime.toISOString() : null,
          notes: log?.notes ?? null,
        });
      }
    }

    // Sort by reminder time
    scheduleItems.sort((a, b) => a.reminderTime.localeCompare(b.reminderTime));
    return scheduleItems;
  }

  /**
   * Get logs for adherence calculations over the last N days
   */
  async getAdherenceLogs(patientId: string, sinceDate: Date): Promise<MedicineLog[]> {
    return prisma.medicineLog.findMany({
      where: {
        patientId,
        scheduledTime: { gte: sinceDate },
      },
    });
  }
}

export const medicineRepository = new MedicineRepository();
