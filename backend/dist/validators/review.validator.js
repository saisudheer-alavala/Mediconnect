"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reviewQuerySchema = exports.createReviewSchema = void 0;
const zod_1 = require("zod");
exports.createReviewSchema = zod_1.z.object({
    rating: zod_1.z.number().int().min(1, 'Rating must be at least 1 star').max(5, 'Rating cannot exceed 5 stars'),
    title: zod_1.z.string().trim().max(100, 'Title cannot exceed 100 characters').optional(),
    comment: zod_1.z.string().trim().min(5, 'Comment must be at least 5 characters long').max(1000, 'Comment cannot exceed 1000 characters'),
    appointmentId: zod_1.z.string().uuid().optional(),
});
exports.reviewQuerySchema = zod_1.z.object({
    page: zod_1.z.string().optional().transform((val) => (val ? Math.max(1, parseInt(val, 10)) : 1)),
    limit: zod_1.z.string().optional().transform((val) => (val ? Math.min(50, Math.max(1, parseInt(val, 10))) : 10)),
    minRating: zod_1.z.string().optional().transform((val) => (val ? parseInt(val, 10) : undefined)),
});
