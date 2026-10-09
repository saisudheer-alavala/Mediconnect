import { Appointment, AppointmentStatus, DoctorProfile, PatientProfile, Prisma } from '@prisma/client';
import { prisma } from '../config/database';
import { QueryAppointmentsInput } from '../validators/appointment.validator';

export type AppointmentWithDetails = Appointment & {
  doctor: DoctorProfile & { specialization: { name: string } | null };
  patient: PatientProfile;
};

export class AppointmentRepository {
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

  /**
   * Check if a specific slot is already booked for this doctor
   */
  async checkSlotConflict(doctorId: string, appointmentDate: Date, startTime: string): Promise<boolean> {
    const existing = await prisma.appointment.findFirst({
      where: {
        doctorId,
        appointmentDate,
        startTime,
        status: {
          not: AppointmentStatus.CANCELLED,
        },
      },
    });
    return existing !== null;
  }

  /**
   * Book appointment
   */
  async createAppointment(data: {
    patientId: string;
    doctorId: string;
    appointmentDate: Date;
    startTime: string;
    endTime: string;
    patientNotes?: string | null;
  }): Promise<AppointmentWithDetails> {
    return prisma.appointment.create({
      data: {
        patientId: data.patientId,
        doctorId: data.doctorId,
        appointmentDate: data.appointmentDate,
        startTime: data.startTime,
        endTime: data.endTime,
        status: AppointmentStatus.CONFIRMED, // Auto-confirmed on creation
        patientNotes: data.patientNotes,
      },
      include: {
        doctor: {
          include: {
            specialization: {
              select: { name: true },
            },
          },
        },
        patient: true,
      },
    }) as Promise<AppointmentWithDetails>;
  }

  /**
   * List appointments for a patient
   */
  async findAppointmentsByPatient(
    patientId: string,
    filters: QueryAppointmentsInput
  ): Promise<AppointmentWithDetails[]> {
    const where: Prisma.AppointmentWhereInput = { patientId };

    if (filters.status) {
      where.status = filters.status;
    }

    if (filters.date) {
      where.appointmentDate = new Date(filters.date + 'T00:00:00.000Z');
    }

    if (filters.upcomingOnly) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      where.appointmentDate = { gte: today };
      where.status = { in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] };
    }

    return prisma.appointment.findMany({
      where,
      include: {
        doctor: {
          include: {
            specialization: {
              select: { name: true },
            },
          },
        },
        patient: true,
      },
      orderBy: [{ appointmentDate: 'desc' }, { startTime: 'desc' }],
    }) as Promise<AppointmentWithDetails[]>;
  }

  /**
   * List appointments for a doctor
   */
  async findAppointmentsByDoctor(
    doctorId: string,
    filters: QueryAppointmentsInput
  ): Promise<AppointmentWithDetails[]> {
    const where: Prisma.AppointmentWhereInput = { doctorId };

    if (filters.status) {
      where.status = filters.status;
    }

    if (filters.date) {
      where.appointmentDate = new Date(filters.date + 'T00:00:00.000Z');
    }

    if (filters.upcomingOnly) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      where.appointmentDate = { gte: today };
      where.status = { in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] };
    }

    return prisma.appointment.findMany({
      where,
      include: {
        doctor: {
          include: {
            specialization: {
              select: { name: true },
            },
          },
        },
        patient: true,
      },
      orderBy: [{ appointmentDate: 'asc' }, { startTime: 'asc' }],
    }) as Promise<AppointmentWithDetails[]>;
  }

  /**
   * Find appointment by ID
   */
  async findAppointmentById(id: string): Promise<AppointmentWithDetails | null> {
    return prisma.appointment.findUnique({
      where: { id },
      include: {
        doctor: {
          include: {
            specialization: {
              select: { name: true },
            },
          },
        },
        patient: true,
      },
    }) as Promise<AppointmentWithDetails | null>;
  }

  /**
   * Update status of an appointment
   */
  async updateAppointmentStatus(
    id: string,
    status: AppointmentStatus,
    cancellationReason?: string | null
  ): Promise<AppointmentWithDetails> {
    return prisma.appointment.update({
      where: { id },
      data: {
        status,
        cancellationReason: cancellationReason ?? undefined,
      },
      include: {
        doctor: {
          include: {
            specialization: {
              select: { name: true },
            },
          },
        },
        patient: true,
      },
    }) as Promise<AppointmentWithDetails>;
  }
}

export const appointmentRepository = new AppointmentRepository();
