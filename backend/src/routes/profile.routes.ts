import { Router } from 'express';
import { profileController } from '../controllers/profile.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validate.middleware';
import { authRateLimiter } from '../middleware/rate_limit.middleware';
import {
  updatePatientProfileSchema,
  updateDoctorProfileSchema,
  changePasswordSchema,
  deactivateAccountSchema,
} from '../validators/profile.validator';

const router = Router();

// Protect all profile endpoints with JWT authentication
router.use(authenticateJwt);

// Get authenticated user's profile
router.get('/me', profileController.getMyProfile);

// Update patient profile
router.put(
  '/patient',
  validateRequest(updatePatientProfileSchema),
  profileController.updatePatientProfile
);

// Update doctor profile
router.put(
  '/doctor',
  validateRequest(updateDoctorProfileSchema),
  profileController.updateDoctorProfile
);

// Change account password
router.post(
  '/change-password',
  authRateLimiter,
  validateRequest(changePasswordSchema),
  profileController.changePassword
);

// Deactivate account
router.post(
  '/deactivate',
  authRateLimiter,
  validateRequest(deactivateAccountSchema),
  profileController.deactivateAccount
);

export const profileRoutes = router;
