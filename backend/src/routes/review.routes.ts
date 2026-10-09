import { Router } from 'express';
import { reviewController } from '../controllers/review.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validate.middleware';
import { createReviewSchema } from '../validators/review.validator';

const router = Router();

router.use(authenticateJwt);

// Review endpoints
router.get('/doctor/:doctorId', (req, res) => reviewController.getDoctorReviews(req, res));
router.get('/doctor/:doctorId/summary', (req, res) => reviewController.getDoctorRatingSummary(req, res));
router.post(
  '/doctor/:doctorId',
  validateRequest(createReviewSchema),
  (req, res) => reviewController.submitReview(req, res)
);

export const reviewRoutes = router;
