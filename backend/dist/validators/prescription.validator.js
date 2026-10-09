"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPrescriptionSchema = exports.prescriptionMedicineSchema = void 0;
const zod_1 = require("zod");
exports.prescriptionMedicineSchema = zod_1.z.object({
    medicineName: zod_1.z.string().trim().min(1, 'Medicine name is required').max(100),
    dosage: zod_1.z.string().trim().min(1, 'Dosage is required').max(50),
    frequency: zod_1.z.string().trim().min(1, 'Frequency is required').max(50),
    durationDays: zod_1.z.number().int().min(1, 'Duration must be at least 1 day').max(365, 'Duration cannot exceed 365 days'),
    instructions: zod_1.z.string().trim().max(255).optional(),
});
exports.createPrescriptionSchema = zod_1.z.object({
    appointmentId: zod_1.z.string().uuid('Invalid appointment ID format').optional(),
    patientId: zod_1.z.string().uuid('Invalid patient ID format'),
    diagnosis: zod_1.z.string().trim().min(2, 'Diagnosis must be at least 2 characters').max(255),
    generalInstructions: zod_1.z.string().trim().max(1000).optional(),
    medicines: zod_1.z.array(exports.prescriptionMedicineSchema).min(1, 'Prescription must contain at least one medicine'),
});
