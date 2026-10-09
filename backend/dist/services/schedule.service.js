"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.scheduleService = exports.ScheduleService = void 0;
const schedule_repository_1 = require("../repositories/schedule.repository");
class ScheduleService {
    async getMySchedule(userId) {
        const doctor = await schedule_repository_1.scheduleRepository.findDoctorProfileByUserId(userId);
        if (!doctor) {
            throw new Error('Only registered medical practitioners can manage consultation schedules.');
        }
        const existing = await schedule_repository_1.scheduleRepository.getDoctorSchedule(doctor.id);
        if (existing.length > 0) {
            return existing;
        }
        // Default template if practitioner has not yet set up hours
        const defaultTemplate = [
            { dayOfWeek: 1, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
            { dayOfWeek: 2, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
            { dayOfWeek: 3, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
            { dayOfWeek: 4, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
            { dayOfWeek: 5, startTime: '09:00', endTime: '17:00', slotDurationMinutes: 30, breakStartTime: '13:00', breakEndTime: '14:00', isActive: true },
            { dayOfWeek: 6, startTime: '10:00', endTime: '14:00', slotDurationMinutes: 30, breakStartTime: null, breakEndTime: null, isActive: false },
            { dayOfWeek: 0, startTime: '10:00', endTime: '14:00', slotDurationMinutes: 30, breakStartTime: null, breakEndTime: null, isActive: false },
        ];
        return schedule_repository_1.scheduleRepository.upsertDoctorSchedule(doctor.id, defaultTemplate);
    }
    async updateMySchedule(userId, input) {
        const doctor = await schedule_repository_1.scheduleRepository.findDoctorProfileByUserId(userId);
        if (!doctor) {
            throw new Error('Only registered medical practitioners can manage consultation schedules.');
        }
        const items = Array.isArray(input) ? input : input.schedule;
        return schedule_repository_1.scheduleRepository.upsertDoctorSchedule(doctor.id, items);
    }
}
exports.ScheduleService = ScheduleService;
exports.scheduleService = new ScheduleService();
