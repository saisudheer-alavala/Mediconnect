import { z } from 'zod';

export const createReviewSchema = z.object({
  rating: z.number().int().min(1, 'Rating must be at least 1 star').max(5, 'Rating cannot exceed 5 stars'),
  title: z.string().trim().max(100, 'Title cannot exceed 100 characters').optional(),
  comment: z.string().trim().min(5, 'Comment must be at least 5 characters long').max(1000, 'Comment cannot exceed 1000 characters'),
  appointmentId: z.string().uuid().optional(),
});

export const reviewQuerySchema = z.object({
  page: z.string().optional().transform((val) => (val ? Math.max(1, parseInt(val, 10)) : 1)),
  limit: z.string().optional().transform((val) => (val ? Math.min(50, Math.max(1, parseInt(val, 10))) : 10)),
  minRating: z.string().optional().transform((val) => (val ? parseInt(val, 10) : undefined)),
});

export type CreateReviewInput = z.infer<typeof createReviewSchema>;
export type ReviewQueryInput = z.infer<typeof reviewQuerySchema>;
