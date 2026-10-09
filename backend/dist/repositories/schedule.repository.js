"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.scheduleRepository = exports.ScheduleRepository = void 0;
const database_1 = require("../config/database");
class ScheduleRepository {
    async findDoctorProfileByUserId(userId) {
        return database_1.prisma.doctorProfile.findUnique({
            where: { userId },
        });
    }
    async getDoctorSchedule(doctorId) {
        return database_1.prisma.doctorAvailability.findMany({
            where: { doctorId },
            orderBy: { dayOfWeek: 'asc' },
        });
    }
    async upsertDoctorSchedule(doctorId, items) {
        await database_1.prisma.$transaction(items.map((item) => database_1.prisma.doctorAvailability.upsert({
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
        })));
        return this.getDoctorSchedule(doctorId);
    }
}
exports.ScheduleRepository = ScheduleRepository;
exports.scheduleRepository = new ScheduleRepository();
