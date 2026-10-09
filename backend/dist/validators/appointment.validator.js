"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.queryAppointmentsSchema = exports.updateAppointmentStatusSchema = exports.createAppointmentSchema = void 0;
const zod_1 = require("zod");
const client_1 = require("@prisma/client");
exports.createAppointmentSchema = zod_1.z.object({
    doctorId: zod_1.z.string().uuid('Invalid Doctor ID'),
    appointmentDate: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'Appointment date must be formatted as YYYY-MM-DD',
    }),
    startTime: zod_1.z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, {
        message: 'Start time must be formatted as HH:mm (24-hour format)',
    }),
    patientNotes: zod_1.z.string().trim().max(500, 'Notes cannot exceed 500 characters').optional().nullable(),
});
exports.updateAppointmentStatusSchema = zod_1.z.object({
    status: zod_1.z.nativeEnum(client_1.AppointmentStatus, {
        errorMap: () => ({ message: 'Status must be CONFIRMED, COMPLETED, CANCELLED, or NO_SHOW' }),
    }),
    cancellationReason: zod_1.z.string().trim().max(250).optional().nullable(),
});
exports.queryAppointmentsSchema = zod_1.z.object({
    status: zod_1.z.nativeEnum(client_1.AppointmentStatus).optional(),
    date: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
    upcomingOnly: zod_1.z
        .enum(['true', 'false'])
        .optional()
        .transform((val) => val === 'true'),
});
