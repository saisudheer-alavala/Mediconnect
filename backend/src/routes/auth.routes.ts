import { Router } from 'express';
import { authController } from '../controllers/auth.controller';
import { validateRequest } from '../middleware/validate.middleware';
import { authenticateJwt } from '../middleware/auth.middleware';
import {
  patientRegisterSchema,
  doctorRegisterSchema,
  loginSchema,
  refreshTokenSchema,
} from '../validators/auth.validator';

import { authRateLimiter } from '../middleware/rate_limit.middleware';

const router = Router();

// Registration with brute-force / flood protection
router.post(
  '/register/patient',
  authRateLimiter,
  validateRequest(patientRegisterSchema),
  authController.registerPatient
);
router.post(
  '/register/doctor',
  authRateLimiter,
  validateRequest(doctorRegisterSchema),
  authController.registerDoctor
);

// Login & Token Rotation
router.post(
  '/login',
  authRateLimiter,
  validateRequest(loginSchema),
  authController.login
);
router.post('/refresh-token', validateRequest(refreshTokenSchema), authController.refreshToken);

// Protected User Profile
router.get('/me', authenticateJwt, authController.getCurrentUser);

export const authRoutes = router;
