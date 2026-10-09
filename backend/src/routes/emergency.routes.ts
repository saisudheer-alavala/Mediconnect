import { Router } from 'express';
import { emergencyController } from '../controllers/emergency.controller';
import { authenticateJwt } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validate.middleware';
import {
  createEmergencyContactSchema,
  updateEmergencyContactSchema,
  updateMedicalIdSchema,
} from '../validators/emergency.validator';

const router = Router();

// Protect all emergency routes
router.use(authenticateJwt);

// ICE / Medical Profile
router.get('/profile', emergencyController.getEmergencyProfile);
router.put(
  '/profile',
  validateRequest(updateMedicalIdSchema),
  emergencyController.updateMedicalProfile
);

// Emergency Contacts
router.get('/contacts', emergencyController.getEmergencyContacts);
router.post(
  '/contacts',
  validateRequest(createEmergencyContactSchema),
  emergencyController.addEmergencyContact
);
router.put(
  '/contacts/:contactId',
  validateRequest(updateEmergencyContactSchema),
  emergencyController.updateEmergencyContact
);
router.delete(
  '/contacts/:contactId',
  emergencyController.deleteEmergencyContact
);

export const emergencyRoutes = router;
