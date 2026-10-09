"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reviewController = exports.ReviewController = void 0;
const review_service_1 = require("../services/review.service");
const review_validator_1 = require("../validators/review.validator");
const api_response_1 = require("../utils/api_response");
class ReviewController {
    async submitReview(req, res) {
        try {
            const userId = req.user.userId;
            const { doctorId } = req.params;
            const validated = review_validator_1.createReviewSchema.parse(req.body);
            const result = await review_service_1.reviewService.submitReview(userId, doctorId, validated);
            (0, api_response_1.successResponse)(res, result, 'Review submitted successfully', 201);
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to submit review', 'SUBMIT_REVIEW_ERROR', 400);
        }
    }
    async getDoctorReviews(req, res) {
        try {
            const { doctorId } = req.params;
            const query = review_validator_1.reviewQuerySchema.parse(req.query);
            const result = await review_service_1.reviewService.getDoctorReviews(doctorId, query);
            (0, api_response_1.successResponse)(res, result, 'Doctor reviews retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve doctor reviews', 'GET_REVIEWS_ERROR', 400);
        }
    }
    async getDoctorRatingSummary(req, res) {
        try {
            const { doctorId } = req.params;
            const result = await review_service_1.reviewService.getDoctorRatingSummary(doctorId);
            (0, api_response_1.successResponse)(res, result, 'Doctor rating summary retrieved successfully');
        }
        catch (error) {
            (0, api_response_1.errorResponse)(res, error.message || 'Failed to retrieve rating summary', 'GET_RATING_SUMMARY_ERROR', 400);
        }
    }
}
exports.ReviewController = ReviewController;
exports.reviewController = new ReviewController();
