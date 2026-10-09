import { DoctorReview } from '@prisma/client';
import { prisma } from '../config/database';
import { CreateReviewInput } from '../validators/review.validator';

export interface DoctorRatingSummary {
  doctorId: string;
  averageRating: number;
  totalReviews: number;
  ratingBreakdown: {
    stars5: number;
    stars4: number;
    stars3: number;
    stars2: number;
    stars1: number;
  };
}

export class ReviewRepository {
  async findPatientProfileByUserId(userId: string) {
    return prisma.patientProfile.findUnique({
      where: { userId },
    });
  }

  async findDoctorById(doctorId: string) {
    return prisma.doctorProfile.findUnique({
      where: { id: doctorId },
      include: {
        specialization: true,
      },
    });
  }

  async findExistingReview(doctorId: string, patientId: string, appointmentId?: string): Promise<DoctorReview | null> {
    if (appointmentId) {
      const byAppt = await prisma.doctorReview.findFirst({
        where: { doctorId, appointmentId },
      });
      if (byAppt) return byAppt;
    }

    return prisma.doctorReview.findFirst({
      where: { doctorId, patientId },
    });
  }

  async createReview(
    doctorId: string,
    patientId: string,
    input: CreateReviewInput,
    isVerified: boolean = true
  ): Promise<DoctorReview> {
    return prisma.doctorReview.create({
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

  async findReviewsByDoctor(
    doctorId: string,
    page: number = 1,
    limit: number = 10,
    minRating?: number
  ): Promise<{ reviews: any[]; total: number; page: number; totalPages: number }> {
    const where: any = { doctorId };
    if (minRating) {
      where.rating = { gte: minRating };
    }

    const skip = (page - 1) * limit;

    const [reviews, total] = await Promise.all([
      prisma.doctorReview.findMany({
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
      prisma.doctorReview.count({ where }),
    ]);

    return {
      reviews,
      total,
      page,
      totalPages: Math.ceil(total / limit) || 1,
    };
  }

  async getDoctorRatingSummary(doctorId: string): Promise<DoctorRatingSummary> {
    const reviews = await prisma.doctorReview.findMany({
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
      if (r.rating === 5) breakdown.stars5++;
      else if (r.rating === 4) breakdown.stars4++;
      else if (r.rating === 3) breakdown.stars3++;
      else if (r.rating === 2) breakdown.stars2++;
      else if (r.rating === 1) breakdown.stars1++;
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

export const reviewRepository = new ReviewRepository();
