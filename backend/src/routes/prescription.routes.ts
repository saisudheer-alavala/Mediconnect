import { Router } from 'express';
import { UserRole } from '@prisma/client';
import { prescriptionController } from '../controllers/prescription.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { requireRoles } from '../middleware/role.middleware';
import { validateRequest } from '../middleware/validate.middleware';
import { createPrescriptionSchema } from '../validators/prescription.validator';

const router = Router();

// Protect all prescription routes
router.use(authenticateJwt);

// Issue prescription (Doctors only)
router.post(
  '/',
  requireRoles(UserRole.DOCTOR),
  validateRequest(createPrescriptionSchema),
  prescriptionController.issuePrescription
);

// Get my prescriptions (Patient or Doctor)
router.get(
  '/my',
  prescriptionController.getMyPrescriptions
);

// Get prescription for appointment
router.get(
  '/appointment/:appointmentId',
  prescriptionController.getPrescriptionByAppointmentId
);

// Get prescription details by ID
router.get(
  '/:id',
  prescriptionController.getPrescriptionById
);

export const prescriptionRoutes = router;
