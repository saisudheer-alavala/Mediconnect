"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reviewRepository = exports.ReviewRepository = void 0;
const database_1 = require("../config/database");
class ReviewRepository {
    async findPatientProfileByUserId(userId) {
        return database_1.prisma.patientProfile.findUnique({
            where: { userId },
        });
    }
    async findDoctorById(doctorId) {
        return database_1.prisma.doctorProfile.findUnique({
            where: { id: doctorId },
            include: {
                specialization: true,
            },
        });
    }
    async findExistingReview(doctorId, patientId, appointmentId) {
        if (appointmentId) {
            const byAppt = await database_1.prisma.doctorReview.findFirst({
                where: { doctorId, appointmentId },
            });
            if (byAppt)
                return byAppt;
        }
        return database_1.prisma.doctorReview.findFirst({
            where: { doctorId, patientId },
        });
    }
    async createReview(doctorId, patientId, input, isVerified = true) {
        return database_1.prisma.doctorReview.create({
            data: {
                doctorId,
                patientId,
                appointmentId: input.appointmentId,
                rating: input.rating,
                title: input.title,
                comment: input.comment,
                isVerified,
            },
            include: {
                patient: {
                    select: {
                        id: true,
                        fullName: true,
                    },
                },
            },
        });
    }
    async findReviewsByDoctor(doctorId, page = 1, limit = 10, minRating) {
        const where = { doctorId };
        if (minRating) {
            where.rating = { gte: minRating };
        }
        const skip = (page - 1) * limit;
        const [reviews, total] = await Promise.all([
            database_1.prisma.doctorReview.findMany({
                where,
                orderBy: { createdAt: 'desc' },
                skip,
                take: limit,
                include: {
                    patient: {
                        select: {
                            id: true,
                            fullName: true,
                        },
                    },
                },
            }),
            database_1.prisma.doctorReview.count({ where }),
        ]);
        return {
            reviews,
            total,
            page,
            totalPages: Math.ceil(total / limit) || 1,
        };
    }
    async getDoctorRatingSummary(doctorId) {
        const reviews = await database_1.prisma.doctorReview.findMany({
            where: { doctorId },
            select: { rating: true },
        });
        const totalReviews = reviews.length;
        if (totalReviews === 0) {
            return {
                doctorId,
                averageRating: 0,
                totalReviews: 0,
                ratingBreakdown: {
                    stars5: 0,
                    stars4: 0,
                    stars3: 0,
                    stars2: 0,
                    stars1: 0,
                },
            };
        }
        let sum = 0;
        const breakdown = {
            stars5: 0,
            stars4: 0,
            stars3: 0,
            stars2: 0,
            stars1: 0,
        };
        for (const r of reviews) {
            sum += r.rating;
            if (r.rating === 5)
                breakdown.stars5++;
            else if (r.rating === 4)
                breakdown.stars4++;
            else if (r.rating === 3)
                breakdown.stars3++;
            else if (r.rating === 2)
                breakdown.stars2++;
            else if (r.rating === 1)
                breakdown.stars1++;
        }
        const averageRating = Number((sum / totalReviews).toFixed(1));
        return {
            doctorId,
            averageRating,
            totalReviews,
            ratingBreakdown: breakdown,
        };
    }
}
exports.ReviewRepository = ReviewRepository;
exports.reviewRepository = new ReviewRepository();
