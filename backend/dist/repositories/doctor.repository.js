"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.doctorRepository = exports.DoctorRepository = void 0;
const client_1 = require("@prisma/client");
const database_1 = require("../config/database");
class DoctorRepository {
    /**
     * Retrieve all specializations with doctor counts
     */
    async findSpecializations() {
        return database_1.prisma.specialization.findMany({
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
    async searchDoctors(filters) {
        const whereClause = {};
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
            if (filters.minFee !== undefined)
                whereClause.consultationFee.gte = filters.minFee;
            if (filters.maxFee !== undefined)
                whereClause.consultationFee.lte = filters.maxFee;
        }
        if (filters.minExperience !== undefined) {
            whereClause.experienceYears = { gte: filters.minExperience };
        }
        const skip = (filters.page - 1) * filters.limit;
        const [doctors, total] = await Promise.all([
            database_1.prisma.doctorProfile.findMany({
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
            database_1.prisma.doctorProfile.count({ where: whereClause }),
        ]);
        return { doctors, total };
    }
    /**
     * Find doctor details by ID
     */
    async findDoctorById(id) {
        return database_1.prisma.doctorProfile.findUnique({
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
    async findBookedAppointmentsForDate(doctorId, appointmentDate) {
        return database_1.prisma.appointment.findMany({
            where: {
                doctorId,
                appointmentDate,
                status: {
                    not: client_1.AppointmentStatus.CANCELLED,
                },
            },
            select: {
                startTime: true,
                endTime: true,
            },
        });
    }
}
exports.DoctorRepository = DoctorRepository;
exports.doctorRepository = new DoctorRepository();
