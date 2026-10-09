"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.appointmentRepository = exports.AppointmentRepository = void 0;
const client_1 = require("@prisma/client");
const database_1 = require("../config/database");
class AppointmentRepository {
    async findPatientProfileByUserId(userId) {
        return database_1.prisma.patientProfile.findUnique({
            where: { userId },
        });
    }
    async findDoctorProfileByUserId(userId) {
        return database_1.prisma.doctorProfile.findUnique({
            where: { userId },
        });
    }
    /**
     * Check if a specific slot is already booked for this doctor
     */
    async checkSlotConflict(doctorId, appointmentDate, startTime) {
        const existing = await database_1.prisma.appointment.findFirst({
            where: {
                doctorId,
                appointmentDate,
                startTime,
                status: {
                    not: client_1.AppointmentStatus.CANCELLED,
                },
            },
        });
        return existing !== null;
    }
    /**
     * Book appointment
     */
    async createAppointment(data) {
        return database_1.prisma.appointment.create({
            data: {
                patientId: data.patientId,
                doctorId: data.doctorId,
                appointmentDate: data.appointmentDate,
                startTime: data.startTime,
                endTime: data.endTime,
                status: client_1.AppointmentStatus.CONFIRMED, // Auto-confirmed on creation
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
        });
    }
    /**
     * List appointments for a patient
     */
    async findAppointmentsByPatient(patientId, filters) {
        const where = { patientId };
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
            where.status = { in: [client_1.AppointmentStatus.PENDING, client_1.AppointmentStatus.CONFIRMED] };
        }
        return database_1.prisma.appointment.findMany({
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
        });
    }
    /**
     * List appointments for a doctor
     */
    async findAppointmentsByDoctor(doctorId, filters) {
        const where = { doctorId };
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
            where.status = { in: [client_1.AppointmentStatus.PENDING, client_1.AppointmentStatus.CONFIRMED] };
        }
        return database_1.prisma.appointment.findMany({
            where,
            include: {
                doctor: {
                    include: {
                        specialization: {
                            select: { name: true },
                        },
                    },
                },
                patient: {
                    include: {
                        user: {
                            select: {
                                phone: true,
                                email: true,
                            },
                        },
                    },
                },
            },
            orderBy: [{ appointmentDate: 'asc' }, { startTime: 'asc' }],
        });
    }
    /**
     * Find appointment by ID
     */
    async findAppointmentById(id) {
        return database_1.prisma.appointment.findUnique({
            where: { id },
            include: {
                doctor: {
                    include: {
                        specialization: {
                            select: { name: true },
                        },
                    },
                },
                patient: {
                    include: {
                        user: {
                            select: {
                                phone: true,
                                email: true,
                            },
                        },
                    },
                },
            },
        });
    }
    /**
     * Update status of an appointment
     */
    async updateAppointmentStatus(id, status, cancellationReason) {
        return database_1.prisma.appointment.update({
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
        });
    }
}
exports.AppointmentRepository = AppointmentRepository;
exports.appointmentRepository = new AppointmentRepository();
