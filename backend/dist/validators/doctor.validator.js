"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.slotsQuerySchema = exports.searchDoctorSchema = void 0;
const zod_1 = require("zod");
exports.searchDoctorSchema = zod_1.z.object({
    search: zod_1.z.string().trim().optional(),
    specializationId: zod_1.z.string().uuid().optional(),
    minFee: zod_1.z.coerce.number().min(0).optional(),
    maxFee: zod_1.z.coerce.number().min(0).optional(),
    minExperience: zod_1.z.coerce.number().min(0).optional(),
    page: zod_1.z.coerce.number().int().min(1).default(1),
    limit: zod_1.z.coerce.number().int().min(1).max(50).default(20),
});
exports.slotsQuerySchema = zod_1.z.object({
    date: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'Date must be formatted as YYYY-MM-DD',
    }),
});
