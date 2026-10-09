import { AppointmentStatus, DoctorAvailability, DoctorProfile, Specialization } from '@prisma/client';
import { prisma } from '../config/database';
import { SearchDoctorInput } from '../validators/doctor.validator';

export class DoctorRepository {
  /**
   * Retrieve all specializations with doctor counts
   */
  async findSpecializations(): Promise<(Specialization & { _count: { doctors: number } })[]> {
    return prisma.specialization.findMany({
      include: {
        _count: {
          select: { doctors: true },
        },
      },
      orderBy: { name: 'asc' },
    });
  }

  /**
   * Search and filter doctors directory
   */
  async searchDoctors(
    filters: SearchDoctorInput
  ): Promise<{ doctors: (DoctorProfile & { specialization: Specialization | null; availabilities: DoctorAvailability[] })[]; total: number }> {
    const whereClause: any = {};

    // Search keyword in name, clinic, or specialization name
    if (filters.search) {
      whereClause.OR = [
        { fullName: { contains: filters.search, mode: 'insensitive' } },
        { clinicName: { contains: filters.search, mode: 'insensitive' } },
        { specialization: { name: { contains: filters.search, mode: 'insensitive' } } },
      ];
    }

    if (filters.specializationId) {
      whereClause.specializationId = filters.specializationId;
    }

    if (filters.minFee !== undefined || filters.maxFee !== undefined) {
      whereClause.consultationFee = {};
      if (filters.minFee !== undefined) whereClause.consultationFee.gte = filters.minFee;
      if (filters.maxFee !== undefined) whereClause.consultationFee.lte = filters.maxFee;
    }

    if (filters.minExperience !== undefined) {
      whereClause.experienceYears = { gte: filters.minExperience };
    }

    const skip = (filters.page - 1) * filters.limit;

    const [doctors, total] = await Promise.all([
      prisma.doctorProfile.findMany({
        where: whereClause,
        include: {
          specialization: true,
          availabilities: {
            where: { isActive: true },
            orderBy: { dayOfWeek: 'asc' },
          },
        },
        orderBy: [{ isVerified: 'desc' }, { experienceYears: 'desc' }],
        skip,
        take: filters.limit,
      }),
      prisma.doctorProfile.count({ where: whereClause }),
    ]);

    return { doctors, total };
  }

  /**
   * Find doctor details by ID
   */
  async findDoctorById(
    id: string
  ): Promise<(DoctorProfile & { specialization: Specialization | null; availabilities: DoctorAvailability[] }) | null> {
    return prisma.doctorProfile.findUnique({
      where: { id },
      include: {
        specialization: true,
        availabilities: {
          where: { isActive: true },
          orderBy: { dayOfWeek: 'asc' },
        },
      },
    });
  }

  /**
   * Retrieve appointments already booked for a specific doctor on a given date
   */
  async findBookedAppointmentsForDate(
    doctorId: string,
    appointmentDate: Date
  ): Promise<{ startTime: string; endTime: string }[]> {
    return prisma.appointment.findMany({
      where: {
        doctorId,
        appointmentDate,
        status: {
          not: AppointmentStatus.CANCELLED,
        },
      },
      select: {
        startTime: true,
        endTime: true,
      },
    });
  }
}

export const doctorRepository = new DoctorRepository();
