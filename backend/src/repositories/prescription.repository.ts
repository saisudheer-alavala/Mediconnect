import { Prisma, Prescription, DoctorProfile, PatientProfile, Appointment } from '@prisma/client';
import { prisma } from '../config/database';
import { CreatePrescriptionInput } from '../validators/prescription.validator';

export type PrescriptionWithDetails = Prescription & {
  medicines: {
    id: string;
    prescriptionId: string;
    medicineName: string;
    dosage: string;
    frequency: string;
    durationDays: number;
    instructions: string | null;
  }[];
  doctor: DoctorProfile & { specialization: { name: string } | null };
  patient: PatientProfile;
  appointment: Appointment | null;
};

export class PrescriptionRepository {
  async findDoctorProfileByUserId(userId: string): Promise<DoctorProfile | null> {
    return prisma.doctorProfile.findUnique({
      where: { userId },
    });
  }

  async findPatientProfileByUserId(userId: string): Promise<PatientProfile | null> {
    return prisma.patientProfile.findUnique({
      where: { userId },
    });
  }

  async findPatientProfileById(patientId: string): Promise<PatientProfile | null> {
    return prisma.patientProfile.findUnique({
      where: { id: patientId },
    });
  }

  async findAppointmentById(appointmentId: string): Promise<Appointment | null> {
    return prisma.appointment.findUnique({
      where: { id: appointmentId },
    });
  }

  async createPrescription(doctorId: string, input: CreatePrescriptionInput): Promise<PrescriptionWithDetails> {
    return prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      const prescription = await tx.prescription.create({
        data: {
          doctorId,
          patientId: input.patientId,
          appointmentId: input.appointmentId,
          diagnosis: input.diagnosis,
          generalInstructions: input.generalInstructions,
          medicines: {
            create: input.medicines.map((m) => ({
              medicineName: m.medicineName,
              dosage: m.dosage,
              frequency: m.frequency,
              durationDays: m.durationDays,
              instructions: m.instructions,
            })),
          },
        },
        include: {
          medicines: true,
          doctor: {
            include: {
              specialization: {
                select: { name: true },
              },
            },
          },
          patient: true,
          appointment: true,
        },
      });

      // If tied to an active appointment, mark appointment as COMPLETED
      if (input.appointmentId) {
        await tx.appointment.update({
          where: { id: input.appointmentId },
          data: { status: 'COMPLETED' },
        });
      }

      return prescription as PrescriptionWithDetails;
    });
  }

  async getPrescriptionsByPatientId(patientId: string): Promise<PrescriptionWithDetails[]> {
    const list = await prisma.prescription.findMany({
      where: { patientId },
      include: {
        medicines: true,
        doctor: {
          include: {
            specialization: {
              select: { name: true },
            },
          },
        },
        patient: true,
        appointment: true,
      },
      orderBy: { issuedAt: 'desc' },
    });
    return list as PrescriptionWithDetails[];
  }

  async getPrescriptionsByDoctorId(doctorId: string): Promise<PrescriptionWithDetails[]> {
    const list = await prisma.prescription.findMany({
      where: { doctorId },
      include: {
        medicines: true,
        doctor: {
          include: {
            specialization: {
              select: { name: true },
            },
          },
        },
        patient: true,
        appointment: true,
      },
      orderBy: { issuedAt: 'desc' },
    });
    return list as PrescriptionWithDetails[];
  }

  async getPrescriptionById(id: string): Promise<PrescriptionWithDetails | null> {
    const item = await prisma.prescription.findUnique({
      where: { id },
      include: {
        medicines: true,
        doctor: {
          include: {
            specialization: {
              select: { name: true },
            },
          },
        },
        patient: true,
        appointment: true,
      },
    });
    return item as PrescriptionWithDetails | null;
  }

  async getPrescriptionByAppointmentId(appointmentId: string): Promise<PrescriptionWithDetails | null> {
    const item = await prisma.prescription.findUnique({
      where: { appointmentId },
      include: {
        medicines: true,
        doctor: {
          include: {
            specialization: {
              select: { name: true },
            },
          },
        },
        patient: true,
        appointment: true,
      },
    });
    return item as PrescriptionWithDetails | null;
  }
}

export const prescriptionRepository = new PrescriptionRepository();
