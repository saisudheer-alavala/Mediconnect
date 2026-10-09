import { scheduleRepository } from '../repositories/schedule.repository';
import { DayScheduleItemInput, UpdateScheduleInput } from '../validators/schedule.validator';

export class ScheduleService {
  async getMySchedule(userId: string) {
    const doctor = await scheduleRepository.findDoctorProfileByUserId(userId);
    if (!doctor) {
      throw new Error('Only registered medical practitioners can manage consultation schedules.');
    }

    const existing = await scheduleRepository.getDoctorSchedule(doctor.id);
    if (existing.length > 0) {
      return existing;
    }

    // Default template if practitioner has not yet set up hours
    const defaultTemplate: DayScheduleItemInput[] = [
      { dayOfWeek: 1, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
      { dayOfWeek: 2, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
      { dayOfWeek: 3, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
      { dayOfWeek: 4, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
      { dayOfWeek: 5, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
      { dayOfWeek: 6, startTime: '10:00', endTime: '14:00', slotDurationMinutes: 30, breakStartTime: null, breakEndTime: null, isActive: false },
      { dayOfWeek: 0, startTime: '10:00', endTime: '14:00', slotDurationMinutes: 30, breakStartTime: null, breakEndTime: null, isActive: false },
    ];

    return scheduleRepository.upsertDoctorSchedule(doctor.id, defaultTemplate);
  }

  async updateMySchedule(userId: string, input: UpdateScheduleInput) {
    const doctor = await scheduleRepository.findDoctorProfileByUserId(userId);
    if (!doctor) {
      throw new Error('Only registered medical practitioners can manage consultation schedules.');
    }

    const items: DayScheduleItemInput[] = Array.isArray(input) ? input : input.schedule;
    return scheduleRepository.upsertDoctorSchedule(doctor.id, items);
  }
}

export const scheduleService = new ScheduleService();
