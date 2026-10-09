import { DoctorAvailability } from '@prisma/client';
import { prisma } from '../config/database';
import { DayScheduleItemInput } from '../validators/schedule.validator';

export class ScheduleRepository {
  async findDoctorProfileByUserId(userId: string) {
    return prisma.doctorProfile.findUnique({
      where: { userId },
    });
  }

  async getDoctorSchedule(doctorId: string): Promise<DoctorAvailability[]> {
    return prisma.doctorAvailability.findMany({
      where: { doctorId },
      orderBy: { dayOfWeek: 'asc' },
    });
  }

  async upsertDoctorSchedule(
    doctorId: string,
    items: DayScheduleItemInput[]
  ): Promise<DoctorAvailability[]> {
    await prisma.$transaction(
      items.map((item) =>
        prisma.doctorAvailability.upsert({
          where: {
            doctorId_dayOfWeek: {
              doctorId,
              dayOfWeek: item.dayOfWeek,
            },
          },
          create: {
            doctorId,
            dayOfWeek: item.dayOfWeek,
            startTime: item.startTime,
            endTime: item.endTime,
            slotDurationMinutes: item.slotDurationMinutes,
            breakStartTime: item.breakStartTime ?? null,
            breakEndTime: item.breakEndTime ?? null,
            isActive: item.isActive,
          },
          update: {
            startTime: item.startTime,
            endTime: item.endTime,
            slotDurationMinutes: item.slotDurationMinutes,
            breakStartTime: item.breakStartTime ?? null,
            breakEndTime: item.breakEndTime ?? null,
            isActive: item.isActive,
          },
        })
      )
    );

    return this.getDoctorSchedule(doctorId);
  }
}

export const scheduleRepository = new ScheduleRepository();
