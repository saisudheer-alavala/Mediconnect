"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reviewService = exports.ReviewService = void 0;
const review_repository_1 = require("../repositories/review.repository");
class ReviewService {
    async submitReview(userId, doctorId, input) {
        const patient = await review_repository_1.reviewRepository.findPatientProfileByUserId(userId);
        if (!patient) {
            throw new Error('Only registered patients can submit doctor ratings and reviews.');
        }
        const doctor = await review_repository_1.reviewRepository.findDoctorById(doctorId);
        if (!doctor) {
            throw new Error('Doctor profile not found.');
        }
        const existing = await review_repository_1.reviewRepository.findExistingReview(doctorId, patient.id, input.appointmentId);
        if (existing) {
            throw new Error('You have already submitted a review for this practitioner/consultation.');
        }
        const review = await review_repository_1.reviewRepository.createReview(doctorId, patient.id, input, true);
        const summary = await review_repository_1.reviewRepository.getDoctorRatingSummary(doctorId);
        return {
            review,
            summary,
        };
    }
    async getDoctorReviews(doctorId, query) {
        const doctor = await review_repository_1.reviewRepository.findDoctorById(doctorId);
        if (!doctor) {
            throw new Error('Doctor profile not found.');
        }
        return review_repository_1.reviewRepository.findReviewsByDoctor(doctorId, query.page, query.limit, query.minRating);
    }
    async getDoctorRatingSummary(doctorId) {
        const doctor = await review_repository_1.reviewRepository.findDoctorById(doctorId);
        if (!doctor) {
            throw new Error('Doctor profile not found.');
        }
        return review_repository_1.reviewRepository.getDoctorRatingSummary(doctorId);
    }
}
exports.ReviewService = ReviewService;
exports.reviewService = new ReviewService();
