import { reviewRepository } from '../repositories/review.repository';
import { CreateReviewInput, ReviewQueryInput } from '../validators/review.validator';

export class ReviewService {
  async submitReview(userId: string, doctorId: string, input: CreateReviewInput) {
    const patient = await reviewRepository.findPatientProfileByUserId(userId);
    if (!patient) {
      throw new Error('Only registered patients can submit doctor ratings and reviews.');
    }

    const doctor = await reviewRepository.findDoctorById(doctorId);
    if (!doctor) {
      throw new Error('Doctor profile not found.');
    }

    const existing = await reviewRepository.findExistingReview(doctorId, patient.id, input.appointmentId);
    if (existing) {
      throw new Error('You have already submitted a review for this practitioner/consultation.');
    }

    const review = await reviewRepository.createReview(doctorId, patient.id, input, true);
    const summary = await reviewRepository.getDoctorRatingSummary(doctorId);

    return {
      review,
      summary,
    };
  }

  async getDoctorReviews(doctorId: string, query: ReviewQueryInput) {
    const doctor = await reviewRepository.findDoctorById(doctorId);
    if (!doctor) {
      throw new Error('Doctor profile not found.');
    }

    return reviewRepository.findReviewsByDoctor(
      doctorId,
      query.page,
      query.limit,
      query.minRating
    );
  }

  async getDoctorRatingSummary(doctorId: string) {
    const doctor = await reviewRepository.findDoctorById(doctorId);
    if (!doctor) {
      throw new Error('Doctor profile not found.');
    }

    return reviewRepository.getDoctorRatingSummary(doctorId);
  }
}

export const reviewService = new ReviewService();
