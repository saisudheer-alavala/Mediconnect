import { Request, Response } from 'express';
import { reviewService } from '../services/review.service';
import { createReviewSchema, reviewQuerySchema } from '../validators/review.validator';
import { successResponse, errorResponse } from '../utils/api_response';

export class ReviewController {
  async submitReview(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { doctorId } = req.params;
      const validated = createReviewSchema.parse(req.body);

      const result = await reviewService.submitReview(userId, doctorId, validated);
      successResponse(res, result, 'Review submitted successfully', 201);
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to submit review', 'SUBMIT_REVIEW_ERROR', 400);
    }
  }

  async getDoctorReviews(req: Request, res: Response): Promise<void> {
    try {
      const { doctorId } = req.params;
      const query = reviewQuerySchema.parse(req.query);

      const result = await reviewService.getDoctorReviews(doctorId, query);
      successResponse(res, result, 'Doctor reviews retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve doctor reviews', 'GET_REVIEWS_ERROR', 400);
    }
  }

  async getDoctorRatingSummary(req: Request, res: Response): Promise<void> {
    try {
      const { doctorId } = req.params;
      const result = await reviewService.getDoctorRatingSummary(doctorId);
      successResponse(res, result, 'Doctor rating summary retrieved successfully');
    } catch (error: any) {
      errorResponse(res, error.message || 'Failed to retrieve rating summary', 'GET_RATING_SUMMARY_ERROR', 400);
    }
  }
}

export const reviewController = new ReviewController();
