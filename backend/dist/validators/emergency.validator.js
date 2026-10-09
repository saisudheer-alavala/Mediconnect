"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateMedicalIdSchema = exports.updateEmergencyContactSchema = exports.createEmergencyContactSchema = void 0;
const zod_1 = require("zod");
exports.createEmergencyContactSchema = zod_1.z.object({
    name: zod_1.z.string().trim().min(2, 'Name must be at least 2 characters').max(100),
    relationship: zod_1.z.string().trim().min(2, 'Relationship must be at least 2 characters').max(50),
    phone: zod_1.z.string().trim().min(7, 'Phone number must be at least 7 characters').max(20),
    isPrimary: zod_1.z.boolean().optional().default(false),
});
exports.updateEmergencyContactSchema = exports.createEmergencyContactSchema.partial();
exports.updateMedicalIdSchema = zod_1.z.object({
    bloodGroup: zod_1.z.string().trim().max(10).optional(),
    allergies: zod_1.z.string().trim().max(500).optional(),
    chronicDiseases: zod_1.z.string().trim().max(500).optional(),
});
