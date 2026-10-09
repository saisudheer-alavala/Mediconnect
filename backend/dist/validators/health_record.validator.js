"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.healthRecordQuerySchema = exports.updateHealthRecordSchema = exports.createHealthRecordSchema = void 0;
const zod_1 = require("zod");
const client_1 = require("@prisma/client");
exports.createHealthRecordSchema = zod_1.z.object({
    title: zod_1.z.string().trim().min(2, 'Title must be at least 2 characters').max(150),
    category: zod_1.z.nativeEnum(client_1.HealthRecordCategory, {
        errorMap: () => ({ message: 'Invalid health record category' }),
    }).default(client_1.HealthRecordCategory.OTHER),
    description: zod_1.z.string().trim().max(1000).optional(),
    fileUrl: zod_1.z.string().trim().min(1, 'File URL or attachment path is required'),
    fileSize: zod_1.z.number().int().positive().optional(),
    mimeType: zod_1.z.string().trim().max(100).optional(),
    uploadedAt: zod_1.z.string().datetime().optional(),
});
exports.updateHealthRecordSchema = exports.createHealthRecordSchema.partial();
exports.healthRecordQuerySchema = zod_1.z.object({
    category: zod_1.z.nativeEnum(client_1.HealthRecordCategory).optional(),
    patientId: zod_1.z.string().uuid().optional(),
    search: zod_1.z.string().trim().optional(),
});
