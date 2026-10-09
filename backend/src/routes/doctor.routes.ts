import { Router } from 'express';
import { doctorController } from '../controllers/doctor.controller';
import { reviewController } from '../controllers/review.controller';
import { scheduleController } from '../controllers/schedule.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validate.middleware';
import { createReviewSchema } from '../validators/review.validator';
import { updateScheduleSchema } from '../validators/schedule.validator';

const router = Router();

// Doctor directory can be queried by authenticated users (patients, doctors, admin)
router.use(authenticateJwt);

// Specific routes before parameterized /:id
router.get('/specializations', (req, res) => doctorController.getSpecializations(req, res));

// Practitioner working hours schedule management
router.get('/me/schedule', (req, res) => scheduleController.getMySchedule(req, res));
router.put(
  '/me/schedule',
  validateRequest(updateScheduleSchema),
  (req, res) => scheduleController.updateMySchedule(req, res)
);

// Directory listing with search & filters
router.get('/', (req, res) => doctorController.getDoctors(req, res));

// Doctor details & slot templates
router.get('/:id', (req, res) => doctorController.getDoctorById(req, res));
router.get('/:id/available-slots', (req, res) => doctorController.getAvailableSlots(req, res));

// Doctor reviews & rating breakdown
router.get('/:doctorId/reviews', (req, res) => reviewController.getDoctorReviews(req, res));
router.get('/:doctorId/rating-summary', (req, res) => reviewController.getDoctorRatingSummary(req, res));
router.post(
  '/:doctorId/reviews',
  validateRequest(createReviewSchema),
  (req, res) => reviewController.submitReview(req, res)
);


export const doctorRoutes = router;
