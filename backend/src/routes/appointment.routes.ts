import { Router } from 'express';
import { UserRole } from '@prisma/client';
import { appointmentController } from '../controllers/appointment.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { requireRoles } from '../middleware/role.middleware';
import { validateRequest } from '../middleware/validate.middleware';
import {
  createAppointmentSchema,
  updateAppointmentStatusSchema,
} from '../validators/appointment.validator';

const router = Router();

// Protect all appointment routes
router.use(authenticateJwt);

// Book appointment (Patients only)
router.post(
  '/',
  requireRoles(UserRole.PATIENT),
  validateRequest(createAppointmentSchema),
  (req, res) => appointmentController.createAppointment(req, res)
);

// Get appointments for authenticated patient or doctor
router.get('/', (req, res) => appointmentController.getAppointments(req, res));

// Appointment details
router.get('/:id', (req, res) => appointmentController.getAppointmentById(req, res));

// Transition appointment status (Confirm, Cancel, Complete, No-Show)
router.patch(
  '/:id/status',
  validateRequest(updateAppointmentStatusSchema),
  (req, res) => appointmentController.updateStatus(req, res)
);

// Get teleconsultation session room metadata
router.get(
  '/:id/teleconsultation',
  (req, res) => appointmentController.getTeleconsultationSession(req, res)
);

export const appointmentRoutes = router;
