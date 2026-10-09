"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.logDoseSchema = exports.updateMedicineSchema = exports.createMedicineSchema = void 0;
const zod_1 = require("zod");
const client_1 = require("@prisma/client");
exports.createMedicineSchema = zod_1.z.object({
    name: zod_1.z.string().trim().min(1, 'Medicine name is required').max(100, 'Name too long'),
    dosage: zod_1.z.string().trim().min(1, 'Dosage is required (e.g., 500mg, 1 tablet)').max(50),
    frequency: zod_1.z.string().trim().min(1, 'Frequency is required (e.g., Twice daily)').max(50),
    instructions: zod_1.z.string().trim().max(250).optional(),
    startDate: zod_1.z.string().refine((val) => !isNaN(Date.parse(val)), {
        message: 'Start date must be a valid ISO date',
    }),
    endDate: zod_1.z
        .string()
        .refine((val) => !isNaN(Date.parse(val)), {
        message: 'End date must be a valid ISO date',
    })
        .optional()
        .nullable(),
    reminders: zod_1.z
        .array(zod_1.z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, {
        message: 'Reminder time must be in HH:mm 24-hour format (e.g., "08:00", "20:00")',
    }))
        .min(1, 'At least one reminder time is required'),
});
exports.updateMedicineSchema = zod_1.z.object({
    name: zod_1.z.string().trim().min(1).max(100).optional(),
    dosage: zod_1.z.string().trim().min(1).max(50).optional(),
    frequency: zod_1.z.string().trim().min(1).max(50).optional(),
    instructions: zod_1.z.string().trim().max(250).optional().nullable(),
    startDate: zod_1.z
        .string()
        .refine((val) => !isNaN(Date.parse(val)), {
        message: 'Start date must be a valid ISO date',
    })
        .optional(),
    endDate: zod_1.z
        .string()
        .refine((val) => !isNaN(Date.parse(val)), {
        message: 'End date must be a valid ISO date',
    })
        .optional()
        .nullable(),
    isActive: zod_1.z.boolean().optional(),
    reminders: zod_1.z
        .array(zod_1.z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, {
        message: 'Reminder time must be in HH:mm 24-hour format',
    }))
        .min(1)
        .optional(),
});
exports.logDoseSchema = zod_1.z.object({
    scheduledTime: zod_1.z.string().refine((val) => !isNaN(Date.parse(val)), {
        message: 'Scheduled time must be a valid ISO date string',
    }),
    status: zod_1.z.nativeEnum(client_1.DoseStatus, {
        errorMap: () => ({ message: 'Status must be TAKEN, SKIPPED, or MISSED' }),
    }),
    takenTime: zod_1.z
        .string()
        .refine((val) => !isNaN(Date.parse(val)), {
        message: 'Taken time must be a valid ISO date string',
    })
        .optional()
        .nullable(),
    notes: zod_1.z.string().max(250).optional().nullable(),
});
