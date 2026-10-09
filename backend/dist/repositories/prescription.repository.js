"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prescriptionRepository = exports.PrescriptionRepository = void 0;
const database_1 = require("../config/database");
class PrescriptionRepository {
    async findDoctorProfileByUserId(userId) {
        return database_1.prisma.doctorProfile.findUnique({
            where: { userId },
        });
    }
    async findPatientProfileByUserId(userId) {
        return database_1.prisma.patientProfile.findUnique({
            where: { userId },
        });
    }
    async findPatientProfileById(patientId) {
        return database_1.prisma.patientProfile.findUnique({
            where: { id: patientId },
        });
    }
    async findAppointmentById(appointmentId) {
        return database_1.prisma.appointment.findUnique({
            where: { id: appointmentId },
        });
    }
    async createPrescription(doctorId, input) {
        return database_1.prisma.$transaction(async (tx) => {
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
            return prescription;
        });
    }
    async getPrescriptionsByPatientId(patientId) {
        const list = await database_1.prisma.prescription.findMany({
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
        return list;
    }
    async getPrescriptionsByDoctorId(doctorId) {
        const list = await database_1.prisma.prescription.findMany({
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
        return list;
    }
    async getPrescriptionById(id) {
        const item = await database_1.prisma.prescription.findUnique({
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
        return item;
    }
    async getPrescriptionByAppointmentId(appointmentId) {
        const item = await database_1.prisma.prescription.findUnique({
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
        return item;
    }
}
exports.PrescriptionRepository = PrescriptionRepository;
exports.prescriptionRepository = new PrescriptionRepository();
